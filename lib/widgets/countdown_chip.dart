import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CountdownChip extends StatefulWidget {
  final DateTime targetTime;
  final Color backgroundColor;
  final Color textColor;
  final String prefix;

  const CountdownChip({
    super.key,
    required this.targetTime,
    this.backgroundColor = MediTrackColors.navy,
    this.textColor = Colors.white,
    this.prefix = '',
  });

  @override
  State<CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<CountdownChip> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _update();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _update());
  }

  void _update() {
    final remaining = widget.targetTime.difference(DateTime.now());
    if (mounted) {
      setState(() => _remaining = remaining.isNegative ? Duration.zero : remaining);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _format(Duration d) {
    if (d.inHours >= 1) {
      final h = d.inHours;
      final m = d.inMinutes.remainder(60);
      return '${h}h ${m.toString().padLeft(2, '0')}m';
    }
    final m = d.inMinutes;
    final s = d.inSeconds.remainder(60);
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: widget.backgroundColor,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.schedule_rounded, size: 13, color: widget.textColor),
          const SizedBox(width: 5),
          Text(
            '${widget.prefix}${_format(_remaining)}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: widget.textColor,
              fontFamily: 'monospace',
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
