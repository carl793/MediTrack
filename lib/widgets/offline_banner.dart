import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      color: MediTrackColors.amber.withValues(alpha: 0.15),
      child: Row(
        children: [
          const Icon(Icons.wifi_off_rounded,
              size: 16, color: MediTrackColors.darkGray),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Device offline — dispense disabled',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: MediTrackColors.darkGray,
              ),
            ),
          ),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: MediTrackColors.coral,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
