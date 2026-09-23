import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppHeader extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onDebugLongPress;

  const AppHeader({
    super.key,
    this.isConnected = true,
    this.onDebugLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left: title + connection status
            Expanded(
              child: GestureDetector(
                onLongPress: onDebugLongPress,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'MediTrack',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                        color: MediTrackColors.textPrimary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isConnected
                                ? MediTrackColors.emerald
                                : MediTrackColors.coral,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isConnected
                              ? 'Connected to Pill Box'
                              : 'Disconnected',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: MediTrackColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Right: navy avatar circle with person icon
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: MediTrackColors.navy,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_rounded,
                size: 18,
                color: MediTrackColors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
