import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/worry.dart';

class PlanetWidget extends StatelessWidget {
  final WorryIntensity intensity;
  final double? overrideSize;

  const PlanetWidget({
    super.key,
    required this.intensity,
    this.overrideSize,
  });

  double get _size => overrideSize ?? intensity.planetSize;

  @override
  Widget build(BuildContext context) {
    final size = _size;
    return Image.asset(
      'assets/${intensity.level}.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
    );
  }
}

class AnimatedPlanetWidget extends StatefulWidget {
  final Worry worry;
  final VoidCallback onTap;

  const AnimatedPlanetWidget({
    super.key,
    required this.worry,
    required this.onTap,
  });

  @override
  State<AnimatedPlanetWidget> createState() => _AnimatedPlanetWidgetState();
}

class _AnimatedPlanetWidgetState extends State<AnimatedPlanetWidget>
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

    _floatAnim = Tween<double>(begin: -4, end: 4).animate(
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
    final planetSize = intensity.planetSize;
    final itemWidth = (planetSize * 2.2).clamp(100.0, 200.0);

    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _floatAnim,
        builder: (context, _) {
          return Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: SizedBox(
              width: itemWidth,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isReviewable)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
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
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),

                  PlanetWidget(intensity: intensity),

                  const SizedBox(height: 10),

                  Text(
                    '${intensity.level}단계',
                    style: TextStyle(
                      color: _isReviewable
                          ? AppColors.starReviewable
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Text(
                      widget.worry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textHint,
                        fontSize: 11,
                        height: 1.4,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
