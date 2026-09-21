import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/pill_button.dart';
import '../../../widgets/two_tone_capsule.dart';
import '../widgets/dashboard_header.dart';

class NotConfiguredView extends StatelessWidget {
  final VoidCallback onAddMedication;

  const NotConfiguredView({super.key, required this.onAddMedication});

  @override
  Widget build(BuildContext context) {
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
                // Status chips
                Row(
                  children: [
                    _buildChip('TRAY INACTIVE', MediTrackColors.grayLight,
                        MediTrackColors.gray),
                    const SizedBox(width: 8),
                    _buildChip(
                        'EMPTY BOX', MediTrackColors.lavenderDeep, MediTrackColors.navy),
                  ],
                ),

                const SizedBox(height: AppSpacing.xl),

                // Capsule illustration
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 110,
                        height: 110,
                        decoration: const BoxDecoration(
                          color: MediTrackColors.lavender,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: TwoToneCapsule(size: 64),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      const Text(
                        'No Medication\nScheduled',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: MediTrackColors.navy,
                          letterSpacing: -0.6,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      const Text(
                        'Set up your medication to get\nhardware-verified dose tracking.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: MediTrackColors.gray,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: AppSpacing.xl),

                PillButton(
                  label: 'Add Medication',
                  onTap: onAddMedication,
                  icon: Icons.add_rounded,
                ),

                const SizedBox(height: AppSpacing.xl),

                // How it works
                const Text(
                  'HOW IT WORKS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: MediTrackColors.gray,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                const _HowItWorksStep(
                  number: '1',
                  title: 'Set up your medication',
                  description: 'Configure dose schedule and fill the hopper',
                  color: MediTrackColors.mint,
                ),
                const SizedBox(height: AppSpacing.sm),
                const _HowItWorksStep(
                  number: '2',
                  title: 'Tap to dispense',
                  description: 'When it\'s time, tap the dispense button',
                  color: MediTrackColors.navy,
                ),
                const SizedBox(height: AppSpacing.sm),
                const _HowItWorksStep(
                  number: '3',
                  title: 'Hardware confirms pickup',
                  description: 'Load cell verifies you took the pill',
                  color: MediTrackColors.coral,
                ),

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip(String label, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: fg,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _HowItWorksStep extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final Color color;

  const _HowItWorksStep({
    required this.number,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: MediTrackColors.lavender,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: MediTrackColors.navy,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 12,
                    color: MediTrackColors.gray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
