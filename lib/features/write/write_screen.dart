import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/worry.dart';
import '../../data/providers/worry_providers.dart';
import '../home/widgets/star_field_painter.dart';
import '../home/widgets/worry_planet_widget.dart';

class WriteScreen extends ConsumerStatefulWidget {
  const WriteScreen({super.key});

  @override
  ConsumerState<WriteScreen> createState() => _WriteScreenState();
}

class _WriteScreenState extends ConsumerState<WriteScreen> {
  final _pageController = PageController();
  int _step = 0; // 0: write, 1: intensity, 2: date, 3: confirm

  final _textController = TextEditingController();
  WorryIntensity? _selectedIntensity;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _textController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _goNext() {
    if (_step == 0 && _textController.text.trim().isEmpty) return;
    if (_step == 1 && _selectedIntensity == null) return;
    if (_step == 2 && _selectedDate == null) return;

    if (_step == 0) {
      FocusManager.instance.primaryFocus?.unfocus();
    }

    if (_step < 3) {
      setState(() => _step++);
      _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    }
  }

  Future<void> _save() async {
    final worry = Worry(
      id: const Uuid().v4(),
      content: _textController.text.trim(),
      intensity: _selectedIntensity!,
      reviewAt: _selectedDate!,
      createdAt: DateTime.now(),
    );
    await ref.read(worryProvider.notifier).addWorry(worry);
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: AnimatedStarField(
          child: SafeArea(
            child: Column(
              children: [
                _buildTopBar(),
                _buildProgressBar(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _WriteStep(
                        controller: _textController,
                        onNext: _goNext,
                      ),
                      _IntensityStep(
                        selected: _selectedIntensity,
                        onSelect: (v) {
                          setState(() => _selectedIntensity = v);
                          Future.delayed(
                            const Duration(milliseconds: 400),
                            _goNext,
                          );
                        },
                      ),
                      _DateStep(
                        selected: _selectedDate,
                        onSelect: (d) => setState(() => _selectedDate = d),
                        onNext: _goNext,
                      ),
                      _ConfirmStep(
                        content: _textController.text,
                        intensity: _selectedIntensity,
                        date: _selectedDate,
                        onSave: _save,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 16, 0),
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              if (_step > 0) {
                setState(() => _step--);
                _pageController.animateToPage(
                  _step,
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeOutCubic,
                );
              } else {
                context.pop();
              }
            },
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 0),
      child: Row(
        children: List.generate(4, (i) {
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(1),
                color: i <= _step ? AppColors.accentBlue : AppColors.divider,
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 1: Write worry
// ─────────────────────────────────────────────────────────────
class _WriteStep extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onNext;

  const _WriteStep({required this.controller, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '지금 무슨 걱정이\n마음에 걸리나요?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              height: 1.4,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1),
          const SizedBox(height: 8),
          const Text(
            '정리되지 않아도 괜찮아요',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF162249),
                    Color(0xFF101936),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accentBlue.withValues(alpha: 0.45),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.14),
                    blurRadius: 28,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(999),
                      color: AppColors.accentBlue.withValues(alpha: 0.12),
                    ),
                    child: const Text(
                      '걱정 적는 곳',
                      style: TextStyle(
                        color: AppColors.accentBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      maxLines: null,
                      expands: true,
                      autofocus: true,
                      textInputAction: TextInputAction.done,
                      onSubmitted: (_) => onNext(),
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 17,
                        height: 1.75,
                        fontWeight: FontWeight.w300,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: '마음에 걸리는 것들을\n자유롭게 적어주세요...',
                        hintStyle: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 16,
                          height: 1.7,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 600.ms),
          const SizedBox(height: 24),
          _NextButton(onTap: onNext, label: '다음'),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 2: Select intensity (10 planet levels, 3-column grid)
// ─────────────────────────────────────────────────────────────
class _IntensityStep extends StatelessWidget {
  final WorryIntensity? selected;
  final ValueChanged<WorryIntensity> onSelect;

  const _IntensityStep({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final values = WorryIntensity.values;

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '이 걱정의 무게를\n행성으로 골라보세요',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              height: 1.4,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 6),
          const Text(
            '무거울수록 큰 행성이에요',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 500.ms),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: values.length,
              itemBuilder: (context, i) {
                final intensity = values[i];
                final isSelected = selected == intensity;
                final imgSize = 28.0 + i * 4.5;

                return GestureDetector(
                  onTap: () => onSelect(intensity),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isSelected
                          ? AppColors.accentBlue.withOpacity(0.15)
                          : AppColors.backgroundCard.withOpacity(0.5),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accentBlue
                            : AppColors.divider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 72,
                          height: 72,
                          child: Center(
                            child: Image.asset(
                              'assets/${intensity.level}.png',
                              width: imgSize,
                              height: imgSize,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '${intensity.level}단계',
                          style: TextStyle(
                            color: isSelected
                                ? AppColors.accentBlue
                                : AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                    .animate(delay: Duration(milliseconds: 40 * i))
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.9, 0.9),
                      curve: Curves.easeOut,
                    );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Step 3: Select date
// ─────────────────────────────────────────────────────────────
class _DateStep extends StatelessWidget {
  final DateTime? selected;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onNext;

  const _DateStep({
    required this.selected,
    required this.onSelect,
    required this.onNext,
  });

  static const _presets = [
    ('10분 뒤', Duration(minutes: 10)),
    ('1일 뒤', Duration(days: 1)),
    ('3일 뒤', Duration(days: 3)),
    ('일주일 뒤', Duration(days: 7)),
    ('1개월 뒤', Duration(days: 30)),
    ('3개월 뒤', Duration(days: 90)),
  ];

  @override
  Widget build(BuildContext context) {
    final selectedLabel = selected == null
        ? null
        : _formatDateOnly(selected!);

    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '언제 다시\n꺼내볼까요?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              height: 1.4,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 8),
          const Text(
            '그때의 내가 지금의 걱정을 다시 볼 거예요',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 14,
            ),
          ).animate(delay: 200.ms).fadeIn(),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: _presets.asMap().entries.map((entry) {
                final i = entry.key;
                final label = entry.value.$1;
                final dur = entry.value.$2;
                final date = DateTime.now().add(dur);
                final isSelected = selected != null &&
                    selected!.difference(date).abs() <
                        const Duration(seconds: 5);
                return GestureDetector(
                  onTap: () => onSelect(date),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isSelected
                          ? AppColors.accentBlue.withOpacity(0.15)
                          : AppColors.backgroundCard.withOpacity(0.5),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.accentBlue : AppColors.divider,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? AppColors.accentBlue
                              : AppColors.textSecondary,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.w500 : FontWeight.w300,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(delay: Duration(milliseconds: 60 * i))
                    .fadeIn(duration: 400.ms)
                    .scale(
                      begin: const Offset(0.95, 0.95),
                      curve: Curves.easeOut,
                    );
              }).toList(),
            ),
          ),
          GestureDetector(
            onTap: () async {
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final initialDate =
                  selected ?? today.add(const Duration(days: 7));
              final date = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: today,
                lastDate: now.add(const Duration(days: 365 * 3)),
                builder: (context, child) => Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: const ColorScheme.dark(
                      primary: AppColors.accentBlue,
                      secondary: AppColors.accentGold,
                      surface: AppColors.backgroundSurface,
                      onPrimary: Colors.white,
                      onSurface: AppColors.textPrimary,
                    ),
                    scaffoldBackgroundColor: AppColors.background,
                    dialogTheme: DialogThemeData(
                      backgroundColor: AppColors.backgroundCard,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    datePickerTheme: DatePickerThemeData(
                      backgroundColor: AppColors.backgroundCard,
                      surfaceTintColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                        side: BorderSide(
                          color: AppColors.accentBlue.withOpacity(0.22),
                        ),
                      ),
                      headerBackgroundColor: AppColors.backgroundSurface,
                      headerForegroundColor: AppColors.textPrimary,
                      weekdayStyle: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                      dayStyle: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      yearStyle: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                      todayForegroundColor: WidgetStateProperty.all(
                        AppColors.accentGold,
                      ),
                      todayBorder: BorderSide(
                        color: AppColors.accentGold.withOpacity(0.55),
                      ),
                      dayForegroundColor: WidgetStateProperty.resolveWith(
                        (states) {
                          if (states.contains(WidgetState.selected)) {
                            return Colors.white;
                          }
                          if (states.contains(WidgetState.disabled)) {
                            return AppColors.textHint;
                          }
                          return AppColors.textPrimary;
                        },
                      ),
                      dayBackgroundColor: WidgetStateProperty.resolveWith(
                        (states) {
                          if (states.contains(WidgetState.selected)) {
                            return AppColors.accentBlue;
                          }
                          return Colors.transparent;
                        },
                      ),
                      yearForegroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      yearBackgroundColor: WidgetStateProperty.resolveWith(
                        (states) => states.contains(WidgetState.selected)
                            ? AppColors.accentBlue
                            : Colors.transparent,
                      ),
                      cancelButtonStyle: TextButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                      ),
                      confirmButtonStyle: TextButton.styleFrom(
                        foregroundColor: AppColors.accentBlue,
                      ),
                    ),
                  ),
                  child: child!,
                ),
              );
              if (date != null) {
                final pickedDay = DateTime(date.year, date.month, date.day);
                final isToday = pickedDay == today;
                final scheduledAt = isToday
                    ? now.add(const Duration(minutes: 10))
                    : DateTime(date.year, date.month, date.day, 9);
                if (!scheduledAt.isAfter(now)) return;
                onSelect(scheduledAt);
              }
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentBlue.withOpacity(0.18),
                    AppColors.accentPurple.withOpacity(0.16),
                  ],
                ),
                border: Border.all(
                  color: AppColors.accentBlue.withOpacity(0.45),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withOpacity(0.14),
                    blurRadius: 18,
                    spreadRadius: 1,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.backgroundSurface.withOpacity(0.75),
                    ),
                    child: Icon(
                      Icons.calendar_month_rounded,
                      color: AppColors.accentGold.withOpacity(0.95),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          '직접 날짜 선택',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '날짜를 고를 수 있어요!',
                          style: TextStyle(
                            color: AppColors.accentBlue.withOpacity(0.86),
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (selectedLabel != null)
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        color: AppColors.backgroundSurface.withOpacity(0.82),
                        border: Border.all(
                          color: AppColors.accentGold.withOpacity(0.28),
                        ),
                      ),
                      child: Text(
                        selectedLabel,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.textSecondary.withOpacity(0.9),
                      size: 22,
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _NextButton(
            onTap: selected != null ? onNext : null,
            label: '다음',
          ),
        ],
      ),
    );
  }

  String _formatDateOnly(DateTime dt) {
    return '${dt.year}. ${dt.month}. ${dt.day}';
  }
}

// ─────────────────────────────────────────────────────────────
// Step 4: Confirm & save
// ─────────────────────────────────────────────────────────────
class _ConfirmStep extends StatefulWidget {
  final String content;
  final WorryIntensity? intensity;
  final DateTime? date;
  final VoidCallback onSave;

  const _ConfirmStep({
    required this.content,
    required this.intensity,
    required this.date,
    required this.onSave,
  });

  @override
  State<_ConfirmStep> createState() => _ConfirmStepState();
}

class _ConfirmStepState extends State<_ConfirmStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _starAnim;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _starAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
  }

  @override
  void dispose() {
    _starAnim.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    setState(() => _saved = true);
    _starAnim.forward();
    await Future.delayed(const Duration(milliseconds: 1800));
    widget.onSave();
  }

  String _formatDate(DateTime? dt) {
    if (dt == null) return '';
    final now = DateTime.now();
    final diff = dt.difference(now);
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 뒤';
    if (diff.inHours < 24) return '${diff.inHours}시간 뒤';
    if (diff.inDays < 7) return '${diff.inDays}일 뒤';
    return _formatFullDateTime(dt);
  }

  String _formatFullDateTime(DateTime dt) {
    final period = dt.hour < 12 ? '오전' : '오후';
    final hour = dt.hour == 0 ? 12 : (dt.hour > 12 ? dt.hour - 12 : dt.hour);
    final minute = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}. ${dt.month}. ${dt.day} $period $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 40, 28, 40),
      child: Column(
        children: [
          if (!_saved) ...[
            const Text(
              '이렇게 맡겨둘게요',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                letterSpacing: 1,
              ),
            ).animate().fadeIn(duration: 500.ms),
            const SizedBox(height: 32),
            if (widget.intensity != null)
              PlanetWidget(intensity: widget.intensity!)
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 600.ms)
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    curve: Curves.easeOutBack,
                  ),
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 300),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: AppColors.backgroundCard,
                border: Border.all(color: AppColors.divider),
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.content,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        height: 1.6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.divider),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Text(
                          widget.intensity?.shortLabel ?? '',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatDate(widget.date),
                          style: const TextStyle(
                            color: AppColors.accentBlue,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ).animate(delay: 200.ms).fadeIn(duration: 600.ms).slideY(begin: 0.1),
            const Spacer(),
            GestureDetector(
              onTap: _handleSave,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A90D9), Color(0xFF7B6FBF)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentBlue.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    '행성으로 올려두기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
          ] else ...[
            const Spacer(),
            AnimatedBuilder(
              animation: _starAnim,
              builder: (context, _) {
                final t = _starAnim.value;
                return Transform.translate(
                  offset: Offset(0, -80 * t),
                  child: Opacity(
                    opacity: t < 0.8 ? 1.0 : (1.0 - (t - 0.8) / 0.2),
                    child: Column(
                      children: [
                        if (widget.intensity != null)
                          PlanetWidget(intensity: widget.intensity!),
                        const SizedBox(height: 32),
                        const Text(
                          '걱정을 잠시\n맡겨두었어요',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.w300,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          '때가 되면 다시 꺼내볼게요',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const Spacer(),
          ],
        ],
      ),
    );
  }
}

class _NextButton extends StatelessWidget {
  final VoidCallback? onTap;
  final String label;

  const _NextButton({required this.onTap, required this.label});

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(29),
          gradient: enabled
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF7EB8F7), Color(0xFF5F87F2)],
                )
              : null,
          color: enabled ? null : AppColors.backgroundCard,
          border: Border.all(color: enabled ? Colors.transparent : AppColors.divider),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: AppColors.accentBlue.withValues(alpha: 0.28),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: enabled ? AppColors.background : AppColors.textHint,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (enabled) ...[
                const SizedBox(width: 8),
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: AppColors.background,
                  size: 18,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
