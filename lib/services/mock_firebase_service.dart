import 'dart:async';
import '../models/medication_config.dart';
import '../models/tray_state_model.dart';
import '../models/history_event.dart';
import '../models/device_connection.dart';
import 'firebase_service_base.dart';

/// In-memory mock that simulates the Firebase Realtime Database.
/// Used for UI development and testing without hardware or a Firebase project.
///
/// The entire app runs against this — all 7 dashboard states are reachable
/// by toggling internal state via the debug panel.
class MockFirebaseService extends FirebaseServiceBase {
  // ── In-memory state ───────────────────────────────────────────────────────
  MedicationConfig? _medication;
  int _stock = 0;
  TrayStateModel _tray = TrayStateModel.idle();
  DeviceConnection _device = DeviceConnection.unknown();
  final List<HistoryEvent> _history = [];

  // ── StreamControllers ─────────────────────────────────────────────────────
  final _medCtrl = StreamController<MedicationConfig?>.broadcast();
  final _stockCtrl = StreamController<int>.broadcast();
  final _trayCtrl = StreamController<TrayStateModel>.broadcast();
  final _deviceCtrl = StreamController<DeviceConnection>.broadcast();
  final _historyCtrl = StreamController<List<HistoryEvent>>.broadcast();

  MockFirebaseService() {
    // Start with device online so UI shows connected state
    _device = DeviceConnection(
      connected: true,
      lastSeen: DateTime.now().millisecondsSinceEpoch,
    );
    // Emit initial connected state
    Future.microtask(() => _deviceCtrl.add(_device));

    // Keep device heartbeat ticking
    Timer.periodic(const Duration(seconds: 30), (_) {
      _device = DeviceConnection(
        connected: true,
        lastSeen: DateTime.now().millisecondsSinceEpoch,
      );
      _deviceCtrl.add(_device);
    });
  }

  // ── Medication ────────────────────────────────────────────────────────────

  @override
  Stream<MedicationConfig?> watchMedicationConfig() {
    // Emit current value immediately to new listeners
    return _medCtrl.stream.newListener(_medication);
  }

  @override
  Future<void> saveMedicationConfig(MedicationConfig config) async {
    _medication = config;
    _medCtrl.add(_medication);
  }

  // ── Stock ─────────────────────────────────────────────────────────────────

  @override
  Stream<int> watchStockLevel() => _stockCtrl.stream.newListener(_stock);

  @override
  Future<void> updateStockLevel(int level) async {
    _stock = level.clamp(0, 15);
    _stockCtrl.add(_stock);
  }

  // ── Dispense ──────────────────────────────────────────────────────────────

  @override
  Future<void> triggerDispense({required String slot}) async {
    // Simulate ESP32 reacting: set dispensing immediately
    await debugSimulateDispensing(slot);

    // After 3 seconds simulate pill taken (auto-complete for demo)
    Future.delayed(const Duration(seconds: 3), () {
      debugSimulateTaken(slot, _medication?.name ?? 'Medication');
    });
  }

  @override
  Future<void> clearDispenseTrigger() async {}

  // ── Tray ──────────────────────────────────────────────────────────────────

  @override
  Stream<TrayStateModel> watchTrayState() =>
      _trayCtrl.stream.newListener(_tray);

  // ── Device ────────────────────────────────────────────────────────────────

  @override
  Stream<DeviceConnection> watchDeviceConnection() =>
      _deviceCtrl.stream.newListener(_device);

  // ── History ───────────────────────────────────────────────────────────────

  @override
  Stream<List<HistoryEvent>> watchHistory() =>
      _historyCtrl.stream.newListener(List.from(_history));

  @override
  Future<void> addHistoryEvent(HistoryEvent event) async {
    final id =
        'mock_${DateTime.now().millisecondsSinceEpoch}_${_history.length}';
    _history.insert(0, HistoryEvent(
      id: id,
      medicationName: event.medicationName,
      scheduledFor: event.scheduledFor,
      date: event.date,
      dispensedAt: event.dispensedAt,
      resolvedAt: event.resolvedAt,
      resolution: event.resolution,
      reason: event.reason,
    ));
    _historyCtrl.add(List.from(_history));
  }

