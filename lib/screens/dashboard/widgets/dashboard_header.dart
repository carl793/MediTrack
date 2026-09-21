import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/day_strip.dart';
import '../../debug/debug_panel.dart';

class DashboardHeader extends StatelessWidget {
  final VoidCallback? onEditTap;
  final bool showEdit;

  const DashboardHeader({
    super.key,
    this.onEditTap,
    this.showEdit = true,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Long-press title to open debug panel in debug builds
              GestureDetector(
                onLongPress: kDebugMode
                    ? () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const DebugPanel(),
                          ),
                        )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _greeting(),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: MediTrackColors.gray,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Text(
                          'MediTrack',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: MediTrackColors.navy,
                            letterSpacing: -0.6,
                          ),
                        ),
                        if (kDebugMode) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: MediTrackColors.amber.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'DEV',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: MediTrackColors.navy,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  if (showEdit && onEditTap != null)
                    GestureDetector(
                      onTap: onEditTap,
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: MediTrackColors.lavender,
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
                  // Profile icon — non-interactive per spec §12
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: MediTrackColors.navy,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          const DayStrip(),
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}
