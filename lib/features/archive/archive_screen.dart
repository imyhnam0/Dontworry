import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/worry.dart';
import '../../data/providers/worry_providers.dart';
import '../home/widgets/star_field_painter.dart';
import '../home/widgets/worry_planet_widget.dart';

enum _ArchiveFilter { all, resolved, notResolved }

class ArchiveScreen extends ConsumerStatefulWidget {
  const ArchiveScreen({super.key});

  @override
  ConsumerState<ArchiveScreen> createState() => _ArchiveScreenState();
}

class _ArchiveScreenState extends ConsumerState<ArchiveScreen> {
  _ArchiveFilter _filter = _ArchiveFilter.all;

  @override
  Widget build(BuildContext context) {
    final allResolved = ref.watch(resolvedWorriesProvider);
    final resolvedCount =
        allResolved.where((w) => w.reviewAnswer == ReviewAnswer.resolved).length;
    final notResolvedCount =
        allResolved.where((w) => w.reviewAnswer == ReviewAnswer.notResolved).length;

    final filtered = _filterList(allResolved);

    return Scaffold(
      body: AnimatedStarField(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              _buildStats(allResolved.length, resolvedCount, notResolvedCount),
              const SizedBox(height: 8),
              if (allResolved.isEmpty)
                Expanded(child: _buildEmpty())
              else
                Expanded(child: _buildArchiveList(filtered)),
            ],
          ),
        ),
      ),
    );
  }

  List<Worry> _filterList(List<Worry> all) {
    switch (_filter) {
      case _ArchiveFilter.all:
        return all;
      case _ArchiveFilter.resolved:
        return all.where((w) => w.reviewAnswer == ReviewAnswer.resolved).toList();
      case _ArchiveFilter.notResolved:
        return all
            .where((w) => w.reviewAnswer == ReviewAnswer.notResolved)
            .toList();
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () => context.pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textSecondary,
              size: 20,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(height: 20),
          const Text(
            '은하수 아카이브',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.w300,
              letterSpacing: -0.5,
            ),
          ).animate().fadeIn(duration: 600.ms),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildStats(int total, int resolved, int notResolved) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          _buildStatChip(
            label: '전체',
            count: total,
            isActive: _filter == _ArchiveFilter.all,
            color: AppColors.accentBlue,
            onTap: () => setState(() => _filter = _ArchiveFilter.all),
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            label: '해결',
            count: resolved,
            isActive: _filter == _ArchiveFilter.resolved,
            color: AppColors.starResolved,
            onTap: () => setState(() => _filter = _ArchiveFilter.resolved),
          ),
          const SizedBox(width: 8),
          _buildStatChip(
            label: '미해결',
            count: notResolved,
            isActive: _filter == _ArchiveFilter.notResolved,
            color: AppColors.accentPink,
            onTap: () => setState(() => _filter = _ArchiveFilter.notResolved),
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn(duration: 500.ms);
  }

  Widget _buildStatChip({
    required String label,
    required int count,
    required bool isActive,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: isActive
                ? color.withOpacity(0.15)
                : AppColors.backgroundCard.withOpacity(0.5),
            border: Border.all(
              color: isActive ? color.withOpacity(0.6) : AppColors.divider,
              width: isActive ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                '$count',
                style: TextStyle(
                  color: isActive ? color : AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? color : AppColors.textHint,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
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
            '아직 지나간 걱정이 없어요',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 15,
              fontWeight: FontWeight.w300,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '걱정이 지나가면 여기 모이게 돼요',
            style: TextStyle(
              color: AppColors.textHint,
              fontSize: 13,
            ),
          ),
        ],
      ).animate().fadeIn(delay: 200.ms, duration: 600.ms),
    );
  }

  Widget _buildArchiveList(List<Worry> worries) {
    if (worries.isEmpty) {
      final msg = _filter == _ArchiveFilter.resolved
          ? '해결된 걱정이 아직 없어요'
          : '미해결 걱정이 없어요';
      return Center(
        child: Text(
          msg,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.w300,
          ),
        ).animate().fadeIn(duration: 400.ms),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      itemCount: worries.length,
      itemBuilder: (context, i) {
        final worry = worries[i];
        return _ArchiveCard(worry: worry)
            .animate(delay: Duration(milliseconds: i * 60))
            .fadeIn(duration: 400.ms)
            .slideY(begin: 0.05);
      },
    );
  }
}

