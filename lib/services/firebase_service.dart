import 'package:firebase_database/firebase_database.dart';
import '../models/medication_config.dart';
import '../models/tray_state_model.dart';
import '../models/history_event.dart';
import '../models/device_connection.dart';
import 'firebase_service_base.dart';

/// Production Firebase implementation — requires google-services.json.
class FirebaseService extends FirebaseServiceBase {
  final DatabaseReference _db;

  FirebaseService(this._db);

  // ── Medication Config ─────────────────────────────────────────────────────

  @override
  Stream<MedicationConfig?> watchMedicationConfig() {
    return _db.child('medication').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return null;
      try {
        return MedicationConfig.fromJson(data as Map<dynamic, dynamic>);
      } catch (_) {
        return null;
      }
    });
  }

  @override
  Future<void> saveMedicationConfig(MedicationConfig config) async {
    await _db.child('medication').set(config.toJson());
  }

  // ── Stock ─────────────────────────────────────────────────────────────────

  @override
  Stream<int> watchStockLevel() {
    return _db.child('stock/current').onValue.map((event) {
      final val = event.snapshot.value;
      if (val == null) return 0;
      return int.tryParse(val.toString()) ?? 0;
    });
  }

  @override
  Future<void> updateStockLevel(int level) async {
    await _db.child('stock/current').set(level);
  }

  // ── Dispense Trigger ──────────────────────────────────────────────────────

  @override
  Future<void> triggerDispense({required String slot}) async {
    await _db.child('dispense').set({
      'triggerDispense': true,
      'requestedAt': DateTime.now().millisecondsSinceEpoch,
      'requestedSlot': slot,
    });
  }

  @override
  Future<void> clearDispenseTrigger() async {
    await _db.child('dispense/triggerDispense').set(false);
  }

  // ── Tray State ────────────────────────────────────────────────────────────

  @override
  Stream<TrayStateModel> watchTrayState() {
    return _db.child('tray').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return TrayStateModel.idle();
      try {
        return TrayStateModel.fromJson(data as Map<dynamic, dynamic>);
      } catch (_) {
        return TrayStateModel.idle();
      }
    });
  }

  // ── Device Connection ─────────────────────────────────────────────────────

  @override
  Stream<DeviceConnection> watchDeviceConnection() {
    return _db.child('device').onValue.map((event) {
      final data = event.snapshot.value;
      if (data == null) return DeviceConnection.unknown();
      try {
        return DeviceConnection.fromJson(data as Map<dynamic, dynamic>);
      } catch (_) {
        return DeviceConnection.unknown();
      }
    });
  }

  // ── History ───────────────────────────────────────────────────────────────

  @override
  Stream<List<HistoryEvent>> watchHistory() {
    return _db
        .child('history')
        .orderByChild('resolvedAt')
        .limitToLast(200)
        .onValue
        .map((event) {
      final data = event.snapshot.value;
      if (data == null) return <HistoryEvent>[];
      if (data is! Map) return <HistoryEvent>[];
      final events = data.entries
          .map((e) {
            try {
              return HistoryEvent.fromJson(
                  e.key.toString(), e.value as Map<dynamic, dynamic>);
            } catch (_) {
              return null;
            }
          })
          .whereType<HistoryEvent>()
          .toList();
      events.sort((a, b) => (b.resolvedAt ?? 0).compareTo(a.resolvedAt ?? 0));
      return events;
    });
  }

  @override
  Future<void> addHistoryEvent(HistoryEvent event) async {
    final ref = _db.child('history').push();
    await ref.set(event.toJson());
  }

  // ── Debug helpers ─────────────────────────────────────────────────────────

  @override
  Future<void> debugSimulateDispensing(String slot) async {
    await _db.child('tray').set({
      'state': 'dispensing',
      'activeSlot': slot,
      'weightGrams': 0.0,
      'dispensedAt': DateTime.now().millisecondsSinceEpoch,
      'resolvedAt': null,
      'resolution': null,
    });
  }

  @override
  Future<void> debugSimulateTaken(String slot, String medName) async {
    final now = DateTime.now();
    final resolvedAt = now.millisecondsSinceEpoch;
    final dispensedAt =
        now.subtract(const Duration(minutes: 1)).millisecondsSinceEpoch;
    await _db.child('tray').set({
      'state': 'idle',
      'activeSlot': slot,
      'weightGrams': 0.0,
      'dispensedAt': dispensedAt,
      'resolvedAt': resolvedAt,
      'resolution': 'taken',
    });
    final ref = _db.child('history').push();
    await ref.set({
      'medicationName': medName,
      'scheduledFor': slot,
      'date': _todayStr(now),
      'dispensedAt': dispensedAt,
      'resolvedAt': resolvedAt,
      'resolution': 'taken',
      'reason': null,
    });
  }

  @override
  Future<void> debugSimulateMissed(
      String slot, String medName, String reason) async {
    final now = DateTime.now();
    final resolvedAt = now.millisecondsSinceEpoch;
    await _db.child('tray').set({
      'state': 'idle',
      'activeSlot': slot,
      'weightGrams': 0.2,
      'dispensedAt': reason == 'not_picked_up'
          ? now
              .subtract(const Duration(minutes: 16))
              .millisecondsSinceEpoch
          : null,
      'resolvedAt': resolvedAt,
      'resolution': 'missed',
    });
    final ref = _db.child('history').push();
    await ref.set({
      'medicationName': medName,
      'scheduledFor': slot,
      'date': _todayStr(now),
      'dispensedAt': reason == 'not_picked_up'
          ? now
              .subtract(const Duration(minutes: 16))
              .millisecondsSinceEpoch
          : null,
      'resolvedAt': resolvedAt,
      'resolution': 'missed',
      'reason': reason,
    });
  }

  @override
  Future<void> debugSetDeviceOnline() async {
    await _db.child('device').set({
      'connected': true,
      'lastSeen': DateTime.now().millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> debugSetDeviceOffline() async {
    await _db.child('device').set({
      'connected': false,
      'lastSeen': DateTime.now()
          .subtract(const Duration(minutes: 5))
          .millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> debugClearAll() async {
    await _db.remove();
  }

  String _todayStr(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
