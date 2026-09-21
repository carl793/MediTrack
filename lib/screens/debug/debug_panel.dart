import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../state/meditrack_state.dart';
import '../../theme/app_theme.dart';

/// Debug panel — only visible in kDebugMode.
/// Access via long-press on the MediTrack header.
class DebugPanel extends StatelessWidget {
  const DebugPanel({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink();

    final state = context.read<MediTrackState>();
    final firebase = state.firebaseService;
    final config = state.medicationConfig;
    final slot = config?.alarmTimes.isNotEmpty == true
        ? config!.alarmTimes.first
        : '08:00';
    final medName = config?.name ?? 'Unknown';

    return Scaffold(
      backgroundColor: MediTrackColors.navy,
      appBar: AppBar(
        backgroundColor: MediTrackColors.navy,
        title: const Text(
          '⚠ Debug Panel',
          style: TextStyle(
            color: MediTrackColors.mint,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('SIMULATE ESP32'),
            _DebugButton(
              label: 'Simulate: Dispensing',
              color: MediTrackColors.amber,
              icon: Icons.output_rounded,
              onTap: () => firebase.debugSimulateDispensing(slot),
            ),
            _DebugButton(
              label: 'Simulate: Pill Taken',
              color: MediTrackColors.mint,
              icon: Icons.check_circle_rounded,
              onTap: () => firebase.debugSimulateTaken(slot, medName),
            ),
            _DebugButton(
              label: 'Simulate: Missed (Not Picked Up)',
              color: MediTrackColors.coral,
              icon: Icons.hourglass_empty_rounded,
              onTap: () =>
                  firebase.debugSimulateMissed(slot, medName, 'not_picked_up'),
            ),
            _DebugButton(
              label: 'Simulate: Missed (Not Dispensed)',
              color: MediTrackColors.coral,
              icon: Icons.notifications_off_rounded,
              onTap: () =>
                  firebase.debugSimulateMissed(slot, medName, 'not_dispensed'),
            ),
            const SizedBox(height: AppSpacing.md),
            _sectionLabel('DEVICE STATE'),
            _DebugButton(
              label: 'Set Device Online',
              color: MediTrackColors.mint,
              icon: Icons.wifi_rounded,
              onTap: () => firebase.debugSetDeviceOnline(),
            ),
            _DebugButton(
              label: 'Set Device Offline',
              color: MediTrackColors.coral,
              icon: Icons.wifi_off_rounded,
              onTap: () => firebase.debugSetDeviceOffline(),
            ),
            const SizedBox(height: AppSpacing.md),
            _sectionLabel('DANGER ZONE'),
            _DebugButton(
              label: 'Clear All Firebase Data',
              color: Colors.redAccent,
              icon: Icons.delete_forever_rounded,
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear all data?'),
                    content: const Text(
                        'This will delete all Firebase data permanently.'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Delete',
                              style: TextStyle(color: Colors.red))),
                    ],
                  ),
                );
                if (confirm == true) await firebase.debugClearAll();
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _sectionLabel('CURRENT STATE'),
            Consumer<MediTrackState>(
              builder: (_, s, __) => Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '''Dashboard State: ${s.dashboardState.name}
Medication: ${s.medicationConfig?.name ?? 'none'}
Stock: ${s.stockLevel}
Tray State: ${s.trayState.state}
Device Online: ${s.deviceConnection.isOnline}
History Events: ${s.history.length}
Weekly Adherence: ${(s.weeklyAdherence * 100).toStringAsFixed(0)}%''',
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: MediTrackColors.mint,
                    height: 1.6,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: MediTrackColors.mint,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _DebugButton extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final VoidCallback onTap;

  const _DebugButton({
    required this.label,
    required this.color,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () {
          onTap();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(label),
              duration: const Duration(seconds: 1),
              backgroundColor: color,
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 14),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
