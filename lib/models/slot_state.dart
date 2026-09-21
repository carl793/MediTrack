enum SlotStatus { upcoming, due, resolved, closed }

enum DashboardState {
  notConfigured,
  lockedIdle,
  unlockedIdle,
  dispensing,
  resolvedTaken,
  resolvedMissed,
  courseCompleted,
}

class SlotState {
  final SlotStatus status;
  final String slotTime; // "08:00"
  final DateTime scheduledDateTime;
  final DateTime windowCloseTime;
  final int slotIndex;
  final int totalSlots;

  const SlotState({
    required this.status,
    required this.slotTime,
    required this.scheduledDateTime,
    required this.windowCloseTime,
    required this.slotIndex,
    required this.totalSlots,
  });

  String get doseLabel {
    if (totalSlots == 1) return 'Daily Dose';
    return 'Dose ${slotIndex + 1} of $totalSlots';
  }
}
