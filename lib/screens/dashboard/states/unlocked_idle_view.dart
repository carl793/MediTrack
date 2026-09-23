import 'package:flutter/material.dart';
import '../../../state/meditrack_state.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/countdown_chip.dart';
import '../../../widgets/day_strip.dart';
import '../../../widgets/info_card.dart';
import '../../../widgets/pill_button.dart';
import '../../../widgets/two_tone_capsule.dart';
import '../widgets/dashboard_header.dart';

class UnlockedIdleView extends StatelessWidget {
  final MediTrackState state;
  final VoidCallback onDispense;
  final VoidCallback onEditTap;

  const UnlockedIdleView({
    super.key,
    required this.state,
    required this.onDispense,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    final config = state.medicationConfig!;
    final slot = state.currentSlot;

    // Dispense button is always enabled in app-only mode (no ESP32 connected yet)
    // Once ESP32 connects, dispense is blocked only when it goes offline
    final espHasEverConnected = state.deviceConnection.lastSeen != null;
    final isKnownOffline = espHasEverConnected && !state.deviceConnection.isOnline;
    // Allow dispense if: (1) ESP32 never connected (app-only mode), OR (2) ESP32 is online
    final canDispense = !espHasEverConnected || !isKnownOffline;
    final hasStock = state.stockLevel > 0;
    final daysLeft = state.daysOfSupplyRemaining;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DashboardHeader(isConnected: state.deviceConnection.isOnline, onEditTap: onEditTap),

          // Greeting section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Eyebrow
                      const Text(
                        "TODAY'S REGIMEN",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.88,
                          color: MediTrackColors.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Headline
                      Text(
                        _greeting(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: MediTrackColors.textPrimary,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Your medication is ready to dispense',
                        style: TextStyle(
                          fontSize: 14,
                          color: MediTrackColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                // Sun badge
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: MediTrackColors.lavenderLight,
                  ),
                  child: const Icon(
                    Icons.wb_sunny_rounded,
                    size: 20,
                    color: MediTrackColors.amber,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Day strip
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: DayStrip(),
          ),

          const SizedBox(height: AppSpacing.md),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status chip row with window-close countdown
                Row(
                  children: [
                    const StatusChip(
                      label: 'READY TO DISPENSE',
                      backgroundColor: MediTrackColors.mint,
                      textColor: MediTrackColors.navy,
                      icon: Icons.check_circle_rounded,
                    ),
                    const Spacer(),
                    // Countdown to when this dose window closes (marks missed)
                    if (slot != null)
                      CountdownChip(
                        targetTime: slot.windowCloseTime,
                        backgroundColor:
                            MediTrackColors.coral.withValues(alpha: 0.12),
                        textColor: MediTrackColors.coral,
                        prefix: 'Closes: ',
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.lg),

                // Hero card with capsule + pulse animation
                InfoCard(
                  backgroundColor: MediTrackColors.lavender,
                  child: Column(
                    children: [
                      // Capsule + pulsing ring
                      const _PulsingCapsule(size: 88),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        config.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: MediTrackColors.navy,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (config.dosageStrength.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          config.dosageStrength,
                          style: const TextStyle(
                            fontSize: 14,
                            color: MediTrackColors.gray,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.md),

                // Dose time card
                if (slot != null)
                  InfoCard(
                    border: Border.all(
                        color: MediTrackColors.mint.withValues(alpha: 0.6),
                        width: 1.5),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: MediTrackColors.mint.withValues(alpha: 0.2),
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
                              Text(
                                slot.doseLabel,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: MediTrackColors.gray,
                                  letterSpacing: 0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${_formatTime(slot.slotTime)} · Ready now',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: MediTrackColors.navy,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Window closes at ${_formatTime(
                                  '${slot.windowCloseTime.hour.toString().padLeft(2, '0')}:${slot.windowCloseTime.minute.toString().padLeft(2, '0')}',
                                )}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: MediTrackColors.gray,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const StatusChip(
                          label: 'DUE',
                          backgroundColor: MediTrackColors.mint,
                          textColor: MediTrackColors.navy,
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: AppSpacing.md),

                // Supply card
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

                // Stock warning (advisory only — does not block dispense)
                if (!hasStock)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: InfoCard(
                      backgroundColor:
                          MediTrackColors.coral.withValues(alpha: 0.1),
                      border: Border.all(
                          color: MediTrackColors.coral.withValues(alpha: 0.4)),
                      child: const Row(
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: MediTrackColors.coral, size: 20),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Out of stock — refill hopper and update inventory',
                              style: TextStyle(
                                fontSize: 13,
                                color: MediTrackColors.coral,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Dispense button
                PillButton(
                  label: 'Dispense Now',
                  onTap: canDispense ? onDispense : null,
                  enabled: canDispense,
                  icon: Icons.play_circle_rounded,
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }
}

class _PulsingCapsule extends StatefulWidget {
  final double size;
  const _PulsingCapsule({required this.size});

  @override
  State<_PulsingCapsule> createState() => _PulsingCapsuleState();
}

class _PulsingCapsuleState extends State<_PulsingCapsule>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
    _scale = Tween(begin: 1.0, end: 1.5).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _opacity = Tween(begin: 0.4, end: 0.0).animate(
        CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size + 40,
      height: widget.size + 40,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Pulse ring
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Transform.scale(
              scale: _scale.value,
              child: Opacity(
                opacity: _opacity.value,
                child: Container(
                  width: widget.size + 20,
                  height: widget.size + 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: MediTrackColors.mint.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ),
          // Capsule
          Container(
            width: widget.size + 8,
            height: widget.size + 8,
            decoration: const BoxDecoration(
              color: MediTrackColors.white,
              shape: BoxShape.circle,
            ),
            child: Center(child: CapsuleAvatar(size: widget.size)),
          ),
        ],
      ),
    );
  }
}
