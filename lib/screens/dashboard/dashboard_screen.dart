import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/slot_state.dart';
import '../../state/meditrack_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/offline_banner.dart';
import 'states/not_configured_view.dart';
import 'states/locked_idle_view.dart';
import 'states/unlocked_idle_view.dart';
import 'states/dispensing_view.dart';
import 'states/resolved_taken_view.dart';
import 'states/resolved_missed_view.dart';
import 'states/course_completed_view.dart';
import '../history/history_screen.dart';
import '../wizard/wizard_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<MediTrackState>(
      builder: (context, state, _) {
        return Scaffold(
          backgroundColor: MediTrackColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // Offline banner
                if (!state.deviceConnection.isOnline &&
                    state.medicationConfig != null)
                  const OfflineBanner(),

                // Main content
                Expanded(
                  child: _buildBody(context, state),
                ),
              ],
            ),
          ),
          bottomNavigationBar: _BottomNav(
            onHistoryTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const HistoryScreen()),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MediTrackState state) {
    // Loading skeleton
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(MediTrackColors.mint),
          strokeWidth: 2,
        ),
      );
    }

    switch (state.dashboardState) {
      case DashboardState.notConfigured:
        return NotConfiguredView(
          onAddMedication: () => _openWizard(context, state),
        );

      case DashboardState.lockedIdle:
        return LockedIdleView(
          state: state,
          onEditTap: () => _openWizard(context, state),
        );

      case DashboardState.unlockedIdle:
        return UnlockedIdleView(
          state: state,
          onDispense: () {
            final slot = state.currentSlot;
            if (slot != null) state.triggerDispense(slot.slotTime);
          },
          onEditTap: () => _openWizard(context, state),
        );

      case DashboardState.dispensing:
        return DispensingView(state: state);

      case DashboardState.resolvedTaken:
        return ResolvedTakenView(
          state: state,
          onOkay: () => state.acknowledgeResolution(),
        );

      case DashboardState.resolvedMissed:
        return ResolvedMissedView(
          state: state,
          onOkay: () => state.acknowledgeResolution(),
        );

      case DashboardState.courseCompleted:
        return CourseCompletedView(
          state: state,
          onSetupNext: () => _openWizardBlank(context, state),
        );
    }
  }

  void _openWizard(BuildContext context, MediTrackState state) {
    if (state.trayState.isDispensing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot edit while a dose is being dispensed.'),
          backgroundColor: MediTrackColors.coral,
        ),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WizardScreen(
          existingConfig: state.medicationConfig,
          existingStock: state.stockLevel,
        ),
      ),
    );
  }

  void _openWizardBlank(BuildContext context, MediTrackState state) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WizardScreen(),
      ),
    );
  }
}

// ── Bottom Navigation ──────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final VoidCallback onHistoryTap;

  const _BottomNav({required this.onHistoryTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: MediTrackColors.grayLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.home_rounded,
            label: 'Home',
            isActive: true,
            onTap: () {},
          ),
          _NavItem(
            icon: Icons.history_rounded,
            label: 'History',
            isActive: false,
            onTap: onHistoryTap,
          ),
          // Profile icon — static, non-interactive per spec
          _NavItem(
            icon: Icons.person_rounded,
            label: 'Profile',
            isActive: false,
            onTap: () {}, // Non-interactive per spec §12
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 24,
              color: isActive ? MediTrackColors.navy : MediTrackColors.grayMedium,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                color: isActive ? MediTrackColors.navy : MediTrackColors.grayMedium,
              ),
            ),
            const SizedBox(height: 4),
            if (isActive)
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: MediTrackColors.mint,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
