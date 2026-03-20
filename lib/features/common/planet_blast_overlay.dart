import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../data/models/worry.dart';
import '../home/widgets/worry_planet_widget.dart';

/// Full-screen one-shot animation used when a worry is sent to the Milky Way.
Future<void> showPlanetBlastDialog(
  BuildContext context, {
  required WorryIntensity intensity,
  required bool isResolved,
}) {
  final accent = isResolved ? AppColors.starResolved : AppColors.accentPink;

  return showGeneralDialog(
    context: context,
    barrierLabel: 'planet-blast',
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.2),
    pageBuilder: (_, __, ___) => _PlanetBlastOverlay(
      intensity: intensity,
      accent: accent,
    ),
    transitionDuration: const Duration(milliseconds: 120),
  );
}

class _PlanetBlastOverlay extends StatefulWidget {
  final WorryIntensity intensity;
  final Color accent;

  const _PlanetBlastOverlay({
    required this.intensity,
    required this.accent,
  });

  @override
  State<_PlanetBlastOverlay> createState() => _PlanetBlastOverlayState();
}

class _PlanetBlastOverlayState extends State<_PlanetBlastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<double> _angles;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pop();
      }
    });

    final r = Random(widget.intensity.index + DateTime.now().millisecondsSinceEpoch);
    _angles = List.generate(14, (_) => r.nextDouble() * pi * 2);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) {
            final t = Curves.easeOutQuart.transform(_controller.value);
            final fadeT = Curves.easeIn.transform(_controller.value);

            final planetScale = 1 - fadeT * 0.65;
            final planetOpacity = (1 - fadeT * 1.2).clamp(0.0, 1.0);

            final shockRadius = 80 + (180 * t);
            final shockOpacity = (1 - t).clamp(0.0, 1.0);

            return SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildDust(t),

                  // Shockwave ring
                  Container(
                    width: shockRadius,
                    height: shockRadius,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.accent.withOpacity(0.65 * shockOpacity),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: widget.accent.withOpacity(0.20 * shockOpacity),
                          blurRadius: 24,
                          spreadRadius: 6,
                        ),
                      ],
                    ),
                  ),

                  // Planet shrinking
                  Opacity(
                    opacity: planetOpacity,
                    child: Transform.scale(
                      scale: planetScale,
                      child: PlanetWidget(intensity: widget.intensity),
                    ),
                  ),

                  // Blasting shards
                  ...List.generate(_angles.length, (i) {
                    final angle = _angles[i];
                    final dist = 20 + (140 * t) * (0.7 + i / _angles.length * 0.6);
                    final size = (8 * (1 - fadeT)).clamp(2.0, 8.0);
                    return Transform.translate(
                      offset: Offset(
                        cos(angle) * dist,
                        sin(angle) * dist,
                      ),
                      child: _Shard(
                        color: widget.accent,
                        size: size,
                        opacity: (1 - fadeT).clamp(0.0, 1.0),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDust(double t) {
    final dots = List.generate(18, (i) {
      final angle = _angles[i % _angles.length] + (i * 0.35);
      final dist = 30 + (120 * t) * (0.5 + (i % 7) / 10);
      final opacity = (1 - t) * 0.5;
      return Positioned(
        left: 140 + cos(angle) * dist,
        top: 140 + sin(angle) * dist,
        child: Container(
          width: 3,
          height: 3,
          decoration: BoxDecoration(
            color: widget.accent.withOpacity(opacity.clamp(0.0, 0.6)),
            shape: BoxShape.circle,
          ),
        ),
      );
    });

    return SizedBox.expand(
      child: Stack(children: dots),
    );
  }
}

class _Shard extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Shard({
    required this.color,
    required this.size,
    required this.opacity,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withOpacity(0.9),
              color.withOpacity(0.2),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.35),
              blurRadius: 8,
              spreadRadius: 2,
            )
          ],
        ),
      ),
    );
  }
}
