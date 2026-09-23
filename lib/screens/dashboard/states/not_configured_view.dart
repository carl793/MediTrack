import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../../widgets/day_strip.dart';
import '../widgets/dashboard_header.dart';

class NotConfiguredView extends StatelessWidget {
  final VoidCallback onAddMedication;
  final bool isConnected;

  const NotConfiguredView({
    super.key,
    required this.onAddMedication,
    this.isConnected = false,
  });

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── 1. Header ───────────────────────────────────────────────────
          DashboardHeader(isConnected: isConnected),

          // ── 2. Greeting section ─────────────────────────────────────────
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
                        'Take a moment to set up your routine',
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

          // ── 3. Day strip ────────────────────────────────────────────────
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: DayStrip(),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── 4. Empty-state hero card ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: MediTrackColors.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.card),
                boxShadow: cardShadow,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Row 1: status chips
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left chip: tray inactive
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFF666D73),
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'TRAY INACTIVE',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                              color: MediTrackColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      // Right chip: empty box
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: MediTrackColors.lavenderChip,
                          borderRadius: BorderRadius.circular(AppRadius.chip),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.inbox_rounded,
                                size: 14, color: MediTrackColors.navy),
                            SizedBox(width: 4),
                            Text(
                              'Empty Box',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: MediTrackColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Row 2: illustration
                  _PillBottleIllustration(),

                  const SizedBox(height: 20),

                  // Row 3: copy
                  const Text(
                    'No Medication Scheduled',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                      color: MediTrackColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add your medication to start receiving timely reminders and automatic dispensing from your smart box.',
                    style: TextStyle(
                      fontSize: 14,
                      color: MediTrackColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 20),

                  // Row 4: Add Medication button
                  GestureDetector(
                    onTap: onAddMedication,
                    child: Container(
                      width: double.infinity,
                      height: 52,
                      decoration: BoxDecoration(
                        color: MediTrackColors.navy,
                        borderRadius:
                            BorderRadius.circular(AppRadius.button),
                      ),
                      child: const Center(
                        child: Text(
                          'Add Medication',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: MediTrackColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── 5. How it works section ──────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline_rounded,
                    size: 18, color: MediTrackColors.navy),
                const SizedBox(width: 8),
                const Text(
                  'How it works',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: MediTrackColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: MediTrackColors.lavenderChip,
                    borderRadius: BorderRadius.circular(AppRadius.chip),
                  ),
                  child: const Text(
                    '3 Steps',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: MediTrackColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          // Swipeable step cards
          const _HowItWorksCarousel(),
        ],
      ),
    );
  }
}

// ── Pill bottle illustration ──────────────────────────────────────────────

class _PillBottleIllustration extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer halo
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: MediTrackColors.paleBlue.withValues(alpha: 0.5),
            ),
          ),
          // Inner white circle with bottle icon
          Container(
            width: 70,
            height: 70,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: MediTrackColors.cardBg,
            ),
            child: const Center(
              child: _PillBottleIcon(size: 32),
            ),
          ),
          // FAB badge bottom-right
          Positioned(
            bottom: 8,
            right: MediaQuery.of(context).size.width / 2 - 68,
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: MediTrackColors.navy,
              ),
              child: const Icon(
                Icons.add_rounded,
                size: 20,
                color: MediTrackColors.white,
              ),
            ),
          ),
          // Sparkle dots
          Positioned(
            top: 18,
            left: MediaQuery.of(context).size.width / 2 - 68,
            child: Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: MediTrackColors.mint,
              ),
            ),
          ),
          Positioned(
            top: 14,
            right: MediaQuery.of(context).size.width / 2 - 72,
            child: Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: MediTrackColors.amber.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PillBottleIcon extends StatelessWidget {
  final double size;
  const _PillBottleIcon({required this.size});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.7, size),
      painter: _BottlePainter(),
    );
  }
}

class _BottlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF136692)
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Lid (rounded rect top)
    final lidRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, 0, w * 0.7, h * 0.22),
      const Radius.circular(4),
    );
    canvas.drawRRect(lidRect, paint);

    // Body (rounded rect bottom)
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, h * 0.26, w, h * 0.74),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, paint);

    // Cross / plus on body
    final crossPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round;
    final cx = w / 2;
    final cy = h * 0.63;
    final arm = w * 0.2;
    canvas.drawLine(
        Offset(cx - arm, cy), Offset(cx + arm, cy), crossPaint);
    canvas.drawLine(
        Offset(cx, cy - arm), Offset(cx, cy + arm), crossPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── How It Works carousel ─────────────────────────────────────────────────

class _HowItWorksCarousel extends StatefulWidget {
  const _HowItWorksCarousel();

  @override
  State<_HowItWorksCarousel> createState() => _HowItWorksCarouselState();
}

class _HowItWorksCarouselState extends State<_HowItWorksCarousel> {
  final _controller = PageController(viewportFraction: 0.85);
  int _page = 0;

  static const _steps = [
    (
      number: '1',
      icon: Icons.medication_rounded,
      title: 'Place pills inside',
      body:
          'Fill the smart compartments with your daily tablets or capsules.',
      stepLabel: 'Step 1 of 3',
    ),
    (
      number: '2',
      icon: Icons.schedule_rounded,
      title: 'Choose your schedule',
      body:
          'Pick morning, afternoon, or evening doses with effortless precision.',
      stepLabel: 'Step 2 of 3',
    ),
    (
      number: '3',
      icon: Icons.verified_rounded,
      title: 'Track every dose',
      body:
          'Hardware-verified pickup confirms each dose was actually taken.',
      stepLabel: 'Step 3 of 3',
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 170,
          child: PageView.builder(
            controller: _controller,
            itemCount: _steps.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, i) {
              final step = _steps[i];
              return Padding(
                padding: EdgeInsets.only(
                  left: i == 0 ? AppSpacing.md : 6,
                  right: i == _steps.length - 1 ? AppSpacing.md : 6,
                ),
                child: _StepCard(
                  number: step.number,
                  icon: step.icon,
                  title: step.title,
                  body: step.body,
                  stepLabel: step.stepLabel,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Pagination dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_steps.length, (i) {
            final isActive = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: isActive ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: isActive
                    ? MediTrackColors.navy
                    : MediTrackColors.lavenderChip,
                borderRadius: BorderRadius.circular(99),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String body;
  final String stepLabel;

  const _StepCard({
    required this.number,
    required this.icon,
    required this.title,
    required this.body,
    required this.stepLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MediTrackColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: cardShadow,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Numbered circle
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: MediTrackColors.paleBlueBadge,
                ),
                child: Center(
                  child: Text(
                    number,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: MediTrackColors.navy,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Icon(icon, size: 18, color: MediTrackColors.navy),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: MediTrackColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: const TextStyle(
              fontSize: 13,
              color: MediTrackColors.textMuted,
              height: 1.45,
            ),
          ),
          const Spacer(),
          Text(
            stepLabel,
            style: const TextStyle(
              fontSize: 12,
              color: MediTrackColors.navy,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
