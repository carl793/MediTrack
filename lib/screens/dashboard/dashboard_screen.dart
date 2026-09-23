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
                // Offline banner — only show when ESP32 is KNOWN offline
                // (not when it simply hasn't connected yet / pre-hardware)
                if (state.medicationConfig != null &&
                    state.deviceConnection.lastSeen != null &&
                    !state.deviceConnection.isOnline)
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
          isConnected: state.deviceConnection.isOnline,
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
      height: 68,
      decoration: BoxDecoration(
        color: MediTrackColors.pageBg,
        border: Border(
          top: BorderSide(
            color: MediTrackColors.grayLight.withValues(alpha: 0.8),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // Home — active
          _NavItem(
            icon: Icons.medication_rounded,
            label: 'Home',
            isActive: true,
            onTap: () {},
          ),
          // History — inactive
          _NavItem(
            icon: Icons.calendar_today_rounded,
            label: 'History',
            isActive: false,
            onTap: onHistoryTap,
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
              size: 22,
              color: isActive
                  ? MediTrackColors.navy
                  : MediTrackColors.textSecondary,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: isActive
                    ? MediTrackColors.navy
                    : MediTrackColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
