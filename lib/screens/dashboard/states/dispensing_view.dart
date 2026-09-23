import 'package:flutter/material.dart';
import '../../../state/meditrack_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/info_card.dart';
import '../../../widgets/pill_button.dart';
import '../../../widgets/two_tone_capsule.dart';
import '../../../widgets/countdown_chip.dart';
import '../widgets/dashboard_header.dart';

class DispensingView extends StatelessWidget {
  final MediTrackState state;

  const DispensingView({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final config = state.medicationConfig!;
    final tray = state.trayState;
    final slot = tray.activeSlot ?? state.currentSlot?.slotTime ?? '—';

    // Compute pickup window end time
    DateTime? windowEnd;
    if (tray.dispensedAtDateTime != null) {
      windowEnd = tray.dispensedAtDateTime!
          .add(Duration(minutes: config.missedWindowMinutes));
    }

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
                // Status chip
                Row(
                  children: [
                    const StatusChip(
                      label: 'PILL IN TRAY',
                      backgroundColor: MediTrackColors.amber,
                      textColor: MediTrackColors.navy,
                      icon: Icons.circle,
                    ),
                    const Spacer(),
                    if (windowEnd != null)
                      CountdownChip(
                        targetTime: windowEnd,
                        backgroundColor: MediTrackColors.coral
                            .withValues(alpha: 0.15),
                        textColor: MediTrackColors.coral,
                        prefix: 'Pickup: ',
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Dispensing animation card
                InfoCard(
                  backgroundColor: MediTrackColors.lavender,
                  child: Column(
                    children: [
                      _SpinningCapsule(),
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
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color:
                              MediTrackColors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(
                                    MediTrackColors.navy),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Waiting for tray pickup…',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: MediTrackColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Active slot info
                InfoCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color:
                              MediTrackColors.amber.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.output_rounded,
                            color: MediTrackColors.navy, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Pill dispensed at',
                              style: TextStyle(
                                fontSize: 12,
                                color: MediTrackColors.gray,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              tray.dispensedAtDateTime != null
                                  ? _formatDateTime(
                                      tray.dispensedAtDateTime!)
                                  : 'Just now',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: MediTrackColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        'Slot: ${_formatTime(slot)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: MediTrackColors.gray,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Pickup window info
                InfoCard(
                  backgroundColor:
                      MediTrackColors.coral.withValues(alpha: 0.07),
                  border: Border.all(
                      color: MediTrackColors.coral.withValues(alpha: 0.25)),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: MediTrackColors.coral, size: 18),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Pick up your pill within ${config.missedWindowMinutes} minutes or the dose will be marked missed.',
                          style: const TextStyle(
                            fontSize: 13,
                            color: MediTrackColors.coral,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.lg),

                // Disabled dispense button
                const PillButton(
                  label: 'Waiting for tray pickup…',
                  enabled: false,
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
    if (hhmm == '—') return hhmm;
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $period';
  }

  String _formatDateTime(DateTime dt) {
    final h = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final m = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $period';
  }
}

class _SpinningCapsule extends StatefulWidget {
  @override
  State<_SpinningCapsule> createState() => _SpinningCapsuleState();
}

class _SpinningCapsuleState extends State<_SpinningCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 3))
      ..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: const CapsuleAvatar(size: 72),
    );
  }
}
