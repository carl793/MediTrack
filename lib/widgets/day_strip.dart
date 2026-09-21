import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DayStrip extends StatelessWidget {
  const DayStrip({super.key});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final days = List.generate(7, (i) {
      final d = now.subtract(Duration(days: 3 - i));
      return d;
    });

    const dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: days.map((d) {
        final isToday = d.year == now.year &&
            d.month == now.month &&
            d.day == now.day;
        final dayName = dayNames[d.weekday - 1];
        return _DayCell(
          dayName: dayName,
          dayNum: d.day.toString(),
          isToday: isToday,
        );
      }).toList(),
    );
  }
}

class _DayCell extends StatelessWidget {
  final String dayName;
  final String dayNum;
  final bool isToday;

  const _DayCell({
    required this.dayName,
    required this.dayNum,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 38,
      height: 58,
      decoration: BoxDecoration(
        color: isToday ? MediTrackColors.navy : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            dayName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isToday
                  ? MediTrackColors.mint
                  : MediTrackColors.gray,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayNum,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isToday ? Colors.white : MediTrackColors.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
