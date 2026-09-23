import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Horizontal 5-day strip. Shows Mon–Fri (or the 5 days around today).
/// Today's card has navy fill; others are white cards.
class DayStrip extends StatelessWidget {
  /// Optional list of dates that have a "taken" dot (past adherence).
  final List<DateTime> takenDates;

  const DayStrip({super.key, this.takenDates = const []});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    // Show 2 days before today, today, 2 days after
    final days = List.generate(5, (i) => now.subtract(Duration(days: 2 - i)));

    return Row(
      children: days.asMap().entries.map((entry) {
        final i = entry.key;
        final day = entry.value;
        final isToday = _isSameDay(day, now);
        final isPast = day.isBefore(DateTime(now.year, now.month, now.day));
        final hasTaken = takenDates.any((d) => _isSameDay(d, day));

        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
            child: _DayCard(
              dayAbbrev: _dayAbbrev(day),
              dayNum: day.day.toString(),
              isToday: isToday,
              isPast: isPast,
              hasTaken: hasTaken,
            ),
          ),
        );
      }).toList(),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  String _dayAbbrev(DateTime d) {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return names[d.weekday - 1];
  }
}

class _DayCard extends StatelessWidget {
  final String dayAbbrev;
  final String dayNum;
  final bool isToday;
  final bool isPast;
  final bool hasTaken;

  const _DayCard({
    required this.dayAbbrev,
    required this.dayNum,
    required this.isToday,
    required this.isPast,
    required this.hasTaken,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = isPast
        ? (hasTaken ? MediTrackColors.dayDotPast : MediTrackColors.grayLight)
        : MediTrackColors.dayDotFuture;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isToday ? MediTrackColors.navy : MediTrackColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.dayCard),
        boxShadow: isToday ? [] : cardShadow,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isToday ? dayAbbrev.toUpperCase() : dayAbbrev,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              color: isToday ? MediTrackColors.white : MediTrackColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayNum,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isToday ? MediTrackColors.white : MediTrackColors.textPrimary,
            ),
          ),
          const SizedBox(height: 5),
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isToday ? Colors.white.withValues(alpha: 0.6) : dotColor,
            ),
          ),
        ],
      ),
    );
  }
}
