import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/medication_config.dart';
import '../../state/meditrack_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/pill_button.dart';
import '../../widgets/info_card.dart';

class WizardScreen extends StatefulWidget {
  final MedicationConfig? existingConfig;
  final int existingStock;

  const WizardScreen({
    super.key,
    this.existingConfig,
    this.existingStock = 0,
  });

  @override
  State<WizardScreen> createState() => _WizardScreenState();
}

class _WizardScreenState extends State<WizardScreen> {
  int _step = 0;
  bool _isSaving = false;

  // Draft fields
  late TextEditingController _nameCtrl;
  late TextEditingController _dosageCtrl;
  late TextEditingController _unitCtrl;
  late TextEditingController _purposeCtrl;
  late int _stockCount;
  late int _dosesPerDay;
  late List<TimeOfDay> _alarmTimes;
  late CourseType _courseType;
  late int _durationDays;
  late List<bool> _activeDays; // Mon-Sun index 0-6
  late int _pickupWindowMinutes;

  @override
  void initState() {
    super.initState();
    final c = widget.existingConfig;
    _nameCtrl = TextEditingController(text: c?.name ?? '');
    _dosageCtrl = TextEditingController(text: c?.dosageStrength ?? '');
    _unitCtrl = TextEditingController(text: c?.unitForm ?? '1 tablet');
    _purposeCtrl = TextEditingController(text: c?.purpose ?? '');
    _stockCount = widget.existingStock > 0 ? widget.existingStock : 10;
    _dosesPerDay = c?.alarmTimes.length ?? 1;
    _alarmTimes = c != null && c.alarmTimes.isNotEmpty
        ? c.alarmTimes.map(_parseTime).toList()
        : [const TimeOfDay(hour: 8, minute: 0)];
    while (_alarmTimes.length < _dosesPerDay) {
      _alarmTimes.add(const TimeOfDay(hour: 12, minute: 0));
    }
    _courseType = c?.courseType ?? CourseType.ongoing;
    _durationDays = c?.durationDays ?? 7;
    final days = c?.activeDays ?? ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    _activeDays = dayNames.map((d) => days.contains(d)).toList();
    _pickupWindowMinutes = c?.missedWindowMinutes ?? 15;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _dosageCtrl.dispose();
    _unitCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  TimeOfDay _parseTime(String hhmm) {
    final p = hhmm.split(':');
    return TimeOfDay(hour: int.parse(p[0]), minute: int.parse(p[1]));
  }

  String _formatTime(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';

  String _displayTime(TimeOfDay t) {
    final period = t.hour >= 12 ? 'PM' : 'AM';
    final h = t.hour > 12 ? t.hour - 12 : (t.hour == 0 ? 12 : t.hour);
    return '$h:${t.minute.toString().padLeft(2, '0')} $period';
  }

  bool get _canProceed {
    switch (_step) {
      case 0:
        return _nameCtrl.text.trim().isNotEmpty;
      case 1:
        return _stockCount > 0 && _stockCount <= 15;
      case 2:
        return _alarmTimes.length == _dosesPerDay;
      case 3:
        if (_courseType == CourseType.fixedDuration) {
          return _durationDays >= 1 && _durationDays <= 90;
        }
        return _activeDays.any((v) => v);
      case 4:
        return true;
      default:
        return false;
    }
  }

  Future<void> _save() async {
    final appState = context.read<MediTrackState>();

    // Block if dispensing
    if (appState.trayState.isDispensing) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot save while a dose is being dispensed.'),
          backgroundColor: MediTrackColors.coral,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final activeDayList = dayNames
          .asMap()
          .entries
          .where((e) => _activeDays[e.key])
          .map((e) => e.value)
          .toList();

      final sortedTimes = List<TimeOfDay>.from(_alarmTimes)
        ..sort((a, b) {
          final aMin = a.hour * 60 + a.minute;
          final bMin = b.hour * 60 + b.minute;
          return aMin.compareTo(bMin);
        });

      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final config = MedicationConfig(
        name: _nameCtrl.text.trim(),
        dosageStrength: _dosageCtrl.text.trim(),
        unitForm: _unitCtrl.text.trim(),
        purpose: _purposeCtrl.text.trim(),
        alarmTimes: sortedTimes.map(_formatTime).toList(),
        courseType: _courseType,
        startDate: todayStr,
        durationDays:
            _courseType == CourseType.fixedDuration ? _durationDays : null,
        activeDays: _courseType == CourseType.ongoing ? activeDayList : null,
        missedWindowMinutes: _pickupWindowMinutes,
      );

      await appState.saveMedicationConfig(config, _stockCount);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: $e'),
            backgroundColor: MediTrackColors.coral,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MediTrackColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            _WizardHeader(
              step: _step,
              onClose: () => Navigator.pop(context),
            ),
            _ProgressBar(step: _step, total: 5),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, anim) =>
                    FadeTransition(opacity: anim, child: child),
                child: KeyedSubtree(
                  key: ValueKey(_step),
                  child: _buildStep(),
                ),
              ),
            ),
            _WizardFooter(
              step: _step,
              canProceed: _canProceed,
              isSaving: _isSaving,
              onBack: _step > 0 ? () => setState(() => _step--) : null,
              onContinue: _step < 4
                  ? (_canProceed ? () => setState(() => _step++) : null)
                  : (_canProceed ? _save : null),
              isLastStep: _step == 4,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    switch (_step) {
      case 0:
        return _Step1MedicationDetails(
          nameCtrl: _nameCtrl,
          dosageCtrl: _dosageCtrl,
          unitCtrl: _unitCtrl,
          purposeCtrl: _purposeCtrl,
          onChanged: () => setState(() {}),
        );
      case 1:
        return _Step2PillInventory(
          count: _stockCount,
          onChanged: (v) => setState(() => _stockCount = v),
        );
      case 2:
        return _Step3DosingSchedule(
          dosesPerDay: _dosesPerDay,
          alarmTimes: _alarmTimes,
          onDosesChanged: (n) => setState(() {
            _dosesPerDay = n;
            while (_alarmTimes.length < n) {
              _alarmTimes.add(const TimeOfDay(hour: 12, minute: 0));
            }
            while (_alarmTimes.length > n) {
              _alarmTimes.removeLast();
            }
          }),
          onTimeChanged: (i, t) => setState(() => _alarmTimes[i] = t),
          displayTime: _displayTime,
        );
      case 3:
        return _Step4CourseLength(
          courseType: _courseType,
          durationDays: _durationDays,
          activeDays: _activeDays,
          onCourseTypeChanged: (t) => setState(() => _courseType = t),
          onDurationChanged: (d) => setState(() => _durationDays = d),
          onActiveDayToggled: (i) =>
              setState(() => _activeDays[i] = !_activeDays[i]),
        );
      case 4:
        return _Step5PickupWindow(
          minutes: _pickupWindowMinutes,
          onChanged: (m) => setState(() => _pickupWindowMinutes = m),
        );
      default:
        return const SizedBox();
    }
  }
}

