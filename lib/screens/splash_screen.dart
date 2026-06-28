import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // إضافة المكتبة المطلوبة

class SplashLoader extends StatefulWidget {
  const SplashLoader({super.key});

  @override
  State<SplashLoader> createState() => _SplashLoaderState();
}

class _SplashLoaderState extends State<SplashLoader>
    with TickerProviderStateMixin {
  late AnimationController _ringsController;
  late AnimationController _glowController;
  late AnimationController _progressController;
  Timer? _typingTimer;
  String _displayedText = '';
  int _currentIndex = 0;
  final String _fullText = "INFINITY DELIVERY";

  @override
  void initState() {
    super.initState();

    _ringsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..forward();

    _progressController.addListener(() {
      setState(() {});
    });

    _startTyping();

    // تعديل منطق الانتقال ليكون ذكياً (يفحص حالة الدخول لجميع المستخدمين)
    Timer(const Duration(milliseconds: 5800), () {
      _checkUserStatusAndNavigate();
    });
  }

  // دالة فحص حالة المستخدم والتوجيه
  Future<void> _checkUserStatusAndNavigate() async {
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // إذا كان مسجلاً مسبقاً يذهب للرئيسية فوراً بعد الأنميشن
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // إذا كان جديداً يذهب لصفحة تسجيل الدخول
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _startTyping() {
    const totalDuration = 4500;
    final interval = totalDuration ~/ _fullText.length;
    _typingTimer = Timer.periodic(Duration(milliseconds: interval), (timer) {
      if (_currentIndex < _fullText.length) {
        if (mounted) {
          setState(() {
            _displayedText = _fullText.substring(0, _currentIndex + 1);
            _currentIndex++;
          });
        }
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _ringsController.dispose();
    _glowController.dispose();
    _progressController.dispose();
    _typingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          const StarFieldBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFD4AF37).withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 240,
                      height: 240,
                      child: RotatingRings(controller: _ringsController),
                    ),
                    AnimatedBuilder(
                      animation: _glowController,
                      builder: (context, child) {
                        return Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFD4AF37)
                                    .withOpacity(0.2 * _glowController.value),
                                blurRadius: 40,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                          child: Transform.scale(
                            scale: 1.0 + (_glowController.value * 0.03),
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                AnimatedText(
                  displayedText: _displayedText,
                  fullText: _fullText,
                ),
                const Text(
                  "سرعة_و_دقة//وخدمه في كل حته#",
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 13,
                    letterSpacing: 4,
                    fontWeight: FontWeight.w300,
                  ),
                ),
                const SizedBox(height: 60),
                Column(
                  children: [
                    SizedBox(
                      width: 200,
                      height: 3,
                      child: LinearProgressIndicator(
                        value: _progressController.value,
                        backgroundColor: Colors.white10,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFFD4AF37)),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      "${(_progressController.value * 100).toInt()}% جاري التحميل",
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 10,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- المكونات الفرعية ---

class RotatingRings extends StatelessWidget {
  final AnimationController controller;
  const RotatingRings({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            _buildRing(controller.value * 2 * pi, 230, 0.2, [0, 1]),
            _buildRing(-controller.value * 2 * pi, 190, 0.15, [2, 3]),
          ],
        );
      },
    );
  }

  Widget _buildRing(
      double angle, double size, double opacity, List<int> sides) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: const Color(0xFFD4AF37).withOpacity(opacity), width: 1),
        ),
        child: CircularProgressIndicator(
          value: 0.25,
          strokeWidth: 2,
          color: const Color(0xFFD4AF37).withOpacity(opacity * 2),
        ),
      ),
    );
  }
}

class AnimatedText extends StatelessWidget {
  final String displayedText;
  final String fullText;
  const AnimatedText(
      {super.key, required this.displayedText, required this.fullText});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Text(
        displayedText + (displayedText.length < fullText.length ? "_" : ""),
        style: const TextStyle(
          color: Color(0xFFD4AF37),
          fontSize: 24,
          fontWeight: FontWeight.bold,
          letterSpacing: 3,
          fontFamily: 'Courier',
        ),
      ),
    );
  }
}

class StarFieldBackground extends StatefulWidget {
  const StarFieldBackground({super.key});
  @override
  State<StarFieldBackground> createState() => _StarFieldBackgroundState();
}

class _StarFieldBackgroundState extends State<StarFieldBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Star> stars = List.generate(100, (index) => Star.random());

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1))
          ..repeat();
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
          star.y += star.speed;
          if (star.y > size.height) {
            star.y = 0;
            star.x = Random().nextDouble() * size.width;
          }
        }
        return CustomPaint(painter: StarPainter(stars: stars), size: size);
      },
    );
  }
}

class Star {
  double x, y;
  final double size, speed, opacity;
  Star(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.opacity});
  factory Star.random() => Star(
        x: Random().nextDouble() * 500, // تعديل ليشمل عرض الشاشات الأكبر
        y: Random().nextDouble() * 1000,
        size: 1 + Random().nextDouble() * 2,
        speed: 0.5 + Random().nextDouble() * 2,
        opacity: 0.1 + Random().nextDouble() * 0.4,
      );
}

class StarPainter extends CustomPainter {
  final List<Star> stars;
  StarPainter({required this.stars});
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    // تم تغيير اللون هنا من الأبيض إلى الذهبي
    const Color starGoldColor = Color(0xFFD4AF37);

    for (var star in stars) {
      paint.color = starGoldColor.withOpacity(star.opacity);
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}