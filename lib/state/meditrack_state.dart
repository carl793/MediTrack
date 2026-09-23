import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/medication_config.dart';
import '../models/tray_state_model.dart';
import '../models/history_event.dart';
import '../models/device_connection.dart';
import '../models/slot_state.dart';
import '../services/firebase_service_base.dart';
import '../services/local_storage_service.dart';
import '../services/notification_service.dart';
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

  // ── Internals ─────────────────────────────────────────────────────────────
  final List<StreamSubscription> _subs = [];
  Timer? _clockTimer; // fires every 60s so slot state stays live
  MedicationConfig? _lastScheduledConfig; // track when to reschedule notifs
  String? _lastDashSig;

  MediTrackState({
    required this.firebaseService,
    required this.localStorageService,
  }) {
    _initialize();
  }

  Future<void> _initialize() async {
    lastAcknowledgedResolvedAt =
        localStorageService.getLastAcknowledgedResolvedAt();

    // Initialize notification service
    await NotificationService().initialize();

    _subs.add(firebaseService.watchMedicationConfig().listen((config) {
      medicationConfig = config;
      isLoading = false;
      // Reschedule notifications when config changes
      _rescheduleNotificationsIfNeeded(config);
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

    // ── Clock tick: rebuilds dashboard state every 5 seconds for responsive UI ──
    _clockTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _checkAndFireDueNotification();
      notifyListeners();
      _detectAndLogNotDispensedMisses();
    });
  }

  void _rescheduleNotificationsIfNeeded(MedicationConfig? config) {
    if (config == null) {
      NotificationService().cancelAll();
      _lastScheduledConfig = null;
      return;
    }
    // Clear notification cache when config changes so slots re-notify correctly
    if (_lastScheduledConfig != null &&
        _lastScheduledConfig!.alarmTimes.join(',') !=
            config.alarmTimes.join(',')) {
      NotificationService().clearCache();
    }
    _lastScheduledConfig = config;
  }

  // ── Dashboard State Computation ───────────────────────────────────────────

  DashboardState get dashboardState {
    if (isLoading) return DashboardState.lockedIdle;

    final config = medicationConfig;
    if (config == null || config.alarmTimes.isEmpty) {
      _dbgDash('E', 'config_null', DashboardState.notConfigured, {
        'branch': config == null ? 'config_null' : 'empty_alarms',
        'alarmCount': config?.alarmTimes.length ?? 0,
      });
      return DashboardState.notConfigured;
    }

    final now = DateTime.now();

    if (config.isCourseCompleted(now)) return DashboardState.courseCompleted;
    if (trayState.isDispensing) return DashboardState.dispensing;

    // Show resolution card if there's an unacknowledged result from tray
    final resolvedAt = trayState.resolvedAtDateTime;
    if (resolvedAt != null) {
      final lastAck = lastAcknowledgedResolvedAt;
      if (lastAck == null || resolvedAt.isAfter(lastAck)) {
        if (trayState.resolution == 'taken') {
          return DashboardState.resolvedTaken;
        } else if (trayState.resolution == 'missed') {
          _dbgDash('A', 'tray_unacked_miss', DashboardState.resolvedMissed, {
            'branch': 'tray_unacked_miss',
            'trayResolvedAtMs': resolvedAt.millisecondsSinceEpoch,
            'lastAckMs': lastAck?.millisecondsSinceEpoch,
            'alarmCount': config.alarmTimes.length,
          });
          return DashboardState.resolvedMissed;
        }
      }
    }

    // Check for recent unacknowledged missed doses in history (not_dispensed, not_picked_up)
    if (history.isNotEmpty) {
      final recentMissed = history.where((e) {
        if (!e.isMissed) return false;
        final eventTime = e.resolvedAtDateTime;
        if (eventTime == null) return false;
        final lastAck = lastAcknowledgedResolvedAt;
        return lastAck == null || eventTime.isAfter(lastAck);
      }).toList();
      
      if (recentMissed.isNotEmpty) {
        final newest = recentMissed
            .map((e) => e.resolvedAt)
            .whereType<int>()
            .fold<int>(0, (a, b) => a > b ? a : b);
        _dbgDash('A', 'history_unacked_miss', DashboardState.resolvedMissed, {
          'branch': 'history_unacked_miss',
          'unackedMissCount': recentMissed.length,
          'newestMissMs': newest,
          'lastAckMs': lastAcknowledgedResolvedAt?.millisecondsSinceEpoch,
          'trayResolvedAtMs': resolvedAt?.millisecondsSinceEpoch,
          'alarmCount': config.alarmTimes.length,
        });
        return DashboardState.resolvedMissed;
      }
    }

    final scheduler = SchedulingService(config, now);
    final slot = scheduler.getCurrentSlot(history);

    if (slot != null && slot.status == SlotStatus.due) {
      _dbgDash('C', 'due_slot', DashboardState.unlockedIdle, {
        'branch': 'due_slot',
        'slotTime': slot.slotTime,
        'alarmCount': config.alarmTimes.length,
      });
      return DashboardState.unlockedIdle;
    }

    _dbgDash('C', 'locked_idle', DashboardState.lockedIdle, {
      'branch': 'locked_idle',
      'slotTime': slot?.slotTime,
      'slotStatus': slot?.status.name,
      'alarmCount': config.alarmTimes.length,
      'lastAckMs': lastAcknowledgedResolvedAt?.millisecondsSinceEpoch,
    });
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
    // Dismiss every resolution currently known (tray + history), not only
    // the tray timestamp. Using a stale tray time left later history misses
    // unacked, so Okay kept showing resolvedMissed.
    var ms = DateTime.now().millisecondsSinceEpoch;
    final trayMs = trayState.resolvedAt;
    if (trayMs != null && trayMs > ms) ms = trayMs;
    for (final e in history) {
      final t = e.resolvedAt;
      if (t != null && t > ms) ms = t;
    }
    final ts = DateTime.fromMillisecondsSinceEpoch(ms);
    final unackedMissAfterWouldRemain = history.where((e) {
      if (!e.isMissed || e.resolvedAtDateTime == null) return false;
      return e.resolvedAtDateTime!.isAfter(ts);
    }).length;
    // #region agent log
    _agentLog('A', 'meditrack_state.acknowledgeResolution', 'ack_called', {
      'runId': 'post-fix',
      'trayResolvedAtMs': trayState.resolvedAtDateTime?.millisecondsSinceEpoch,
      'trayResolution': trayState.resolution,
      'chosenTsMs': ts.millisecondsSinceEpoch,
      'prevLastAckMs': lastAcknowledgedResolvedAt?.millisecondsSinceEpoch,
      'historyLen': history.length,
      'unackedMissAfterChosen': unackedMissAfterWouldRemain,
      'nowMs': DateTime.now().millisecondsSinceEpoch,
    });
    // #endregion
    await localStorageService.setLastAcknowledgedResolvedAt(ts);
    lastAcknowledgedResolvedAt = ts;
    notifyListeners();
  }

  Future<void> saveMedicationConfig(MedicationConfig config, int stock) async {
    await firebaseService.saveMedicationConfig(config);
    await firebaseService.updateStockLevel(stock);
    // Clear notification cache so new schedule takes effect immediately
    NotificationService().clearCache();
    _lastScheduledConfig = config;
    notifyListeners();
  }

  // ── Notification Firing (on clock tick) ──────────────────────────────────

  String _lastNotifDate = '';

  void _checkAndFireDueNotification() {
    final config = medicationConfig;
    if (config == null) return;

    final now = DateTime.now();
    final dateStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    // Clear cache on new day
    if (_lastNotifDate != dateStr) {
      _lastNotifDate = dateStr;
      NotificationService().clearCacheForDate(dateStr);
    }

    // Check each alarm time — if it just became DUE (within last 60s), fire
    final scheduler = SchedulingService(config, now);
    final slot = scheduler.getCurrentSlot(history);

    if (slot != null && slot.status == SlotStatus.due) {
      // Only fire if the slot JUST became due (within last 65s buffer)
      final secondsSinceAlarm = now.difference(slot.scheduledDateTime).inSeconds;
      if (secondsSinceAlarm >= 0 && secondsSinceAlarm <= 65) {
        NotificationService().maybeFireDueNotification(
          config: config,
          slotTime: slot.slotTime,
          date: dateStr,
        );
      }
    }
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

    final alreadyLogged = history.any((e) =>
        e.scheduledFor == slotTime &&
        e.date == dateStr &&
        e.reason == 'not_dispensed');
    if (alreadyLogged) return;

    // #region agent log
    _agentLog('B', 'meditrack_state._logNotDispensed', 'logging_new_miss', {
      'slotTime': slotTime,
      'dateStr': dateStr,
      'historyLen': history.length,
      'lastAckMs': lastAcknowledgedResolvedAt?.millisecondsSinceEpoch,
    });
    // #endregion

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
    _clockTimer?.cancel();
    for (final sub in _subs) {
      sub.cancel();
    }
    super.dispose();
  }

  void _dbgDash(
    String hypothesisId,
    String message,
    DashboardState result,
    Map<String, Object?> data,
  ) {
    final sig =
        '${result.name}|${data['branch']}|${data['lastAckMs']}|${data['unackedMissCount']}|${data['newestMissMs']}';
    if (_lastDashSig == sig) return;
    _lastDashSig = sig;
    // #region agent log
    _agentLog(hypothesisId, 'meditrack_state.dashboardState', message, {
      ...data,
      'result': result.name,
    });
    // #endregion
  }

  void _agentLog(
    String hypothesisId,
    String location,
    String message,
    Map<String, Object?> data,
  ) {
    // #region agent log
    try {
      final payload = jsonEncode({
        'sessionId': '32f2cc',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'hypothesisId': hypothesisId,
        'location': location,
        'message': message,
        'data': data,
      });
      debugPrint('DBG32f2cc $payload');
      try {
        File(r'C:\Users\63960\Desktop\Flutter projects\meditrack\debug-32f2cc.log')
            .writeAsStringSync('$payload\n', mode: FileMode.append, flush: true);
      } catch (_) {}
      for (final host in ['127.0.0.1', '10.0.2.2']) {
        HttpClient()
            .postUrl(Uri.parse(
                'http://$host:7752/ingest/58e13aff-1765-4912-8bde-eb185a3d7eb2'))
            .then((req) {
          req.headers.contentType = ContentType.json;
          req.headers.set('X-Debug-Session-Id', '32f2cc');
          req.write(payload);
          return req.close();
        }).catchError((_) {});
      }
    } catch (_) {}
    // #endregion
  }
}
