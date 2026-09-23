import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

enum NavTab { home, history }

class BottomNav extends StatelessWidget {
  final NavTab activeTab;
  final VoidCallback onHomeTap;
  final VoidCallback onHistoryTap;

  const BottomNav({
    super.key,
    required this.activeTab,
    required this.onHomeTap,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: const BoxDecoration(
        color: MediTrackColors.pageBg,
        border: Border(
          top: BorderSide(color: MediTrackColors.divider, width: 1),
        ),
      ),
      child: Row(
        children: [
          _NavItem(
            icon: Icons.medication_rounded,
            label: 'Home',
            isActive: activeTab == NavTab.home,
            onTap: onHomeTap,
          ),
          _NavItem(
            icon: Icons.calendar_today_outlined,
            label: 'History',
            isActive: activeTab == NavTab.history,
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
    final color = isActive ? MediTrackColors.navy : MediTrackColors.textSecondary;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight:
                    isActive ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
