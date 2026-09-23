import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../debug/debug_panel.dart';

class DashboardHeader extends StatelessWidget {
  final bool isConnected;
  final VoidCallback? onEditTap;

  const DashboardHeader({
    super.key,
    this.isConnected = false,
    this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onLongPress: kDebugMode
                  ? () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const DebugPanel()))
                  : null,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'MediTrack',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: MediTrackColors.textPrimary,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected
                              ? MediTrackColors.emerald
                              : MediTrackColors.grayMedium,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'Connected to Pill Box' : 'Not connected',
                        style: const TextStyle(
                          fontSize: 13,
                          color: MediTrackColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Edit button — shown only when onEditTap provided
          if (onEditTap != null) ...[
            GestureDetector(
              onTap: onEditTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: MediTrackColors.lavenderChip,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.edit_rounded,
                  size: 18,
                  color: MediTrackColors.navy,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Avatar
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: MediTrackColors.navy,
            ),
            child: const Icon(
              Icons.person_rounded,
              size: 20,
              color: MediTrackColors.white,
            ),
          ),
        ],
      ),
    );
  }
}