// ── Wizard Header ─────────────────────────────────────────────────────────

class _WizardHeader extends StatelessWidget {
  final int step;
  final VoidCallback onClose;

  const _WizardHeader({required this.step, required this.onClose});

  static const _titles = [
    'Medication Details',
    'Pill Inventory',
    'Dosing Schedule',
    'Course Length',
    'Pickup Window',
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'STEP ${step + 1} OF 5',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: MediTrackColors.gray,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  _titles[step],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: MediTrackColors.navy,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: MediTrackColors.lavender,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.close_rounded,
                  size: 18, color: MediTrackColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Progress Bar ──────────────────────────────────────────────────────────

class _ProgressBar extends StatelessWidget {
  final int step;
  final int total;

  const _ProgressBar({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.md),
      child: Row(
        children: List.generate(total, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 4,
                decoration: BoxDecoration(
                  color: i <= step
                      ? MediTrackColors.mint
                      : MediTrackColors.grayLight,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Wizard Footer ─────────────────────────────────────────────────────────

class _WizardFooter extends StatelessWidget {
  final int step;
  final bool canProceed;
  final bool isSaving;
  final VoidCallback? onBack;
  final VoidCallback? onContinue;
  final bool isLastStep;

  const _WizardFooter({
    required this.step,
    required this.canProceed,
    required this.isSaving,
    this.onBack,
    this.onContinue,
    required this.isLastStep,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          if (onBack != null) ...[
            OutlinePillButton(
              label: '← Back',
              onTap: onBack,
              width: 110,
              borderColor: MediTrackColors.navy.withValues(alpha: 0.3),
              textColor: MediTrackColors.navy,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: PillButton(
              label: isLastStep ? 'Save & Start Reminders' : 'Continue →',
              onTap: onContinue,
              enabled: canProceed && !isSaving,
              isLoading: isSaving,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Step 1: Medication Details ────────────────────────────────────────────

class _Step1MedicationDetails extends StatelessWidget {
  final TextEditingController nameCtrl;
  final TextEditingController dosageCtrl;
  final TextEditingController unitCtrl;
  final TextEditingController purposeCtrl;
  final VoidCallback onChanged;

  const _Step1MedicationDetails({
    required this.nameCtrl,
    required this.dosageCtrl,
    required this.unitCtrl,
    required this.purposeCtrl,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Enter the details of the medication to be loaded into the dispenser.',
            style: TextStyle(
              fontSize: 14,
              color: MediTrackColors.gray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          _FormField(
            label: 'Medication Name',
            hint: 'e.g. Amoxicillin',
            controller: nameCtrl,
            onChanged: (_) => onChanged(),
            isRequired: true,
            maxLength: 100,
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Dosage Strength',
            hint: 'e.g. 500 mg',
            controller: dosageCtrl,
            onChanged: (_) => onChanged(),
            maxLength: 50,
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'Unit Form',
            hint: 'e.g. 1 capsule, 1 tablet',
            controller: unitCtrl,
            onChanged: (_) => onChanged(),
            maxLength: 50,
          ),
          const SizedBox(height: AppSpacing.md),
          _FormField(
            label: 'What it\'s for',
            hint: 'e.g. Bacterial infection — full course',
            controller: purposeCtrl,
            onChanged: (_) => onChanged(),
            maxLength: 120,
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.md),
          InfoCard(
            backgroundColor: MediTrackColors.mint.withValues(alpha: 0.1),
            child: const Row(
              children: [
                Icon(Icons.info_outline_rounded,
                    size: 16, color: MediTrackColors.navy),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Dosage and unit form are display-only labels.\nNo medical calculations are performed.',
                    style: TextStyle(
                      fontSize: 12,
                      color: MediTrackColors.navy,
                      height: 1.5,
                    ),
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

// ── Step 2: Pill Inventory ────────────────────────────────────────────────

class _Step2PillInventory extends StatelessWidget {
  final int count;
  final ValueChanged<int> onChanged;

  const _Step2PillInventory({
    required this.count,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const maxPills = 15;
    final pct = count / maxPills;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How many pills are currently in the hopper? Maximum capacity is 15 pills.',
            style: TextStyle(fontSize: 14, color: MediTrackColors.gray, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Pill count display
          Center(
            child: Column(
              children: [
                Text(
                  '$count',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.w900,
                    color: MediTrackColors.navy,
                    letterSpacing: -2,
                  ),
                ),
                const Text(
                  'pills in hopper',
                  style: TextStyle(
                    fontSize: 16,
                    color: MediTrackColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Dot row
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: List.generate(maxPills, (i) {
              final filled = i < count;
              return Container(
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  color: filled ? MediTrackColors.mint : MediTrackColors.grayLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: filled
                        ? MediTrackColors.mintDark
                        : MediTrackColors.grayLight,
                    width: 1,
                  ),
                ),
              );
            }),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Stepper row
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _StepperButton(
                icon: Icons.remove_rounded,
                onTap: count > 1 ? () => onChanged(count - 1) : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: MediTrackColors.navy,
                      ),
                    ),
                    const Text(
                      'of $maxPills max',
                      style: TextStyle(
                        fontSize: 12,
                        color: MediTrackColors.gray,
                      ),
                    ),
                  ],
                ),
              ),
              _StepperButton(
                icon: Icons.add_rounded,
                onTap: count < maxPills ? () => onChanged(count + 1) : null,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Capacity bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: LinearProgressIndicator(
                value: pct,
                backgroundColor: MediTrackColors.grayLight,
                valueColor: AlwaysStoppedAnimation(
                  count >= 13
                      ? MediTrackColors.mint
                      : count >= 8
                          ? MediTrackColors.amber
                          : MediTrackColors.coral,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${((1 - pct) * 100).toStringAsFixed(0)}% hopper capacity remaining',
            style: const TextStyle(fontSize: 12, color: MediTrackColors.gray),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Quick presets
          const Text(
            'QUICK FILL',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: MediTrackColors.gray,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [5, 10, 15].map((v) {
              final isSelected = count == v;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => onChanged(v),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MediTrackColors.navy
                          : MediTrackColors.lavender,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      v == 15 ? 'Fill Max (15)' : '$v',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isSelected ? Colors.white : MediTrackColors.navy,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _StepperButton({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled ? MediTrackColors.navy : MediTrackColors.grayLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon,
            color: enabled ? Colors.white : MediTrackColors.grayMedium,
            size: 22),
      ),
    );
  }
}

// ── Step 3: Dosing Schedule ───────────────────────────────────────────────

class _Step3DosingSchedule extends StatelessWidget {
  final int dosesPerDay;
  final List<TimeOfDay> alarmTimes;
  final ValueChanged<int> onDosesChanged;
  final Function(int, TimeOfDay) onTimeChanged;
  final String Function(TimeOfDay) displayTime;

  const _Step3DosingSchedule({
    required this.dosesPerDay,
    required this.alarmTimes,
    required this.onDosesChanged,
    required this.onTimeChanged,
    required this.displayTime,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How many times per day? Maximum 3 doses.',
            style: TextStyle(fontSize: 14, color: MediTrackColors.gray, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Doses per day selector
          const Text(
            'DOSES PER DAY',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: MediTrackColors.gray,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [1, 2, 3].map((n) {
              final isSelected = dosesPerDay == n;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: n < 3 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () => onDosesChanged(n),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? MediTrackColors.navy
                            : MediTrackColors.lavender,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Column(
                          children: [
                            Text(
                              '$n',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: isSelected
                                    ? Colors.white
                                    : MediTrackColors.navy,
                              ),
                            ),
                            Text(
                              n == 1 ? 'once' : n == 2 ? 'twice' : '3 times',
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? MediTrackColors.mint
                                    : MediTrackColors.gray,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),

          // Time pickers
          const Text(
            'ALARM TIMES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: MediTrackColors.gray,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          ...List.generate(dosesPerDay, (i) {
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: () async {
                  final t = await showTimePicker(
                    context: context,
                    initialTime: i < alarmTimes.length
                        ? alarmTimes[i]
                        : const TimeOfDay(hour: 8, minute: 0),
                    builder: (ctx, child) => Theme(
                      data: Theme.of(ctx).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: MediTrackColors.navy,
                          secondary: MediTrackColors.mint,
                        ),
                      ),
                      child: child!,
                    ),
                  );
                  if (t != null) onTimeChanged(i, t);
                },
                child: InfoCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: MediTrackColors.mint.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.alarm_rounded,
                            color: MediTrackColors.navy, size: 20),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dose ${i + 1}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: MediTrackColors.gray,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            i < alarmTimes.length
                                ? displayTime(alarmTimes[i])
                                : 'Tap to set',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: MediTrackColors.navy,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.chevron_right_rounded,
                          color: MediTrackColors.gray),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Step 4: Course Length ─────────────────────────────────────────────────

class _Step4CourseLength extends StatelessWidget {
  final CourseType courseType;
  final int durationDays;
  final List<bool> activeDays;
  final ValueChanged<CourseType> onCourseTypeChanged;
  final ValueChanged<int> onDurationChanged;
  final ValueChanged<int> onActiveDayToggled;

  const _Step4CourseLength({
    required this.courseType,
    required this.durationDays,
    required this.activeDays,
    required this.onCourseTypeChanged,
    required this.onDurationChanged,
    required this.onActiveDayToggled,
  });

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final isFixed = courseType == CourseType.fixedDuration;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Is this an ongoing medication or a fixed-length course?',
            style: TextStyle(fontSize: 14, color: MediTrackColors.gray, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Course type selection
          Row(
            children: [
              Expanded(
                child: _CourseTypeCard(
                  title: 'Ongoing',
                  subtitle: 'Daily maintenance\nwith active days',
                  icon: Icons.repeat_rounded,
                  isSelected: !isFixed,
                  onTap: () => onCourseTypeChanged(CourseType.ongoing),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _CourseTypeCard(
                  title: 'Fixed Duration',
                  subtitle: 'Runs every day\nfor N days',
                  icon: Icons.calendar_month_rounded,
                  isSelected: isFixed,
                  onTap: () =>
                      onCourseTypeChanged(CourseType.fixedDuration),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          if (isFixed) ...[
            const Text(
              'NUMBER OF DAYS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: MediTrackColors.gray,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            _DayDurationPicker(
              value: durationDays,
              onChanged: onDurationChanged,
            ),
            const SizedBox(height: AppSpacing.sm),
            const InfoCard(
              backgroundColor: MediTrackColors.lavenderDeep,
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: MediTrackColors.navy),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Fixed-duration courses run every day. The Active Days selector is not available for fixed courses.',
                      style: TextStyle(
                          fontSize: 12,
                          color: MediTrackColors.navy,
                          height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            const Text(
              'ACTIVE DAYS',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: MediTrackColors.gray,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (i) {
                return _DayToggle(
                  label: dayLabels[i].substring(0, 1),
                  isActive: activeDays[i],
                  onTap: () => onActiveDayToggled(i),
                );
              }),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              '${activeDays.where((v) => v).length} day${activeDays.where((v) => v).length != 1 ? 's' : ''} selected',
              style: const TextStyle(fontSize: 13, color: MediTrackColors.gray),
            ),
          ],
        ],
      ),
    );
  }
}

class _CourseTypeCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CourseTypeCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? MediTrackColors.navy : MediTrackColors.lavender,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? MediTrackColors.mint
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon,
                color: isSelected
                    ? MediTrackColors.mint
                    : MediTrackColors.navy,
                size: 26),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: isSelected ? Colors.white : MediTrackColors.navy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? MediTrackColors.mint.withValues(alpha: 0.8)
                    : MediTrackColors.gray,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayToggle extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _DayToggle({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? MediTrackColors.navy : MediTrackColors.lavender,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isActive ? Colors.white : MediTrackColors.gray,
            ),
          ),
        ),
      ),
    );
  }
}

class _DayDurationPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DayDurationPicker({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return InfoCard(
      child: Row(
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            onTap: value > 1 ? () => onChanged(value - 1) : null,
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$value',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: MediTrackColors.navy,
                    letterSpacing: -1,
                  ),
                ),
                Text(
                  value == 1 ? 'day' : 'days',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: MediTrackColors.gray,
                  ),
                ),
              ],
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            onTap: value < 90 ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

// ── Step 5: Pickup Window ─────────────────────────────────────────────────

class _Step5PickupWindow extends StatelessWidget {
  final int minutes;
  final ValueChanged<int> onChanged;

  const _Step5PickupWindow({
    required this.minutes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    const options = [5, 10, 15, 20, 30];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'How long should the system wait for you to pick up the pill before marking it as missed?',
            style: TextStyle(fontSize: 14, color: MediTrackColors.gray, height: 1.5),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Large time display
          Center(
            child: Column(
              children: [
                Text(
                  '$minutes',
                  style: const TextStyle(
                    fontSize: 80,
                    fontWeight: FontWeight.w900,
                    color: MediTrackColors.navy,
                    letterSpacing: -3,
                  ),
                ),
                const Text(
                  'minute pickup window',
                  style: TextStyle(
                    fontSize: 16,
                    color: MediTrackColors.gray,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Options
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((m) {
              final isSelected = m == minutes;
              return GestureDetector(
                onTap: () => onChanged(m),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? MediTrackColors.navy
                        : MediTrackColors.lavender,
                    borderRadius: BorderRadius.circular(99),
                    border: isSelected
                        ? Border.all(color: MediTrackColors.mint, width: 2)
                        : null,
                  ),
                  child: Text(
                    '$m min',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color:
                          isSelected ? Colors.white : MediTrackColors.navy,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),

          InfoCard(
            backgroundColor: MediTrackColors.lavenderDeep,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.verified_rounded,
                        size: 16, color: MediTrackColors.navy),
                    SizedBox(width: 8),
                    Text(
                      'Hardware-verified pickup',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: MediTrackColors.navy,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The load cell under the tray detects when you remove the pill. If the window expires with the pill still present, the dose is marked missed — no manual confirmation required.',
                  style: const TextStyle(
                    fontSize: 12,
                    color: MediTrackColors.navy,
                    height: 1.5,
                  ).copyWith(color: MediTrackColors.darkGray),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable form field ───────────────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isRequired;
  final int? maxLength;
  final int maxLines;

  const _FormField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.onChanged,
    this.isRequired = false,
    this.maxLength,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: MediTrackColors.navy,
              ),
            ),
            if (isRequired)
              const Text(
                ' *',
                style: TextStyle(color: MediTrackColors.coral),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          onChanged: onChanged,
          maxLength: maxLength,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 15,
            color: MediTrackColors.navy,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: MediTrackColors.grayMedium,
              fontSize: 15,
            ),
            filled: true,
            fillColor: MediTrackColors.lavender,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide:
                  const BorderSide(color: MediTrackColors.navy, width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 14),
            counterText: '',
          ),
        ),
      ],
    );
  }
}
