import 'dart:math';
import 'package:flutter/material.dart';

class StarField extends StatefulWidget {
  final int starCount;
  const StarField({super.key, this.starCount = 120});

  @override
  State<StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<StarField>
    with SingleTickerProviderStateMixin {
  late List<_Star> stars;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    stars = List.generate(widget.starCount, (index) => _Star.random());
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
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
      builder: (context, child) {
        final size = MediaQuery.of(context).size;
        for (var star in stars) {
          star.y -= star.speed;
          if (star.y < -10) {
            star.y = size.height + 10;
            star.x = Random().nextDouble() * size.width;
          }
        }
        return CustomPaint(
          painter: StarPainter(stars: stars),
          size: Size.infinite,
        );
      },
    );
  }
}

class _Star {
  double x, y;
  final double size;
  final double speed;
  final double opacity;
  final Color color;

  _Star({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.opacity,
    required this.color,
  });

  factory _Star.random() {
    final random = Random();
    return _Star(
      x: random.nextDouble() * 500,
      y: random.nextDouble() * 1000,
      size: 2 + random.nextDouble() * 4,
      speed: 0.5 + random.nextDouble() * 2,
      opacity: 0.3 + random.nextDouble() * 0.5,
      color: Colors.amber,
    );
  }
}

class StarPainter extends CustomPainter {
  final List<_Star> stars;

  StarPainter({required this.stars});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var star in stars) {
      paint.color = star.color.withOpacity(star.opacity);
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainter oldDelegate) => true;
}
