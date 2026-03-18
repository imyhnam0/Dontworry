import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class StarFieldPainter extends CustomPainter {
  final List<_Star> stars;
  final double shimmerValue;

  StarFieldPainter({required this.stars, required this.shimmerValue});

  @override
  void paint(Canvas canvas, Size size) {
    // Background gradient
    final bgPaint = Paint();
    final bgGradient = const RadialGradient(
      center: Alignment(0.3, -0.5),
      radius: 1.2,
      colors: [
        Color(0xFF141B3A),
        Color(0xFF080B1A),
        Color(0xFF04060F),
      ],
      stops: [0.0, 0.6, 1.0],
    );
    bgPaint.shader = bgGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    // Milky way glow (subtle diagonal band)
    final milkyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: [
          Colors.transparent,
          const Color(0xFF1A2050).withOpacity(0.3),
          const Color(0xFF1A2050).withOpacity(0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.35, 0.65, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), milkyPaint);

    // Draw background stars
    for (final star in stars) {
      final flicker = (sin(shimmerValue * 2 * pi + star.phase) + 1) / 2;
      final opacity = star.baseOpacity + flicker * 0.3 * (1 - star.baseOpacity);
      final paint = Paint()
        ..color = star.color.withOpacity(opacity.clamp(0.0, 1.0))
        ..maskFilter = star.size > 1.2
            ? MaskFilter.blur(BlurStyle.normal, star.size * 0.8)
            : null;
      canvas.drawCircle(
        Offset(star.x * size.width, star.y * size.height),
        star.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(StarFieldPainter oldDelegate) {
    return oldDelegate.shimmerValue != shimmerValue;
  }
}

class _Star {
  final double x;
  final double y;
  final double size;
  final double baseOpacity;
  final double phase;
  final Color color;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.baseOpacity,
    required this.phase,
    required this.color,
  });
}

List<_Star> generateStars(int count, Random rng) {
  final colors = [
    AppColors.starWhite,
    const Color(0xFFCCDDFF),
    const Color(0xFFDDEEFF),
    const Color(0xFFEEDDFF),
  ];
  return List.generate(count, (i) {
    return _Star(
      x: rng.nextDouble(),
      y: rng.nextDouble(),
      size: rng.nextDouble() * 1.2 + 0.3,
      baseOpacity: rng.nextDouble() * 0.5 + 0.1,
      phase: rng.nextDouble(),
      color: colors[rng.nextInt(colors.length)],
    );
  });
}

class AnimatedStarField extends StatefulWidget {
  final Widget child;

  const AnimatedStarField({super.key, required this.child});

  @override
  State<AnimatedStarField> createState() => _AnimatedStarFieldState();
}

class _AnimatedStarFieldState extends State<AnimatedStarField>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<_Star> _stars;

  @override
  void initState() {
    super.initState();
    final rng = Random(42);
    _stars = generateStars(120, rng);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return CustomPaint(
          painter: StarFieldPainter(
            stars: _stars,
            shimmerValue: _controller.value,
          ),
          child: widget.child,
        );
      },
    );
  }
}
