import 'package:flutter/material.dart';
import 'dart:math';

class MembershipScreen extends StatefulWidget {
  const MembershipScreen({super.key});

  @override
  State<MembershipScreen> createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late List<StarMember> _stars;

  // تعريف البيانات الأساسية للخطط
  final List<Map<String, dynamic>> _plans = [
    {
      'name': 'فضي',
      'price': '16,320',
      'currency': 'ج.س',
      'color': 0xFFC0C0C0,
      'features': ['تغطية الأحياء', 'تتبع الطلبات'],
      'leftSide': ['تقارير أداء', 'أولوية توصيل'],
      'popular': false
    },
    {
      'name': 'ذهبي',
      'price': '33,680',
      'currency': 'ج.س',
      'color': 0xFFD4AF37,
      'features': ['تغطية الأحياء', 'دعم واتساب'],
      'leftSide': ['أولوية التوصيل', 'التوصيل المسبق'],
      'popular': true
    },
    {
      'name': 'بلاتيني',
      'price': '58,160',
      'currency': 'ج.س',
      'color': 0xFFE5E4E2,
      'features': ['دعم 24/7', 'مدير حساب خاص'],
      'leftSide': ['تحليلات متقدمة', 'أولوية قصوى'],
      'popular': false
    },
  ];

  @override
  void initState() {
    super.initState();
    _starsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat();
    _stars = List.generate(40, (index) => StarMember.random());
  }

  @override
  void dispose() {
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // تم تغيير const إلى final لحل مشكلة الخط الأحمر في الصور
    final Color goldColor = const Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.black, // ضمان خلفية داكنة متناسقة
        appBar: AppBar(
          title: const Text("خطط العضوية",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Stack(
          children: [
            // تأثير النجوم المتحركة في الخلفية
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _starsController,
                builder: (context, child) {
                  final size = MediaQuery.of(context).size;
                  for (var star in _stars) {
                    star.y -= star.speed;
                    if (star.y < -10) {
                      star.y = size.height + 10;
                      star.x = Random().nextDouble() * size.width;
                    }
                  }
                  return CustomPaint(
                      painter: StarPainterMember(_stars, goldColor),
                      size: size);
                },
              ),
            ),

            // محتوى القائمة القابل للتمرير
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        ..._plans.map((plan) => _buildPlanCard(plan)),
                        const SizedBox(height: 50),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(Map<String, dynamic> plan) {
    final bool isPopular = plan['popular'] as bool;
    final Color mainColor = Color(plan['color'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
            colors: [mainColor.withOpacity(0.15), Colors.black87],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: mainColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(color: mainColor.withOpacity(0.1), blurRadius: 20)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(plan['name'],
                      style: TextStyle(
                          color: mainColor,
                          fontSize: 22,
                          fontWeight: FontWeight.bold)),
                  if (isPopular) const SizedBox(width: 10),
                  if (isPopular)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(20)),
                      child: const Text("الأكثر طلباً",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("${plan['price']} ${plan['currency']}",
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  Text(
                      "لكل شهر", // تم تثبيت كلمة الشهر كما في التحديثات السابقة
                      style: TextStyle(color: mainColor, fontSize: 11)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (plan['features'] as List)
                          .map((f) => _featureItem(f))
                          .toList())),
              Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: (plan['leftSide'] as List)
                          .map((f) => _featureItem(f))
                          .toList())),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
                backgroundColor: mainColor,
                foregroundColor: Colors.black,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))),
            child: const Text("اشتراك",
                style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _featureItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
          const SizedBox(width: 6),
          Text(text,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}

class StarMember {
  double x, y;
  final double size, speed, opacity;
  StarMember(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.opacity});

  factory StarMember.random() {
    final r = Random();
    return StarMember(
        x: r.nextDouble() * 500,
        y: r.nextDouble() * 1000,
        size: 1.5 + r.nextDouble() * 2.5,
        speed: 0.3 + r.nextDouble() * 1.2,
        opacity: 0.2 + r.nextDouble() * 0.5);
  }
}

class StarPainterMember extends CustomPainter {
  final List<StarMember> stars;
  final Color starColor;
  StarPainterMember(this.stars, this.starColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var s in stars) {
      paint.color = starColor.withOpacity(s.opacity);
      canvas.drawCircle(Offset(s.x, s.y), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
