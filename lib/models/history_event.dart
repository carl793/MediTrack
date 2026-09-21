class HistoryEvent {
  final String id;
  final String medicationName;
  final String scheduledFor; // "08:00"
  final String date; // "2026-09-21"
  final int? dispensedAt; // epoch ms, null for not_dispensed
  final int? resolvedAt; // epoch ms
  final String resolution; // "taken" | "missed"
  final String? reason; // null | "not_picked_up" | "not_dispensed"

  const HistoryEvent({
    required this.id,
    required this.medicationName,
    required this.scheduledFor,
    required this.date,
    this.dispensedAt,
    this.resolvedAt,
    required this.resolution,
    this.reason,
  });

  factory HistoryEvent.fromJson(String id, Map<dynamic, dynamic> json) {
    return HistoryEvent(
      id: id,
      medicationName: (json['medicationName'] ?? '').toString(),
      scheduledFor: (json['scheduledFor'] ?? '').toString(),
      date: (json['date'] ?? '').toString(),
      dispensedAt: json['dispensedAt'] != null
          ? int.tryParse(json['dispensedAt'].toString())
          : null,
      resolvedAt: json['resolvedAt'] != null
          ? int.tryParse(json['resolvedAt'].toString())
          : null,
      resolution: (json['resolution'] ?? 'missed').toString(),
      reason: json['reason']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'medicationName': medicationName,
      'scheduledFor': scheduledFor,
      'date': date,
      'dispensedAt': dispensedAt,
      'resolvedAt': resolvedAt,
      'resolution': resolution,
      'reason': reason,
    };
  }

  bool get isTaken => resolution == 'taken';
  bool get isMissed => resolution == 'missed';
  bool get isNotPickedUp => reason == 'not_picked_up';
  bool get isNotDispensed => reason == 'not_dispensed';

  DateTime? get resolvedAtDateTime => resolvedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(resolvedAt!)
      : null;

  DateTime? get dispensedAtDateTime => dispensedAt != null
      ? DateTime.fromMillisecondsSinceEpoch(dispensedAt!)
      : null;
}
