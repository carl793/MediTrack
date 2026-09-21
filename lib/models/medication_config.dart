import 'package:flutter/foundation.dart';

enum CourseType { ongoing, fixedDuration }

@immutable
class MedicationConfig {
  final String name;
  final String dosageStrength;
  final String unitForm;
  final String purpose;
  final List<String> alarmTimes; // ["08:00", "14:00", "20:00"]
  final CourseType courseType;
  final String? startDate; // "YYYY-MM-DD"
  final int? durationDays;
  final List<String>? activeDays; // ["Mon","Tue",...]
  final int missedWindowMinutes;

  const MedicationConfig({
    required this.name,
    required this.dosageStrength,
    this.unitForm = '1 tablet',
    this.purpose = '',
    required this.alarmTimes,
    required this.courseType,
    this.startDate,
    this.durationDays,
    this.activeDays,
    this.missedWindowMinutes = 15,
  });

  factory MedicationConfig.fromJson(Map<dynamic, dynamic> json) {
    final rawAlarms = json['alarmTimes'];
    List<String> alarms = [];
    if (rawAlarms is List) {
      alarms = rawAlarms.map((e) => e.toString()).toList();
    } else if (rawAlarms is Map) {
      alarms = rawAlarms.values.map((e) => e.toString()).toList();
    }
    alarms.sort();

    final rawActive = json['activeDays'];
    List<String>? activeDays;
    if (rawActive is List) {
      activeDays = rawActive.map((e) => e.toString()).toList();
    } else if (rawActive is Map) {
      activeDays = rawActive.values.map((e) => e.toString()).toList();
    }

    return MedicationConfig(
      name: (json['name'] ?? '').toString(),
      dosageStrength: (json['dosageStrength'] ?? '').toString(),
      unitForm: (json['unitForm'] ?? '1 tablet').toString(),
      purpose: (json['purpose'] ?? '').toString(),
      alarmTimes: alarms,
      courseType: (json['courseType'] ?? 'ongoing').toString() == 'fixedDuration'
          ? CourseType.fixedDuration
          : CourseType.ongoing,
      startDate: json['startDate']?.toString(),
      durationDays: json['durationDays'] != null
          ? int.tryParse(json['durationDays'].toString())
          : null,
      activeDays: activeDays,
      missedWindowMinutes: int.tryParse(
              (json['missedWindowMinutes'] ?? 15).toString()) ??
          15,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosageStrength': dosageStrength,
      'unitForm': unitForm,
      'purpose': purpose,
      'alarmTimes': alarmTimes,
      'courseType': courseType == CourseType.fixedDuration
          ? 'fixedDuration'
          : 'ongoing',
      'startDate': startDate ?? _todayString(),
      'durationDays': durationDays,
      'activeDays': activeDays ??
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
      'missedWindowMinutes': missedWindowMinutes,
    };
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  MedicationConfig copyWith({
    String? name,
    String? dosageStrength,
    String? unitForm,
    String? purpose,
    List<String>? alarmTimes,
    CourseType? courseType,
    String? startDate,
    int? durationDays,
    List<String>? activeDays,
    int? missedWindowMinutes,
  }) {
    return MedicationConfig(
      name: name ?? this.name,
      dosageStrength: dosageStrength ?? this.dosageStrength,
      unitForm: unitForm ?? this.unitForm,
      purpose: purpose ?? this.purpose,
      alarmTimes: alarmTimes ?? this.alarmTimes,
      courseType: courseType ?? this.courseType,
      startDate: startDate ?? this.startDate,
      durationDays: durationDays ?? this.durationDays,
      activeDays: activeDays ?? this.activeDays,
      missedWindowMinutes: missedWindowMinutes ?? this.missedWindowMinutes,
    );
  }

  /// Returns DateTime of course end (exclusive — day after last dose day)
  DateTime? get courseEndDate {
    if (courseType != CourseType.fixedDuration || durationDays == null || startDate == null) {
      return null;
    }
    final parts = startDate!.split('-');
    if (parts.length != 3) return null;
    final start = DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
    return start.add(Duration(days: durationDays!));
  }

  bool isCourseCompleted(DateTime now) {
    if (courseType != CourseType.fixedDuration) return false;
    final end = courseEndDate;
    if (end == null) return false;
    final today = DateTime(now.year, now.month, now.day);
    return today.isAfter(end.subtract(const Duration(days: 1)));
  }

  bool isActiveDay(DateTime date) {
    if (courseType == CourseType.fixedDuration) return true;
    final days = activeDays ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const weekdayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = weekdayNames[date.weekday - 1];
    return days.contains(dayName);
  }

  int get dosesPerDay => alarmTimes.length;

  double get daysRemaining {
    // stock is managed separately; this just returns duration info
    if (courseType == CourseType.fixedDuration && durationDays != null) {
      return durationDays!.toDouble();
    }
    return 0;
  }
}
