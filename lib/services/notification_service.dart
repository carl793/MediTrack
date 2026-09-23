import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/medication_config.dart';

/// MediTrack notification strategy:
///
/// We do NOT use zonedSchedule / AlarmManager because Android 12+ blocks
/// exact alarms on sideloaded apps and the permission cannot be granted manually.
///
/// Instead, the app's 60-second clock timer (in MediTrackState) calls
/// [maybeFireDueNotification] every minute. When a slot transitions to DUE
/// that has not yet been notified, we fire an immediate notification via show().
///
/// This approach:
/// - Requires no special Android permissions beyond POST_NOTIFICATIONS
/// - Works on all Android versions including 12+
/// - Is reliable as long as the app is open (which is the expected use case —
///   the user opens the app to trigger the dispense anyway)
/// - Fires within 60 seconds of the scheduled time (same practical result)
class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // Track which slots we have already notified so we don't spam
  final Set<String> _notifiedSlots = {}; // "YYYY-MM-DD|HH:MM"

  Future<void> initialize() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    // Create channel (Android 8+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(
          const AndroidNotificationChannel(
            'meditrack_doses',
            'Dose Reminders',
            description:
                'Alerts when it is time to take your medication',
            importance: Importance.max,
            enableVibration: true,
            playSound: true,
          ),
        );

    // Request POST_NOTIFICATIONS permission (Android 13+)
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

    _initialized = true;
    if (kDebugMode) debugPrint('NotificationService initialized (immediate mode)');
  }

  /// Called every 60 seconds by MediTrackState's clock timer.
  /// Fires a notification if [slotTime] on [date] just became DUE
  /// and hasn't already been notified.
  Future<void> maybeFireDueNotification({
    required MedicationConfig config,
    required String slotTime,   // "HH:MM"
    required String date,       // "YYYY-MM-DD"
  }) async {
    if (!_initialized) await initialize();

    final key = '$date|$slotTime';
    if (_notifiedSlots.contains(key)) return; // already fired

    _notifiedSlots.add(key);

    // Format display time
    final parts = slotTime.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    final display = '$h12:$m $period';

    await _plugin.show(
      slotTime.hashCode ^ date.hashCode, // unique stable ID
      'MediTrack Reminder',
      'It is $display. Time to take your ${config.name}.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'meditrack_doses',
          'Dose Reminders',
          channelDescription: 'Alerts when it is time to take your medication',
          importance: Importance.max,
          priority: Priority.max,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );

    if (kDebugMode) {
      debugPrint('Notification fired for $config.name at $slotTime ($date)');
    }
  }

  /// Clear the notified-slots cache (call when config changes or on new day)
  void clearCache() {
    _notifiedSlots.clear();
  }

  /// Clear cache for a new calendar day
  void clearCacheForDate(String date) {
    _notifiedSlots.removeWhere((key) => !key.startsWith(date));
  }

  // Keep this for compatibility — no-op since we no longer pre-schedule
  Future<void> scheduleAll(MedicationConfig config) async {
    if (!_initialized) await initialize();
    // No-op: notifications are fired on-demand by maybeFireDueNotification
    if (kDebugMode) debugPrint('scheduleAll: using immediate notification mode');
  }

  Future<void> cancelAll() async {
    if (!_initialized) return;
    await _plugin.cancelAll();
    _notifiedSlots.clear();
  }
}
