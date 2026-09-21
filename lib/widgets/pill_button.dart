import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool enabled;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final IconData? icon;

  const PillButton({
    super.key,
    required this.label,
    this.onTap,
    this.enabled = true,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = enabled && !isLoading && onTap != null;
    final bg = backgroundColor ??
        (isActive ? MediTrackColors.mint : MediTrackColors.grayLight);
    final fg = textColor ??
        (isActive ? MediTrackColors.navy : MediTrackColors.grayMedium);

    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.all(AppRadius.pill),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: MediTrackColors.mint.withValues(alpha: 0.35),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  )
                ]
              : [],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: fg,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class OutlinePillButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final Color? borderColor;
  final Color? textColor;
  final double? width;

  const OutlinePillButton({
    super.key,
    required this.label,
    this.onTap,
    this.borderColor,
    this.textColor,
    this.width,
  });

  @override
  Widget build(BuildContext context) {
    final bc = borderColor ?? MediTrackColors.navy;
    final tc = textColor ?? MediTrackColors.navy;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width ?? double.infinity,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: const BorderRadius.all(AppRadius.pill),
          border: Border.all(color: bc, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: tc,
              letterSpacing: -0.2,
            ),
          ),
        ),
      ),
    );
  }
}
