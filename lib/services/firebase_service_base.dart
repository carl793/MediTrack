import '../models/medication_config.dart';
import '../models/tray_state_model.dart';
import '../models/history_event.dart';
import '../models/device_connection.dart';

/// Abstract interface — implemented by [FirebaseService] (real) and
/// [MockFirebaseService] (dev/test without hardware).
abstract class FirebaseServiceBase {
  Stream<MedicationConfig?> watchMedicationConfig();
  Future<void> saveMedicationConfig(MedicationConfig config);

  Stream<int> watchStockLevel();
  Future<void> updateStockLevel(int level);

  Future<void> triggerDispense({required String slot});
  Future<void> clearDispenseTrigger();

  Stream<TrayStateModel> watchTrayState();
  Stream<DeviceConnection> watchDeviceConnection();

  Stream<List<HistoryEvent>> watchHistory();
  Future<void> addHistoryEvent(HistoryEvent event);

  // Debug helpers
  Future<void> debugSimulateDispensing(String slot);
  Future<void> debugSimulateTaken(String slot, String medName);
  Future<void> debugSimulateMissed(String slot, String medName, String reason);
  Future<void> debugSetDeviceOnline();
  Future<void> debugSetDeviceOffline();
  Future<void> debugClearAll();
}
