import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/worry.dart';
import '../../data/providers/worry_providers.dart';
import '../common/planet_blast_overlay.dart';
import 'widgets/star_field_painter.dart';
import 'widgets/worry_planet_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final worries = ref.watch(worryProvider);
    final reviewable = ref.watch(reviewableWorriesProvider);
    final active = ref.watch(activeWorriesProvider);
    final resolved = ref.watch(resolvedWorriesProvider);

    final visibleWorries = [...reviewable, ...active];

    return Scaffold(
      body: AnimatedStarField(
        child: SafeArea(
          child: Stack(
            children: [
              // Reviewable notification at top
              if (reviewable.isNotEmpty)
                Positioned(
                  top: 16,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '열어볼 수 있는 별이 ${reviewable.length}개 있어요 ✦',
                      style: const TextStyle(
                        color: AppColors.starReviewable,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ).animate().fadeIn().shimmer(
                          duration: 2000.ms,
                          color: AppColors.starReviewable,
                        ),
                  ),
                ),

              // Planets area (full screen, scrollable)
              Positioned.fill(
                top: reviewable.isNotEmpty ? 40 : 8,
                bottom: 100,
                child: worries.isEmpty
                    ? _buildEmpty()
                    : _ScatteredPlanets(
                        worries: visibleWorries,
                        onWorryTap: (worry) {
                          if (worry.status == WorryStatus.reviewable) {
                            context.push('/review/${worry.id}');
                          } else {
                            _showWorryDetail(context, worry);
                          }
                        },
                      ),
              ),

              // Bottom bar
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildBottom(context, resolved.length),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text(
            '✦',
            style: TextStyle(fontSize: 32, color: AppColors.starDim),
          ),
          SizedBox(height: 16),
          Text(
            '아직 맡겨둔 걱정이 없어요',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '지금의 걱정을 행성으로 올려보세요',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 300.ms, duration: 800.ms),
    );
  }

  Widget _buildBottom(BuildContext context, int resolvedCount) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withOpacity(0.8),
            AppColors.background,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 40),
      child: Row(
        children: [
          if (resolvedCount > 0)
            GestureDetector(
              onTap: () => context.push('/archive'),
              child: Container(
                height: 52,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  border: Border.all(
                    color: AppColors.accentPurple.withOpacity(0.35),
                  ),
                  gradient: LinearGradient(
                    colors: [
                      AppColors.backgroundSurface.withOpacity(0.95),
                      AppColors.backgroundCard.withOpacity(0.88),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accentPurple.withOpacity(0.12),
                      blurRadius: 14,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/space.png',
                      width: 30,
                      height: 30,
                      fit: BoxFit.contain,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '은하수 ($resolvedCount)',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.push('/write'),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4A90D9), Color(0xFF7B6FBF)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accentBlue.withOpacity(0.35),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  void _showWorryDetail(BuildContext context, Worry worry) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _WorryDetailSheet(
        worry: worry,
        parentContext: context,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Scattered planet layout with 2D scroll
// ─────────────────────────────────────────────────────────────
class _ScatteredPlanets extends StatelessWidget {
  final List<Worry> worries;
  final void Function(Worry) onWorryTap;

  const _ScatteredPlanets({
    required this.worries,
    required this.onWorryTap,
  });

  @override
  Widget build(BuildContext context) {
    if (worries.isEmpty) {
      return Center(
        child: const Text(
          '모든 걱정이 은하수로 흘러갔어요',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ).animate().fadeIn(duration: 600.ms),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewW = constraints.maxWidth;
        final viewH = constraints.maxHeight;
        final positions = _computePositions(worries, viewW, viewH);
        final canvasW = positions.$1;
        final coords = positions.$3;

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: SizedBox(
            width: canvasW,
            height: viewH,
            child: Stack(
              clipBehavior: Clip.none,
              children: List.generate(worries.length, (i) {
                final worry = worries[i];
                final pos = coords[i];
                return Positioned(
                  left: pos.dx,
                  top: pos.dy,
                  child: _FloatingPlanet(
                    worry: worry,
                    index: i,
                    onTap: () => onWorryTap(worry),
                  ),
                );
              }),
            ),
          ),
        );
      },
    );
  }

  /// Horizontal-only constellation layout.
  /// 3~4 planets visible per screen, scattered naturally top-to-bottom.
  (double, double, List<Offset>) _computePositions(
      List<Worry> items, double viewW, double viewH) {
    final n = items.length;
    if (n == 0) return (viewW, viewH, []);

    const planetSlot = 140.0;

    final perPage = 7.5;
    final pages = (n / perPage).ceil().clamp(1, 100);
    final canvasW = max(viewW, pages * viewW);

    // Deterministic shuffle for natural ordering
    final indices = List.generate(n, (i) => i);
    final shuffleSeed = items.map((w) => w.id.hashCode).fold(0, (a, b) => a ^ b);
    indices.shuffle(Random(shuffleSeed));

    // Vertically divide into 3 lanes for natural spread
    final laneH = (viewH - planetSlot) / 3;

    const minDist = 90.0;
    const maxAttempts = 30;

    final coords = <Offset>[];
    for (var i = 0; i < n; i++) {
      final idx = indices[i];
      var r = Random(items[idx].id.hashCode);

      final sliceW = canvasW / n;
      final baseX = i * sliceW;

      final lane = idx % 3;
      final laneTop = lane * laneH;

      Offset best = Offset.zero;
      double bestMinDist = -1;

      for (var attempt = 0; attempt < maxAttempts; attempt++) {
        final jitterX = (r.nextDouble() - 0.5) * sliceW * 0.5;
        final x = (baseX + sliceW * 0.25 + jitterX).clamp(8.0, canvasW - planetSlot);
        final y = (laneTop + r.nextDouble() * laneH).clamp(8.0, viewH - planetSlot);
        final candidate = Offset(x, y);

        double nearest = double.infinity;
        for (final placed in coords) {
          final d = (candidate - placed).distance;
          if (d < nearest) nearest = d;
        }

        if (nearest >= minDist) {
          best = candidate;
          break;
        }
        if (nearest > bestMinDist) {
          bestMinDist = nearest;
          best = candidate;
        }
        r = Random(items[idx].id.hashCode + attempt + 1);
      }

      coords.add(best);
    }

    return (canvasW, viewH, coords);
  }
}

class _FloatingPlanet extends StatefulWidget {
  final Worry worry;
  final int index;
  final VoidCallback onTap;

  const _FloatingPlanet({
    required this.worry,
    required this.index,
    required this.onTap,
  });

  @override
  State<_FloatingPlanet> createState() => _FloatingPlanetState();
}

class _FloatingPlanetState extends State<_FloatingPlanet>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    final phase = (widget.worry.id.hashCode % 100) / 100.0;
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2500 + (phase * 1500).toInt()),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -3, end: 3).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isReviewable => widget.worry.status == WorryStatus.reviewable;

  @override
  Widget build(BuildContext context) {
    final intensity = widget.worry.intensity;

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: SizedBox(
              width: 100,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isReviewable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      margin: const EdgeInsets.only(bottom: 6),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: AppColors.starReviewable.withOpacity(0.2),
                        border: Border.all(
                          color: AppColors.starReviewable.withOpacity(0.5),
                          width: 0.5,
                        ),
                      ),
                      child: const Text(
                        '열어보기',
                        style: TextStyle(
                          color: AppColors.starReviewable,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  PlanetWidget(intensity: intensity),
                  const SizedBox(height: 6),
                  Text(
                    '${intensity.level}단계',
                    style: TextStyle(
                      color: _isReviewable
                          ? AppColors.starReviewable
                          : AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.worry.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: AppColors.textHint,
                      fontSize: 10,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    )
        .animate(delay: Duration(milliseconds: 60 * widget.index))
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.7, 0.7), curve: Curves.easeOutBack);
  }
}

// ─────────────────────────────────────────────────────────────
// Worry detail bottom sheet
// ─────────────────────────────────────────────────────────────
class _WorryDetailSheet extends ConsumerWidget {
  final Worry worry;
  final BuildContext parentContext;

  const _WorryDetailSheet({
    required this.worry,
    required this.parentContext,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final maxHeight = MediaQuery.of(context).size.height * 0.78;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.divider),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
          Row(
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: PlanetWidget(
                  intensity: worry.intensity,
                  overrideSize: 24,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${worry.intensity.level}단계',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const Spacer(),
              Text(
                _formatDate(worry.createdAt),
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            worry.content,
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
              const Text(
                '다시 볼 날',
                style: TextStyle(color: AppColors.textHint, fontSize: 13),
              ),
              const Spacer(),
              Text(
                _formatDate(worry.reviewAt),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              final saveFuture = ref.read(worryProvider.notifier).saveReview(
                    id: worry.id,
                    answer: ReviewAnswer.resolved,
                  );

              await showPlanetBlastDialog(
                parentContext,
                intensity: worry.intensity,
                isResolved: true,
              );

              await saveFuture;
            },
            child: Container(
              width: double.infinity,
              height: 48,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: const LinearGradient(
                  colors: [Color(0xFF4A90D9), Color(0xFF7B6FBF)],
                ),
              ),
              child: const Center(
                child: Text(
                  '걱정 해결됐어요',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              Navigator.pop(context);
              await ref.read(worryProvider.notifier).deleteWorry(worry.id);
            },
            child: Container(
              width: double.infinity,
              height: 44,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: const Color(0xFF2A1520),
                border: Border.all(
                    color: AppColors.accentPink.withOpacity(0.3)),
              ),
              child: Center(
                child: Text(
                  '별을 지우기',
                  style: TextStyle(
                    color: AppColors.accentPink.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
          ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}. ${dt.month}. ${dt.day}';
  }
}