  // ── Debug Simulation ──────────────────────────────────────────────────────

  @override
  Future<void> debugSimulateDispensing(String slot) async {
    _tray = TrayStateModel(
      state: 'dispensing',
      activeSlot: slot,
      weightGrams: 0.0,
      dispensedAt: DateTime.now().millisecondsSinceEpoch,
      resolvedAt: null,
      resolution: null,
    );
    _trayCtrl.add(_tray);
  }

  @override
  Future<void> debugSimulateTaken(String slot, String medName) async {
    final now = DateTime.now();
    final resolvedAt = now.millisecondsSinceEpoch;
    final dispensedAt = now
        .subtract(const Duration(seconds: 3))
        .millisecondsSinceEpoch;

    _tray = TrayStateModel(
      state: 'idle',
      activeSlot: slot,
      weightGrams: 0.0,
      dispensedAt: dispensedAt,
      resolvedAt: resolvedAt,
      resolution: 'taken',
    );
    _trayCtrl.add(_tray);

    // Decrement stock
    if (_stock > 0) {
      _stock--;
      _stockCtrl.add(_stock);
    }

    // Add history record
    await addHistoryEvent(HistoryEvent(
      id: '',
      medicationName: medName,
      scheduledFor: slot,
      date: _todayStr(now),
      dispensedAt: dispensedAt,
      resolvedAt: resolvedAt,
      resolution: 'taken',
      reason: null,
    ));
  }

  @override
  Future<void> debugSimulateMissed(
      String slot, String medName, String reason) async {
    final now = DateTime.now();
    final resolvedAt = now.millisecondsSinceEpoch;

    _tray = TrayStateModel(
      state: 'idle',
      activeSlot: slot,
      weightGrams: reason == 'not_picked_up' ? 0.3 : 0.0,
      dispensedAt: reason == 'not_picked_up'
          ? now.subtract(const Duration(minutes: 16)).millisecondsSinceEpoch
          : null,
      resolvedAt: resolvedAt,
      resolution: 'missed',
    );
    _trayCtrl.add(_tray);

    await addHistoryEvent(HistoryEvent(
      id: '',
      medicationName: medName,
      scheduledFor: slot,
      date: _todayStr(now),
      dispensedAt: reason == 'not_picked_up'
          ? now.subtract(const Duration(minutes: 16)).millisecondsSinceEpoch
          : null,
      resolvedAt: resolvedAt,
      resolution: 'missed',
      reason: reason,
    ));
  }

  @override
  Future<void> debugSetDeviceOnline() async {
    _device = DeviceConnection(
      connected: true,
      lastSeen: DateTime.now().millisecondsSinceEpoch,
    );
    _deviceCtrl.add(_device);
  }

  @override
  Future<void> debugSetDeviceOffline() async {
    _device = DeviceConnection(
      connected: false,
      lastSeen: DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch,
    );
    _deviceCtrl.add(_device);
  }

  @override
  Future<void> debugClearAll() async {
    _medication = null;
    _stock = 0;
    _tray = TrayStateModel.idle();
    _history.clear();

    _medCtrl.add(null);
    _stockCtrl.add(0);
    _trayCtrl.add(_tray);
    _historyCtrl.add([]);
  }

  String _todayStr(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}

// ── Stream helper extension ───────────────────────────────────────────────

extension _BroadcastExt<T> on Stream<T> {
  /// Returns a stream that emits [initialValue] immediately on first listen,
  /// then follows the broadcast stream. This replicates Firebase's behaviour
  /// of emitting the current value on subscription.
  Stream<T> newListener(T initialValue) async* {
    yield initialValue;
    yield* this;
  }
}
