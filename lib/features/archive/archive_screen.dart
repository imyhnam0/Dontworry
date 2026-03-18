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

class _ArchiveCard extends StatelessWidget {
  final Worry worry;
  const _ArchiveCard({required this.worry});

  bool get _isResolved => worry.reviewAnswer == ReviewAnswer.resolved;

  Color get _statusColor =>
      _isResolved ? AppColors.starResolved : AppColors.accentPink;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: AppColors.backgroundCard.withOpacity(0.7),
        border: Border.all(color: AppColors.divider),
      ),
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
                '${worry.intensity.level}단계',
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: _statusColor.withOpacity(0.15),
                ),
                child: Text(
                  _isResolved ? '해결' : '미해결',
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            worry.content,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              height: 1.5,
              fontWeight: FontWeight.w300,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
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
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.year}.${dt.month}.${dt.day}';
  }
}
