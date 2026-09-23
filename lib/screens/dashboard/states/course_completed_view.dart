import 'package:flutter/material.dart';
import '../../../models/medication_config.dart';
import '../../../state/meditrack_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/info_card.dart';
import '../../../widgets/pill_button.dart';
import '../../../widgets/two_tone_capsule.dart';
import '../widgets/dashboard_header.dart';

class CourseCompletedView extends StatelessWidget {
  final MediTrackState state;
  final VoidCallback onSetupNext;

  const CourseCompletedView({
    super.key,
    required this.state,
    required this.onSetupNext,
  });

  @override
  Widget build(BuildContext context) {
    final config = state.medicationConfig!;
    final takenCount =
        state.history.where((e) => e.isTaken).length;
    final missedCount =
        state.history.where((e) => e.isMissed).length;
    final totalCount = takenCount + missedCount;
    final overallAdherence =
        totalCount > 0 ? takenCount / totalCount : 0.0;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Completion chip
                const StatusChip(
                  label: 'COURSE COMPLETE',
                  backgroundColor: MediTrackColors.mint,
                  textColor: MediTrackColors.navy,
                  icon: Icons.celebration_rounded,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Completion hero
                InfoCard(
                  backgroundColor: MediTrackColors.mint.withValues(alpha: 0.1),
                  border: Border.all(
                    color: MediTrackColors.mint.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          const CapsuleAvatar(size: 88),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: const BoxDecoration(
                                color: MediTrackColors.mint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  size: 18, color: MediTrackColors.navy),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'Course Completed!',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: MediTrackColors.navy,
                          letterSpacing: -0.6,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        config.courseType == CourseType.fixedDuration &&
                                config.durationDays != null
                            ? 'You completed your ${config.durationDays}-day ${config.name} course.'
                            : 'You completed your ${config.name} course.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: MediTrackColors.gray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Course summary stats
                Row(
                  children: [
                    Expanded(
                      child: MiniStatCard(
                        label: 'Doses Taken',
                        value: '$takenCount',
                        subtitle: 'of $totalCount total',
                        icon: Icons.check_circle_rounded,
                        accentColor: MediTrackColors.mintDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MiniStatCard(
                        label: 'Doses Missed',
                        value: '$missedCount',
                        subtitle: 'of $totalCount total',
                        icon: Icons.cancel_rounded,
                        accentColor: missedCount > 0
                            ? MediTrackColors.coral
                            : MediTrackColors.gray,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Adherence card
                InfoCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'OVERALL ADHERENCE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: MediTrackColors.gray,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(overallAdherence * 100).toStringAsFixed(0)}%',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: overallAdherence >= 0.8
                                  ? MediTrackColors.mintDark
                                  : MediTrackColors.coral,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: SizedBox(
                          height: 10,
                          child: LinearProgressIndicator(
                            value: overallAdherence,
                            backgroundColor: MediTrackColors.grayLight,
                            valueColor: AlwaysStoppedAnimation(
                              overallAdherence >= 0.8
                                  ? MediTrackColors.mint
                                  : MediTrackColors.coral,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      // Weekly breakdown dots
                      _WeeklyDots(history: state.history),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                PillButton(
                  label: 'Set Up Next Medication',
                  onTap: onSetupNext,
                  icon: Icons.add_rounded,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyDots extends StatelessWidget {
  final List history;

  const _WeeklyDots({required this.history});

  @override
  Widget build(BuildContext context) {
    const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
    final now = DateTime.now();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = now.subtract(Duration(days: 6 - i));
        final dayStr =
            '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
        final dayEvents = history.where((e) => e.date == dayStr).toList();
        final hasTaken = dayEvents.any((e) => e.isTaken);
        final hasMissed = dayEvents.any((e) => e.isMissed);

        Color dotColor;
        if (hasTaken && !hasMissed) {
          dotColor = MediTrackColors.mint;
        } else if (hasMissed) {
          dotColor = MediTrackColors.coral;
        } else {
          dotColor = MediTrackColors.grayLight;
        }

        return Column(
          children: [
            Text(
              labels[day.weekday - 1],
              style: const TextStyle(
                fontSize: 10,
                color: MediTrackColors.gray,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        );
      }),
    );
  }
}
