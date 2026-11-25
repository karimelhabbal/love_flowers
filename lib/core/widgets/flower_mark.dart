import 'dart:math';

import 'package:flutter/material.dart';

import '../../app/theme/app_theme.dart';

/// Hand-drawn brand mark: an elegant stem with a rose and two leaves.
class FlowerMark extends StatelessWidget {
  const FlowerMark({super.key, this.size = 64, this.showShadow = false});

  final double size;
  final bool showShadow;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: showShadow
            ? BoxDecoration(
                color: AppColors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sage.withValues(alpha: 0.16),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              )
            : const BoxDecoration(),
        child: CustomPaint(painter: _FlowerMarkPainter()),
      ),
    );
  }
}

class _FlowerMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.shortestSide / 100;
    canvas.save();
    canvas.scale(scale, scale);
    canvas.translate(50, 50);

    final stem = Paint()
      ..color = AppColors.sage
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.4
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, 38)
      ..cubicTo(-2, 12, 6, -6, 2, -24);
    canvas.drawPath(path, stem);

    final leafPaint = Paint()..color = AppColors.sage;
    final leftLeaf = Path()
      ..moveTo(-1, 16)
      ..cubicTo(-20, 20, -30, 8, -30, -4)
      ..cubicTo(-14, -2, -3, 4, -1, 16);
    final rightLeaf = Path()
      ..moveTo(0, 4)
      ..cubicTo(16, 6, 26, -4, 26, -16)
      ..cubicTo(12, -14, 2, -8, 0, 4);
    canvas.drawPath(leftLeaf, leafPaint);
    canvas.drawPath(rightLeaf, leafPaint..color = AppColors.sage.withValues(alpha: 0.78));

    final petalPaint = Paint()..color = AppColors.rose;
    for (var i = 0; i < 6; i++) {
      final angle = (i / 6) * 2 * pi;
      final center = Offset(cos(angle) * 11, -32 + sin(angle) * 9);
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 17, height: 22),
        petalPaint,
      );
    }
    canvas.drawCircle(
      Offset(0, -32),
      7.5,
      Paint()..color = AppColors.blush,
    );
    canvas.drawCircle(
      Offset(0, -32),
      3,
      Paint()..color = AppColors.rose,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlowerMark(size: compact ? 44 : 72),
        const SizedBox(height: 8),
        Text(
          'Love Flowers',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 2),
        Text(
          'زهور الحب',
          textDirection: TextDirection.rtl,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.rose,
              ),
        ),
      ],
    );
  }
}
