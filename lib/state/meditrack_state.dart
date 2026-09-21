import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/medication_config.dart';
import '../models/tray_state_model.dart';
import '../models/history_event.dart';
import '../models/device_connection.dart';
import '../models/slot_state.dart';
import '../services/firebase_service_base.dart';
import '../services/local_storage_service.dart';
import '../services/scheduling_service.dart';

class MediTrackState extends ChangeNotifier {
  final FirebaseServiceBase firebaseService;
  final LocalStorageService localStorageService;

  // ── Raw Firebase State ────────────────────────────────────────────────────
  MedicationConfig? medicationConfig;
  int stockLevel = 0;
  TrayStateModel trayState = TrayStateModel.idle();
  DeviceConnection deviceConnection = DeviceConnection.unknown();
  List<HistoryEvent> history = [];

  // ── Local State ───────────────────────────────────────────────────────────
  DateTime? lastAcknowledgedResolvedAt;
  bool isLoading = true;
  String? error;

  // ── Stream Subscriptions ──────────────────────────────────────────────────
  final List<StreamSubscription> _subs = [];

  MediTrackState({
    required this.firebaseService,
    required this.localStorageService,
  }) {
    _initialize();
  }

  Future<void> _initialize() async {
    lastAcknowledgedResolvedAt =
        localStorageService.getLastAcknowledgedResolvedAt();

    _subs.add(firebaseService.watchMedicationConfig().listen((config) {
      medicationConfig = config;
      isLoading = false;
      notifyListeners();
    }, onError: (_) {
      isLoading = false;
      notifyListeners();
    }));

    _subs.add(firebaseService.watchStockLevel().listen((stock) {
      stockLevel = stock;
      notifyListeners();
    }));

    _subs.add(firebaseService.watchTrayState().listen((tray) {
      trayState = tray;
      notifyListeners();
    }));

    _subs.add(firebaseService.watchDeviceConnection().listen((conn) {
      deviceConnection = conn;
      notifyListeners();
    }));

    _subs.add(firebaseService.watchHistory().listen((hist) {
      history = hist;
      _detectAndLogNotDispensedMisses();
      notifyListeners();
    }));
  }

  // ── Dashboard State Computation ───────────────────────────────────────────

  DashboardState get dashboardState {
    if (isLoading) return DashboardState.lockedIdle;

    final config = medicationConfig;
    if (config == null) return DashboardState.notConfigured;

    final now = DateTime.now();

    // Course completed?
    if (config.isCourseCompleted(now)) return DashboardState.courseCompleted;

    // Dispensing?
    if (trayState.isDispensing) return DashboardState.dispensing;

    // Show resolution card?
    final resolvedAt = trayState.resolvedAtDateTime;
    if (resolvedAt != null) {
      final lastAck = lastAcknowledgedResolvedAt;
      if (lastAck == null || resolvedAt.isAfter(lastAck)) {
        if (trayState.resolution == 'taken') {
          return DashboardState.resolvedTaken;
        } else if (trayState.resolution == 'missed') {
          return DashboardState.resolvedMissed;
        }
      }
    }

    // Check slot state
    final scheduler = SchedulingService(config, now);
    final slot = scheduler.getCurrentSlot(history);

    if (slot != null && slot.status == SlotStatus.due && stockLevel > 0) {
      return DashboardState.unlockedIdle;
    }

    return DashboardState.lockedIdle;
  }

  SlotState? get currentSlot {
    final config = medicationConfig;
    if (config == null) return null;
    final scheduler = SchedulingService(config, DateTime.now());
    return scheduler.getCurrentSlot(history);
  }

  // ── Computed Props ────────────────────────────────────────────────────────

  double get weeklyAdherence {
    if (history.isEmpty) return 0.0;
    final cutoff = DateTime.now().subtract(const Duration(days: 7));
    final recent = history.where((e) =>
        e.resolvedAtDateTime != null &&
        e.resolvedAtDateTime!.isAfter(cutoff)).toList();
    if (recent.isEmpty) return 0.0;
    final taken = recent.where((e) => e.isTaken).length;
    return taken / recent.length;
  }

  double get daysOfSupplyRemaining {
    final config = medicationConfig;
    if (config == null || config.dosesPerDay == 0) return 0;
    return stockLevel / config.dosesPerDay;
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> triggerDispense(String slot) async {
    try {
      await firebaseService.triggerDispense(slot: slot);
    } catch (e) {
      error = 'Failed to trigger dispense: $e';
      notifyListeners();
    }
  }

  Future<void> acknowledgeResolution() async {
    final resolvedAt = trayState.resolvedAtDateTime;
    final ts = resolvedAt ?? DateTime.now();
    await localStorageService.setLastAcknowledgedResolvedAt(ts);
    lastAcknowledgedResolvedAt = ts;
    notifyListeners();
  }

  Future<void> saveMedicationConfig(MedicationConfig config, int stock) async {
    await firebaseService.saveMedicationConfig(config);
    await firebaseService.updateStockLevel(stock);
    notifyListeners();
  }

  // ── Missed Dose Detection (App Side) ─────────────────────────────────────

  void _detectAndLogNotDispensedMisses() {
    final config = medicationConfig;
    if (config == null) return;

    final scheduler = SchedulingService(config, DateTime.now());
    final closedSlots = scheduler.getClosedUnresolvedSlots(history);

    for (final slotTime in closedSlots) {
      _logNotDispensed(slotTime);
    }
  }

  Future<void> _logNotDispensed(String slotTime) async {
    final config = medicationConfig;
    if (config == null) return;
    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Double-check it hasn't been logged already
    final alreadyLogged = history.any((e) =>
        e.scheduledFor == slotTime &&
        e.date == dateStr &&
        e.reason == 'not_dispensed');
    if (alreadyLogged) return;

    await firebaseService.addHistoryEvent(HistoryEvent(
      id: '',
      medicationName: config.name,
      scheduledFor: slotTime,
      date: dateStr,
      dispensedAt: null,
      resolvedAt: now.millisecondsSinceEpoch,
      resolution: 'missed',
      reason: 'not_dispensed',
    ));
  }

  @override
  void dispose() {
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }
}
