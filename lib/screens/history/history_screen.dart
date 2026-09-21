import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/history_event.dart';
import '../../state/meditrack_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/info_card.dart';

enum _HistoryFilter { all, taken, missed }
enum _DateRange { sevenDays, thirtyDays, allTime }

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  _HistoryFilter _filter = _HistoryFilter.all;
  _DateRange _range = _DateRange.sevenDays;

  List<HistoryEvent> _applyFilters(List<HistoryEvent> events) {
    var filtered = List<HistoryEvent>.from(events);

    // Date range
    if (_range != _DateRange.allTime) {
      final cutoff = DateTime.now().subtract(
        Duration(days: _range == _DateRange.sevenDays ? 7 : 30),
      );
      filtered = filtered
          .where((e) =>
              e.resolvedAtDateTime != null &&
              e.resolvedAtDateTime!.isAfter(cutoff))
          .toList();
    }

    // Type filter
    switch (_filter) {
      case _HistoryFilter.taken:
        filtered = filtered.where((e) => e.isTaken).toList();
        break;
      case _HistoryFilter.missed:
        filtered = filtered.where((e) => e.isMissed).toList();
        break;
      case _HistoryFilter.all:
        break;
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MediTrackState>(
      builder: (context, state, _) {
        final filtered = _applyFilters(state.history);
        final adherence = state.weeklyAdherence;

        return Scaffold(
          backgroundColor: MediTrackColors.surface,
          body: SafeArea(
            child: Column(
              children: [
                // App bar
                Padding(
                  padding: const EdgeInsets.fromLTRB(4, 8, 16, 0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: MediTrackColors.navy),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Text(
                        'Medication History',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: MediTrackColors.navy,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Weekly adherence summary card
                        _WeeklySummaryCard(
                          adherence: adherence,
                          history: state.history,
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // Segmented filter
                        _SegmentedFilter(
                          selected: _filter,
                          onChanged: (f) => setState(() => _filter = f),
                        ),

                        const SizedBox(height: AppSpacing.sm),

                        // Date range selector
                        _DateRangeSelector(
                          selected: _range,
                          onChanged: (r) => setState(() => _range = r),
                        ),

                        const SizedBox(height: AppSpacing.md),

                        // History list
                        if (filtered.isEmpty)
                          _EmptyState(filter: _filter)
                        else
                          ...filtered.map((e) => Padding(
                                padding:
                                    const EdgeInsets.only(bottom: AppSpacing.sm),
                                child: _HistoryTile(event: e),
                              )),

                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Weekly Summary Card ────────────────────────────────────────────────────

class _WeeklySummaryCard extends StatelessWidget {
  final double adherence;
  final List<HistoryEvent> history;

  const _WeeklySummaryCard({
    required this.adherence,
    required this.history,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return InfoCard(
      backgroundColor: MediTrackColors.navy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'WEEKLY ADHERENCE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: MediTrackColors.mint,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${(adherence * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    Text(
                      adherence >= 0.9
                          ? 'Excellent adherence 🎉'
                          : adherence >= 0.7
                              ? 'Good — keep it up'
                              : 'Needs improvement',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Circular adherence indicator
              SizedBox(
                width: 72,
                height: 72,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: adherence,
                      backgroundColor:
                          Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(
                          MediTrackColors.mint),
                      strokeWidth: 6,
                    ),
                    Text(
                      '${(adherence * 100).toInt()}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // Day dots row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final day = now.subtract(Duration(days: 6 - i));
              final dayStr =
                  '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}';
              final dayEvents =
                  history.where((e) => e.date == dayStr).toList();
              final hasTaken = dayEvents.any((e) => e.isTaken);
              final hasMissed = dayEvents.any((e) => e.isMissed);
              final isToday = day.year == now.year &&
                  day.month == now.month &&
                  day.day == now.day;

              return Column(
                children: [
                  Text(
                    dayLabels[day.weekday - 1].substring(0, 1),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withValues(alpha: 0.5),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: hasTaken && !hasMissed
                          ? MediTrackColors.mint
                          : hasMissed
                              ? MediTrackColors.coral
                              : Colors.white.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: Colors.white.withValues(alpha: 0.5),
                              width: 1.5)
                          : null,
                    ),
                    child: Center(
                      child: hasTaken && !hasMissed
                          ? const Icon(Icons.check_rounded,
                              size: 14, color: MediTrackColors.navy)
                          : hasMissed
                              ? const Icon(Icons.close_rounded,
                                  size: 14, color: Colors.white)
                              : Text(
                                  day.day.toString(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color:
                                        Colors.white.withValues(alpha: 0.5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ── Segmented Filter ───────────────────────────────────────────────────────

class _SegmentedFilter extends StatelessWidget {
  final _HistoryFilter selected;
  final ValueChanged<_HistoryFilter> onChanged;

  const _SegmentedFilter({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: MediTrackColors.lavender,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: _HistoryFilter.values.map((f) {
          final isSelected = f == selected;
          final label = f == _HistoryFilter.all
              ? 'All'
              : f == _HistoryFilter.taken
                  ? 'Taken'
                  : 'Missed';
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(9),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w700
                          : FontWeight.w500,
                      color: isSelected
                          ? MediTrackColors.navy
                          : MediTrackColors.gray,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Date Range Selector ────────────────────────────────────────────────────

class _DateRangeSelector extends StatelessWidget {
  final _DateRange selected;
  final ValueChanged<_DateRange> onChanged;

  const _DateRangeSelector({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = {
      _DateRange.sevenDays: '7 Days',
      _DateRange.thirtyDays: '30 Days',
      _DateRange.allTime: 'All Time',
    };

    return Row(
      children: options.entries.map((entry) {
        final isSelected = entry.key == selected;
        return Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onChanged(entry.key),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              decoration: BoxDecoration(
                color: isSelected
                    ? MediTrackColors.navy
                    : MediTrackColors.lavender,
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                entry.value,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : MediTrackColors.gray,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ── History Tile ───────────────────────────────────────────────────────────

class _HistoryTile extends StatelessWidget {
  final HistoryEvent event;

  const _HistoryTile({required this.event});

  @override
  Widget build(BuildContext context) {
    final isTaken = event.isTaken;
    final isNotPickedUp = event.isNotPickedUp;

    final accentColor =
        isTaken ? MediTrackColors.mint : MediTrackColors.coral;
    final bgColor = isTaken
        ? MediTrackColors.mint.withValues(alpha: 0.08)
        : MediTrackColors.coral.withValues(alpha: 0.07);

    final timeStr = event.resolvedAtDateTime != null
        ? _formatTime(event.resolvedAtDateTime!)
        : '—';

    final subText = isTaken
        ? 'Taken at $timeStr'
        : isNotPickedUp
            ? '15-minute pickup window expired (pill remained in tray)'
            : 'Dose window closed — dispense was never triggered';

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentColor.withValues(alpha: 0.25),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isTaken
                  ? Icons.check_circle_rounded
                  : isNotPickedUp
                      ? Icons.hourglass_empty_rounded
                      : Icons.notifications_off_rounded,
              color: accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        event.medicationName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: MediTrackColors.navy,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        isTaken ? 'Taken' : 'Missed',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: accentColor == MediTrackColors.mint
                              ? MediTrackColors.mintDark
                              : MediTrackColors.coral,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Scheduled ${_formatTime12(event.scheduledFor)} · ${event.date}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: MediTrackColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subText,
                  style: TextStyle(
                    fontSize: 12,
                    color: isTaken
                        ? MediTrackColors.gray
                        : MediTrackColors.coral,
                    height: 1.4,
                  ),
                ),
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

  String _formatTime12(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final h = int.parse(parts[0]);
    final m = parts[1];
    final period = h >= 12 ? 'PM' : 'AM';
    final h12 = h > 12 ? h - 12 : (h == 0 ? 12 : h);
    return '$h12:$m $period';
  }
}

// ── Empty State ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final _HistoryFilter filter;

  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
        child: Column(
          children: [
            Icon(
              filter == _HistoryFilter.missed
                  ? Icons.check_circle_outline_rounded
                  : Icons.history_rounded,
              size: 48,
              color: MediTrackColors.grayLight,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              filter == _HistoryFilter.missed
                  ? 'No missed doses in this period'
                  : 'No history yet',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: MediTrackColors.gray,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Dose history will appear here\nafter your first dispense.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: MediTrackColors.grayMedium,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
