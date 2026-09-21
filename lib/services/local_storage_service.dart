import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const _keyLastAck = 'lastAcknowledgedResolvedAt';

  final SharedPreferences _prefs;
  LocalStorageService(this._prefs);

  /// Returns null if never acknowledged
  DateTime? getLastAcknowledgedResolvedAt() {
    final ms = _prefs.getInt(_keyLastAck);
    if (ms == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(ms);
  }

  Future<void> setLastAcknowledgedResolvedAt(DateTime dt) async {
    await _prefs.setInt(_keyLastAck, dt.millisecondsSinceEpoch);
  }

  Future<void> clearAll() async {
    await _prefs.clear();
  }
}
