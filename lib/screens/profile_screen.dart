import 'package:flutter/material.dart';
import 'dart:math';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late List<StarProfile> _stars;

  String userName = "حسين علي";
  String userPlan = "الباقة البلاتينية";
  String userBalance = "50,000";
  String remainingOrders = "28";

  @override
  void initState() {
    super.initState();
    _starsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat();
    _stars = List.generate(40, (index) => StarProfile.random());
  }

  @override
  void dispose() {
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const goldGlow = Color(0xFFFFD700);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("حسابي",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: false,
        ),
        body: Stack(
          children: [
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
                      painter: StarPainterProfile(_stars), size: size);
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.3,
                  colors: [
                    Color(0xFF1A1A2E),
                    Color(0xFF0A0A0A),
                    Color(0xFF000000)
                  ],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding:
                        const EdgeInsetsDirectional.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 10),
                        _buildProfileHeader(goldColor, goldGlow),
                        const SizedBox(height: 25),
                        _buildBalanceCard(goldColor, goldGlow),
                        const SizedBox(height: 30),
                        const Text("الإعدادات",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        const SizedBox(height: 15),
                        _buildMenuItem(Icons.wallet, "محفظتي",
                            "$userBalance ج.س", goldColor),
                        _buildMenuItem(Icons.payment, "طرق الدفع",
                            "بطاقة، محفظة، نقدي", goldColor),
                        _buildMenuItem(Icons.notifications, "الإشعارات",
                            "تفعيل الإشعارات", goldColor),
                        _buildMenuItem(
                            Icons.language, "اللغة", "العربية", goldColor),
                        _buildMenuItem(Icons.help_outline, "الدعم الفني",
                            "مركز المساعدة", goldColor),
                        const SizedBox(height: 10),
                        _buildMenuItem(
                            Icons.logout, "تسجيل الخروج", "", goldColor,
                            isLogout: true),
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

  Widget _buildProfileHeader(Color gold, Color goldGlow) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)), child: child)),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [gold, goldGlow]),
              boxShadow: [
                BoxShadow(
                    color: gold.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4)
              ],
            ),
            child: const Center(
                child: Icon(Icons.person, color: Colors.black, size: 50)),
          ),
          const SizedBox(height: 12),
          Text(userName,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
                color: gold.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: gold.withOpacity(0.3))),
            child: Text(userPlan,
                style: const TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(Color gold, Color goldGlow) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)), child: child)),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFF1A1A2E).withOpacity(0.9),
            const Color(0xFF16213E).withOpacity(0.9)
          ], begin: Alignment.topRight, end: Alignment.bottomLeft),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: gold.withOpacity(0.4), width: 1.5),
          boxShadow: [
            BoxShadow(
                color: goldGlow.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 2)
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("رصيدك الحالي",
                  style: TextStyle(color: Colors.white70, fontSize: 14)),
              const SizedBox(height: 5),
              Text("$userBalance ج.س",
                  style: TextStyle(
                      color: gold, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                    color: gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text("⭐ الباقة البلاتينية",
                    style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
              ),
            ]),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              const Text("طلبات متبقية",
                  style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 5),
              Text(remainingOrders,
                  style: TextStyle(
                      color: gold, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Container(
                width: 80,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(2)),
                child: Container(
                  width: (double.parse(remainingOrders) / 30) * 80,
                  height: 4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [gold, goldGlow]),
                      borderRadius: BorderRadius.circular(2)),
                ),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(
      IconData icon, String title, String subtitle, Color gold,
      {bool isLogout = false}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(-20 * (1 - value), 0), child: child)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFF141414).withOpacity(0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: ListTile(
          leading:
              Icon(icon, color: isLogout ? Colors.redAccent : gold, size: 28),
          title: Text(title,
              style: TextStyle(
                  color: isLogout ? Colors.redAccent : Colors.white,
                  fontWeight: FontWeight.w500)),
          subtitle: subtitle.isNotEmpty
              ? Text(subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12))
              : null,
          trailing: isLogout
              ? null
              : const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
          onTap: () {
            if (isLogout)
              _showTopToast("تسجيل الخروج");
            else
              _showTopToast("فتح $title");
          },
        ),
      ),
    );
  }

  void _showTopToast(String message) {
    final overlay = Overlay.of(context);
    final entry = OverlayEntry(
      builder: (context) => Positioned(
        top: MediaQuery.of(context).padding.top + 10,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: -80.0, end: 0.0),
            duration: const Duration(milliseconds: 500),
            curve: Curves.elasticOut,
            builder: (context, val, child) =>
                Transform.translate(offset: Offset(0, val), child: child),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFFFD700)]),
                    borderRadius: BorderRadius.circular(40)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.black, size: 20),
                    const SizedBox(width: 10),
                    Flexible(
                        child: Text(message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.black,
                                fontWeight: FontWeight.bold))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(entry);
    Future.delayed(const Duration(seconds: 2), entry.remove);
  }
}

class StarProfile {
  double x, y;
  final double size, speed, opacity;
  StarProfile(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.opacity});
  factory StarProfile.random() {
    final r = Random();
    return StarProfile(
        x: r.nextDouble() * 500,
        y: r.nextDouble() * 1000,
        size: 1.5 + r.nextDouble() * 2.5,
        speed: 0.3 + r.nextDouble() * 1.2,
        opacity: 0.2 + r.nextDouble() * 0.5);
  }
}

class StarPainterProfile extends CustomPainter {
  final List<StarProfile> stars;
  StarPainterProfile(this.stars);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var s in stars) {
      paint.color = const Color(0xFFD4AF37).withOpacity(s.opacity);
      canvas.drawCircle(Offset(s.x, s.y), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainterProfile oldDelegate) => true;
}
