import 'package:flutter/material.dart';
import '../../../state/meditrack_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/info_card.dart';
import '../../../widgets/pill_button.dart';
import '../../../widgets/two_tone_capsule.dart';
import '../widgets/dashboard_header.dart';

class ResolvedMissedView extends StatelessWidget {
  final MediTrackState state;
  final VoidCallback onOkay;

  const ResolvedMissedView({
    super.key,
    required this.state,
    required this.onOkay,
  });

  @override
  Widget build(BuildContext context) {
    final config = state.medicationConfig!;
    final tray = state.trayState;

    // Find the missed event to determine reason
    final missedEvent = state.history.isNotEmpty ? state.history.first : null;
    final reason = missedEvent?.reason ?? 'not_dispensed';
    final isNotPickedUp = reason == 'not_picked_up';

    final reasonCopy = isNotPickedUp
        ? '15-minute pickup window expired (pill remained in tray)'
        : 'Dose window closed — dispense was never triggered';

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
                // Missed chip
                StatusChip(
                  label: isNotPickedUp ? 'PILL NOT PICKED UP' : 'DOSE MISSED',
                  backgroundColor: MediTrackColors.coral.withValues(alpha: 0.15),
                  textColor: MediTrackColors.coral,
                  icon: Icons.warning_amber_rounded,
                ),

                const SizedBox(height: AppSpacing.lg),

                // Missed card
                InfoCard(
                  backgroundColor: MediTrackColors.coral.withValues(alpha: 0.07),
                  border: Border.all(
                    color: MediTrackColors.coral.withValues(alpha: 0.4),
                    width: 1.5,
                  ),
                  child: Column(
                    children: [
                      // Capsule with X badge
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          CapsuleAvatar(
                            size: 80,
                            badge: Container(
                              width: 28,
                              height: 28,
                              decoration: const BoxDecoration(
                                color: MediTrackColors.coral,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.close_rounded,
                                  size: 16, color: Colors.white),
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

                      const SizedBox(height: 8),

                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: MediTrackColors.coral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isNotPickedUp
                                  ? Icons.hourglass_empty_rounded
                                  : Icons.notifications_off_rounded,
                              size: 16,
                              color: MediTrackColors.coral,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                reasonCopy,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: MediTrackColors.coral,
                                  fontWeight: FontWeight.w500,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (tray.resolvedAtDateTime != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Recorded at ${_formatTime(tray.resolvedAtDateTime!)}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: MediTrackColors.gray,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Supply unchanged note
                InfoCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MediTrackColors.lavenderDeep,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.medication_rounded,
                            color: MediTrackColors.navy, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Supply unchanged',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: MediTrackColors.navy,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isNotPickedUp
                                  ? 'Pill is still in the tray — retrieve it manually'
                                  : 'No pill was dispensed — count unchanged',
                              style: const TextStyle(
                                fontSize: 12,
                                color: MediTrackColors.gray,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        '${state.stockLevel}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: MediTrackColors.navy,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Adherence summary
                InfoCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MediTrackColors.coral.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.bar_chart_rounded,
                            color: MediTrackColors.coral, size: 20),
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: SizedBox(
                          width: 80,
                          height: 8,
                          child: LinearProgressIndicator(
                            value: state.weeklyAdherence,
                            backgroundColor: MediTrackColors.grayLight,
                            valueColor: AlwaysStoppedAnimation(
                              state.weeklyAdherence >= 0.8
                                  ? MediTrackColors.mint
                                  : MediTrackColors.coral,
                            ),
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
                  backgroundColor: MediTrackColors.navy,
                  textColor: Colors.white,
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
