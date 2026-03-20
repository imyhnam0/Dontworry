import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/worry.dart';
import '../../data/providers/worry_providers.dart';
import '../common/planet_blast_overlay.dart';
import '../home/widgets/star_field_painter.dart';
import '../home/widgets/worry_planet_widget.dart';

class ReviewScreen extends ConsumerStatefulWidget {
  final String worryId;
  const ReviewScreen({super.key, required this.worryId});

  @override
  ConsumerState<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  bool _saved = false;
  bool _isSaving = false;
  ReviewAnswer? _selectedAnswer;

  Future<void> _save(Worry worry, ReviewAnswer answer) async {
    if (_isSaving) return;
    setState(() {
      _selectedAnswer = answer;
      _saved = true;
      _isSaving = true;
    });

    final saveFuture = ref.read(worryProvider.notifier).saveReview(
          id: widget.worryId,
          answer: answer,
        );

    await showPlanetBlastDialog(
      context,
      intensity: worry.intensity,
      isResolved: answer.isResolved,
    );

    await saveFuture;
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final worries = ref.watch(worryProvider);
    Worry? worry;
    for (final item in worries) {
      if (item.id == widget.worryId) {
        worry = item;
        break;
      }
    }
    worry ??= ref.read(worryProvider.notifier).getById(widget.worryId);

    if (worry == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => context.go('/home'));
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: AnimatedStarField(
        child: SafeArea(
          child: _saved ? _buildSavedState() : _buildReviewUI(worry),
        ),
      ),
    );
  }

  Widget _buildSavedState() {
    final isResolved = _selectedAnswer?.isResolved ?? false;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          (isResolved
                  ? const Text(
                      '✦',
                      style: TextStyle(
                        fontSize: 40,
                        color: AppColors.starResolved,
                      ),
                    )
                  : Image.asset(
                      'assets/space.png',
                      width: 88,
                      height: 88,
                      fit: BoxFit.contain,
                    ))
              .animate()
              .scale(
                begin: const Offset(0.3, 0.3),
                curve: Curves.elasticOut,
                duration: 800.ms,
              ),
          const SizedBox(height: 24),
          Text(
            isResolved ? '걱정이 해결됐어요!' : '은하수로 보내졌어요',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 600.ms),
          const SizedBox(height: 12),
          Text(
            isResolved
                ? '잘 해냈어요, 그 걱정은 지나갔어요'
                : '아직 괜찮아요, 천천히 해결해봐요',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ).animate(delay: 600.ms).fadeIn(duration: 600.ms),
        ],
      ),
    );
  }

  Widget _buildReviewUI(Worry worry) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(height: 40),

          const Text(
            '그때의 내가 적었어요',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
              letterSpacing: 1,
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 8),
          Text(
            _formatDate(worry.createdAt),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ).animate().fadeIn(duration: 500.ms),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: AppColors.backgroundCard,
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    SizedBox(
                      width: 28,
                      height: 28,
                      child: PlanetWidget(
                        intensity: worry.intensity,
                        overrideSize: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${worry.intensity.level}단계',
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  worry.content,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    height: 1.6,
                    fontWeight: FontWeight.w300,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 600.ms)
              .slideY(begin: 0.1),

          const SizedBox(height: 48),

          Center(
            child: const Text(
              '걱정은 해결됐나요?',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 22,
                fontWeight: FontWeight.w300,
                letterSpacing: -0.3,
              ),
            ).animate(delay: 400.ms).fadeIn(duration: 500.ms),
          ),

          const SizedBox(height: 32),

          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _save(worry, ReviewAnswer.resolved),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF4A90D9), Color(0xFF7B6FBF)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentBlue.withOpacity(0.25),
                          blurRadius: 12,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        '예',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(delay: 500.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.05),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: GestureDetector(
                  onTap: () => _save(worry, ReviewAnswer.notResolved),
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: AppColors.backgroundCard,
                      border: Border.all(
                        color: AppColors.textSecondary.withOpacity(0.4),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '아니요',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ),
                )
                    .animate(delay: 580.ms)
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: 0.05),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}년 ${dt.month}월 ${dt.day}일';
  }
}
