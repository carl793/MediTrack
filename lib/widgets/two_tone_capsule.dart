import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class TwoToneCapsule extends StatelessWidget {
  final double size;
  final String? label;
  final Color topColor;
  final Color bottomColor;

  const TwoToneCapsule({
    super.key,
    this.size = 64,
    this.label,
    this.topColor = MediTrackColors.mint,
    this.bottomColor = MediTrackColors.coral,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size * 0.55,
      height: size,
      child: CustomPaint(
        painter: _CapsulePainter(topColor: topColor, bottomColor: bottomColor),
        child: label != null
            ? Center(
                child: Text(
                  label!,
                  style: TextStyle(
                    fontSize: size * 0.18,
                    fontWeight: FontWeight.w800,
                    color: MediTrackColors.navy,
                  ),
                ),
              )
            : null,
      ),
    );
  }
}

class _CapsulePainter extends CustomPainter {
  final Color topColor;
  final Color bottomColor;

  _CapsulePainter({required this.topColor, required this.bottomColor});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = w / 2;
    final mid = h / 2;

    // Top half (mint)
    final topPaint = Paint()..color = topColor;
    final topPath = Path()
      ..moveTo(0, mid)
      ..lineTo(0, r)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r), clockwise: false)
      ..lineTo(w, mid)
      ..close();
    canvas.drawPath(topPath, topPaint);

    // Bottom half (coral)
    final bottomPaint = Paint()..color = bottomColor;
    final bottomPath = Path()
      ..moveTo(0, mid)
      ..lineTo(0, h - r)
      ..arcToPoint(Offset(w, h - r),
          radius: Radius.circular(r), clockwise: true)
      ..lineTo(w, mid)
      ..close();
    canvas.drawPath(bottomPath, bottomPaint);

    // Divider line
    final linePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.6)
      ..strokeWidth = 1.5;
    canvas.drawLine(Offset(0, mid), Offset(w, mid), linePaint);

    // Outline
    final outlinePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    final outlinePath = Path()
      ..moveTo(0, r)
      ..arcToPoint(Offset(w, r), radius: Radius.circular(r), clockwise: false)
      ..lineTo(w, h - r)
      ..arcToPoint(Offset(0, h - r),
          radius: Radius.circular(r), clockwise: false)
      ..close();
    canvas.drawPath(outlinePath, outlinePaint);
  }

  @override
  bool shouldRepaint(_CapsulePainter old) =>
      old.topColor != topColor || old.bottomColor != bottomColor;
}

/// Larger capsule avatar with optional badge
class CapsuleAvatar extends StatelessWidget {
  final double size;
  final Widget? badge;
  final String? dosageLabel;

  const CapsuleAvatar({
    super.key,
    this.size = 80,
    this.badge,
    this.dosageLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: size + 24,
          height: size + 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: MediTrackColors.lavender,
          ),
        ),
        TwoToneCapsule(size: size, label: dosageLabel),
        if (badge != null)
          Positioned(
            bottom: 0,
            right: 0,
            child: badge!,
          ),
      ],
    );
  }
}
