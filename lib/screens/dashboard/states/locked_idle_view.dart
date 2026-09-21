import 'package:flutter/material.dart';
import '../../../state/meditrack_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/info_card.dart';
import '../../../widgets/pill_button.dart';
import '../../../widgets/two_tone_capsule.dart';
import '../../../widgets/countdown_chip.dart';
import '../widgets/dashboard_header.dart';

class LockedIdleView extends StatelessWidget {
  final MediTrackState state;
  final VoidCallback onEditTap;

  const LockedIdleView({
    super.key,
    required this.state,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = state.medicationConfig!;
    final slot = state.currentSlot;
    final daysLeft = state.daysOfSupplyRemaining;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(onEditTap: onEditTap),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status row
                Row(
                  children: [
                    const StatusChip(
                      label: 'NEXT DOSE SCHEDULED',
                      backgroundColor: MediTrackColors.lavenderDeep,
                      textColor: MediTrackColors.navy,
                      icon: Icons.schedule_rounded,
                    ),
                    const Spacer(),
                    if (slot != null)
                      CountdownChip(
                        targetTime: slot.scheduledDateTime,
                        backgroundColor: MediTrackColors.navy,
                        textColor: Colors.white,
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Medication hero card
                InfoCard(
                  child: Row(
                    children: [
                      const CapsuleAvatar(size: 72),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              config.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: MediTrackColors.navy,
                                letterSpacing: -0.4,
                              ),
                            ),
                            if (config.dosageStrength.isNotEmpty) ...[
                              const SizedBox(height: 3),
                              Text(
                                config.dosageStrength,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: MediTrackColors.gray,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            if (config.unitForm.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                config.unitForm,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: MediTrackColors.gray,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Time card
                if (slot != null)
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
                          child: const Icon(Icons.schedule_rounded,
                              color: MediTrackColors.navy, size: 20),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                slot.doseLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: MediTrackColors.gray,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                _formatTime(slot.slotTime),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: MediTrackColors.navy,
                                  letterSpacing: -0.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const StatusChip(
                          label: 'UPCOMING',
                          backgroundColor: MediTrackColors.lavender,
                          textColor: MediTrackColors.gray,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // Supply row
                Row(
                  children: [
                    Expanded(
                      child: MiniStatCard(
                        label: 'Supply',
                        value: '${state.stockLevel}',
                        subtitle: 'pills remaining',
                        icon: Icons.medication_rounded,
                        accentColor: state.stockLevel <= 3
                            ? MediTrackColors.coral
                            : MediTrackColors.navy,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: MiniStatCard(
                        label: 'Days Left',
                        value: daysLeft < 1
                            ? '<1'
                            : daysLeft.toStringAsFixed(1),
                        subtitle: config.dosesPerDay > 1
                            ? '${config.dosesPerDay}× daily'
                            : 'once daily',
                        icon: Icons.calendar_today_rounded,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Locked dispense button
                PillButton(
                  label: slot != null
                      ? 'Dispense (Scheduled ${_formatTime(slot.slotTime)})'
                      : 'No Upcoming Dose',
                  enabled: false,
                  backgroundColor: MediTrackColors.grayLight,
                  textColor: MediTrackColors.grayMedium,
                ),

                const SizedBox(height: AppSpacing.md),

                // All doses today
                if (config.alarmTimes.length > 1)
                  _AllDosesToday(
                    alarmTimes: config.alarmTimes,
                    history: state.history,
                  ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String hhmm) {
    final parts = hhmm.split(':');
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $period';
  }
}

class _AllDosesToday extends StatelessWidget {
  final List<String> alarmTimes;
  final List history;

  const _AllDosesToday({required this.alarmTimes, required this.history});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStr =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    return InfoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'TODAY\'S DOSES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: MediTrackColors.gray,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...alarmTimes.map((t) {
            final resolved = history.any((e) =>
                e.scheduledFor == t && e.date == todayStr);
            final parts = t.split(':');
            final h = int.parse(parts[0]);
            final m = parts[1];
            final period = h >= 12 ? 'PM' : 'AM';
            final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
            return Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: resolved
                          ? MediTrackColors.mint
                          : MediTrackColors.grayLight,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '$h12:$m $period',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: resolved
                          ? MediTrackColors.gray
                          : MediTrackColors.navy,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    resolved ? 'Taken' : 'Pending',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: resolved
                          ? MediTrackColors.mintDark
                          : MediTrackColors.gray,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
