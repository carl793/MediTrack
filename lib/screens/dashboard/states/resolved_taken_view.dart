import 'package:flutter/material.dart';
import '../../../state/meditrack_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/info_card.dart';
import '../../../widgets/pill_button.dart';
import '../../../widgets/two_tone_capsule.dart';
import '../widgets/dashboard_header.dart';

class ResolvedTakenView extends StatelessWidget {
  final MediTrackState state;
  final VoidCallback onOkay;

  const ResolvedTakenView({
    super.key,
    required this.state,
    required this.onOkay,
  });

  @override
  Widget build(BuildContext context) {
    final config = state.medicationConfig!;
    final tray = state.trayState;
    final daysLeft = state.daysOfSupplyRemaining;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const DashboardHeader(showEdit: false),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success chip
                const StatusChip(
                  label: 'DOSE TAKEN ✓',
                  backgroundColor: MediTrackColors.mint,
                  textColor: MediTrackColors.navy,
                  icon: Icons.check_circle_rounded,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Success card
                InfoCard(
                  backgroundColor: MediTrackColors.mint.withValues(alpha: 0.12),
                  border: Border.all(
                      color: MediTrackColors.mint.withValues(alpha: 0.5),
                      width: 1.5),
                  child: Column(
                    children: [
                      // Capsule with green check badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const CapsuleAvatar(size: 80),
                          Positioned(
                            bottom: -4,
                            right: -4,
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: MediTrackColors.mint,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  size: 16, color: MediTrackColors.navy),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: AppSpacing.md),

                      Text(
                        config.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: MediTrackColors.navy,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      Text(
                        tray.resolvedAtDateTime != null
                            ? 'Taken at ${_formatTime(tray.resolvedAtDateTime!)} · On time'
                            : 'Dose taken successfully',
                        style: const TextStyle(
                          fontSize: 14,
                          color: MediTrackColors.gray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Updated supply
                Row(
                  children: [
                    Expanded(
                      child: MiniStatCard(
                        label: 'Remaining',
                        value: '${state.stockLevel}',
                        subtitle: 'pills in hopper',
                        icon: Icons.medication_rounded,
                        accentColor: state.stockLevel <= 3
                            ? MediTrackColors.coral
                            : MediTrackColors.mintDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MiniStatCard(
                        label: 'Days Left',
                        value: daysLeft < 1
                            ? '<1'
                            : daysLeft.toStringAsFixed(1),
                        subtitle: 'of supply',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.md),

                // Adherence mini summary
                InfoCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MediTrackColors.mint.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.trending_up_rounded,
                            color: MediTrackColors.navy, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '7-Day Adherence',
                              style: TextStyle(
                                fontSize: 12,
                                color: MediTrackColors.gray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${(state.weeklyAdherence * 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: MediTrackColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Adherence bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 80,
                          height: 8,
                          child: LinearProgressIndicator(
                            value: state.weeklyAdherence,
                            backgroundColor: MediTrackColors.grayLight,
                            valueColor: const AlwaysStoppedAnimation(
                                MediTrackColors.mint),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                PillButton(
                  label: 'Okay',
                  onTap: onOkay,
                  icon: Icons.check_rounded,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}
