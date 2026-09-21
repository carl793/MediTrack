import '../models/medication_config.dart';
import '../models/slot_state.dart';
import '../models/history_event.dart';

class SchedulingService {
  final MedicationConfig config;
  final DateTime now;

  SchedulingService(this.config, this.now);

  /// Returns the current "active" slot — either DUE or the next UPCOMING one.
  SlotState? getCurrentSlot(List<HistoryEvent> history) {
    if (!config.isActiveDay(now)) {
      // Not an active day — find next active day
      return _getNextUpcomingSlot();
    }

    final today = _dateOnly(now);
    final todayStr = _dateString(today);
    final sortedTimes = List<String>.from(config.alarmTimes)..sort();

    for (int i = 0; i < sortedTimes.length; i++) {
      final slotTime = sortedTimes[i];
      final scheduledDt = _buildDateTime(today, slotTime);
      final windowClose = _computeWindowClose(i, sortedTimes, today);

      // Already resolved for today?
      final resolved = history.any((e) =>
          e.scheduledFor == slotTime && e.date == todayStr);
      if (resolved) continue;

      if (now.isBefore(scheduledDt)) {
        // This is the next upcoming slot
        return SlotState(
          status: SlotStatus.upcoming,
          slotTime: slotTime,
          scheduledDateTime: scheduledDt,
          windowCloseTime: windowClose,
          slotIndex: i,
          totalSlots: sortedTimes.length,
        );
      } else if (now.isBefore(windowClose)) {
        // This slot is currently DUE
        return SlotState(
          status: SlotStatus.due,
          slotTime: slotTime,
          scheduledDateTime: scheduledDt,
          windowCloseTime: windowClose,
          slotIndex: i,
          totalSlots: sortedTimes.length,
        );
      }
      // Slot is past its window — it's a missed candidate (closed without resolution)
    }

    // All today's slots are done or missed — show tomorrow's first slot
    return _getNextUpcomingSlot();
  }

  SlotState? _getNextUpcomingSlot() {
    final sortedTimes = List<String>.from(config.alarmTimes)..sort();
    if (sortedTimes.isEmpty) return null;

    for (int d = 1; d <= 7; d++) {
      final candidate = _dateOnly(now).add(Duration(days: d));
      if (!config.isActiveDay(candidate)) continue;
      final scheduledDt = _buildDateTime(candidate, sortedTimes[0]);
      final windowClose = _computeWindowClose(0, sortedTimes, candidate);
      return SlotState(
        status: SlotStatus.upcoming,
        slotTime: sortedTimes[0],
        scheduledDateTime: scheduledDt,
        windowCloseTime: windowClose,
        slotIndex: 0,
        totalSlots: sortedTimes.length,
      );
    }
    return null;
  }

  /// Returns all slots today that are past their window and unresolved.
  List<String> getClosedUnresolvedSlots(List<HistoryEvent> history) {
    if (!config.isActiveDay(now)) return [];

    final today = _dateOnly(now);
    final todayStr = _dateString(today);
    final sortedTimes = List<String>.from(config.alarmTimes)..sort();
    final missed = <String>[];

    for (int i = 0; i < sortedTimes.length; i++) {
      final slotTime = sortedTimes[i];
      final windowClose = _computeWindowClose(i, sortedTimes, today);

      if (now.isBefore(windowClose)) continue; // Still open

      final resolved = history.any((e) =>
          e.scheduledFor == slotTime && e.date == todayStr);
      if (!resolved) {
        missed.add(slotTime);
      }
    }
    return missed;
  }

  DateTime _computeWindowClose(
      int index, List<String> sortedTimes, DateTime baseDate) {
    if (index < sortedTimes.length - 1) {
      return _buildDateTime(baseDate, sortedTimes[index + 1]);
    }
    // Last slot: closes at midnight
    return DateTime(baseDate.year, baseDate.month, baseDate.day, 23, 59, 59);
  }

  DateTime _buildDateTime(DateTime date, String hhmm) {
    final parts = hhmm.split(':');
    return DateTime(
      date.year,
      date.month,
      date.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    );
  }

  DateTime _dateOnly(DateTime dt) =>
      DateTime(dt.year, dt.month, dt.day);

  String _dateString(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
