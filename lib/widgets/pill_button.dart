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
        (isActive ? MediTrackColors.navy : MediTrackColors.grayLight);
    final fg = textColor ??
        (isActive ? MediTrackColors.white : MediTrackColors.grayMedium);

    return GestureDetector(
      onTap: isActive ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: width ?? double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: isActive
              ? [
                  BoxShadow(
                    color: MediTrackColors.navy.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation(fg),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 18, color: fg),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: fg,
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
        height: 52,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(color: bc, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: tc,
            ),
          ),
        ),
      ),
    );
  }
}