class _ArchiveCard extends ConsumerWidget {
  final Worry worry;
  const _ArchiveCard({required this.worry});

  bool get _isResolved => worry.reviewAnswer == ReviewAnswer.resolved;

  Color get _statusColor =>
      _isResolved ? AppColors.starResolved : AppColors.accentPink;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => _showWorryDetail(context, ref),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.backgroundSurface.withOpacity(0.98),
              AppColors.backgroundCard.withOpacity(0.92),
            ],
          ),
          border: Border.all(
            color: _statusColor.withOpacity(0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 112,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    _statusColor,
                    _statusColor.withOpacity(0.25),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: PlanetWidget(
                          intensity: worry.intensity,
                          overrideSize: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${worry.intensity.level}단계 걱정',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          color: _statusColor.withOpacity(0.16),
                          border: Border.all(
                            color: _statusColor.withOpacity(0.28),
                          ),
                        ),
                        child: Text(
                          _isResolved ? '해결' : '미해결',
                          style: TextStyle(
                            color: _statusColor,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 13,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: AppColors.background.withOpacity(0.34),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.04),
                      ),
                    ),
                    child: Text(
                      worry.content,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 15,
                        height: 1.6,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        _formatDate(worry.createdAt),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                      const Text(
                        '  →  ',
                        style: TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        _formatDate(worry.reviewedAt ?? worry.reviewAt),
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 11,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '눌러서 전체보기',
                        style: TextStyle(
                          color: _statusColor.withOpacity(0.95),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () async {
                          await _confirmDelete(context, ref);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.redAccent.withOpacity(0.12),
                            border: Border.all(
                              color: Colors.redAccent.withOpacity(0.22),
                            ),
                          ),
                          child: const Text(
                            '삭제',
                            style: TextStyle(
                              color: Color(0xFFFF9A9A),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showWorryDetail(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.7),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.92, end: 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            builder: (context, scale, child) {
              return Transform.scale(scale: scale, child: child);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520, maxHeight: 680),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.backgroundSurface,
                      AppColors.backgroundCard,
                    ],
                  ),
                  border: Border.all(
                    color: _statusColor.withOpacity(0.4),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 18),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 30,
                            height: 30,
                            child: PlanetWidget(
                              intensity: worry.intensity,
                              overrideSize: 24,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${worry.intensity.level}단계 걱정',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(
                              Icons.close_rounded,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(999),
                              color: _statusColor.withOpacity(0.16),
                            ),
                            child: Text(
                              _isResolved ? '해결된 걱정' : '아직 남아있는 걱정',
                              style: TextStyle(
                                color: _statusColor,
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              '${_formatDate(worry.createdAt)}  →  ${_formatDate(worry.reviewedAt ?? worry.reviewAt)}',
                              style: const TextStyle(
                                color: AppColors.textHint,
                                fontSize: 11,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          color: AppColors.background.withOpacity(0.38),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Text(
                          worry.content,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            height: 1.7,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            Navigator.of(context).pop();
                            await _confirmDelete(context, ref);
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFFF9A9A),
                            side: BorderSide(
                              color: Colors.redAccent.withOpacity(0.24),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.delete_outline_rounded, size: 18),
                          label: const Text(
                            '이 걱정 삭제하기',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierColor: Colors.black.withOpacity(0.72),
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.backgroundCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: Colors.redAccent.withOpacity(0.16)),
          ),
          title: const Text(
            '이 걱정을 삭제할까요?',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            '삭제하면 은하수 아카이브에서 완전히 사라집니다.',
            style: TextStyle(
              color: AppColors.textSecondary.withOpacity(0.95),
              fontSize: 14,
              height: 1.5,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text(
                '삭제',
                style: TextStyle(
                  color: Color(0xFFFF9A9A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) return;

    await ref.read(worryProvider.notifier).deleteWorry(worry.id);
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
      SnackBar(
        content: const Text(
          '걱정을 삭제했어요',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.backgroundSurface,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month}.${dt.day}';
  }
}
