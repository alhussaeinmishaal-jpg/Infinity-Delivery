import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  bool _isLoading = true;
  late AnimationController _pulseController;
  late final AnimationController _starsController;
  late final List<StarHome> _stars;
  final ScrollController _scrollController = ScrollController();

  // بيانات ثابتة (يمكن استبدالها لاحقاً من Firestore أيضاً)
  final List<Map<String, dynamic>> _activeOrders = const [
    {
      'icon': '🍕',
      'title': 'وجبة بيتزا - مطعم ماما',
      'status': 'في الطريق',
      'time': '8 دقائق',
      'statusColor': 0xFFD4AF37
    },
    {
      'icon': '💊',
      'title': 'أدوية - صيدلية المنارة',
      'status': 'تم الاستلام',
      'time': '15 دقيقة',
      'statusColor': 0xFF4CAF50
    },
    {
      'icon': '📦',
      'title': 'هدية - محل ورد',
      'status': 'قيد التجهيز',
      'time': '25 دقيقة',
      'statusColor': 0xFFFF9800
    },
  ];
  final List<Map<String, dynamic>> _offers = const [
    {
      'title': 'خصم 30% على أول طلب',
      'subtitle': 'كود: WELCOME30',
      'emoji': '🎉'
    },
    {
      'title': 'توصيل مجاني فوق 10,000 ج.س',
      'subtitle': 'ساري حتى نهاية الشهر',
      'emoji': '🚚'
    },
    {'title': 'البلاتينيوم خصم 15%', 'subtitle': 'لمدة محدودة', 'emoji': '⭐'},
  ];
  final List<Map<String, dynamic>> _services = const [
    {'icon': Icons.restaurant, 'name': 'مطاعم'},
    {'icon': Icons.local_pharmacy, 'name': 'صيدلية'},
    {'icon': Icons.shopping_basket, 'name': 'متاجر'},
    {'icon': Icons.description, 'name': 'مستندات'},
    {'icon': Icons.card_giftcard, 'name': 'هدايا'},
    {'icon': Icons.more_horiz, 'name': 'المزيد'},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    _pulseController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
    _starsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat();
    _stars = List.generate(60, (index) => StarHome.random());
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _starsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (mounted) setState(() => _isLoading = false);
  }

  // دالة لجلب بيانات المستخدم بشكل مباشر (Stream)
  Stream<DocumentSnapshot> _getUserDataStream() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return Stream.empty();
    return FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .snapshots();
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
          title: Row(
            children: [
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                        colors: [Color(0xFFD4AF37), Color(0xFFFFD700)])
                    .createShader(bounds),
                child: const Text("∞",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              const SizedBox(width: 8),
              const Text("Infinity Delivery",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            CircleAvatar(
                radius: 18,
                backgroundColor: goldColor.withOpacity(0.15),
                child: Icon(Icons.person, color: goldColor, size: 20)),
          ],
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
                      painter: StarPainterHome(_stars), size: size);
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
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: AnimatedOpacity(
                    opacity: _isLoading ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 500),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // ✅ هنا استخدمنا StreamBuilder لعرض الرصيد والخطة والطلبات المتبقية
                          _buildBalanceCard(goldColor, goldGlow),
                          const SizedBox(height: 20),
                          _buildMapPreview(goldColor),
                          const SizedBox(height: 25),
                          _buildSectionHeader("🚀 خدمات سريعة", () {}),
                          const SizedBox(height: 15),
                          _buildQuickServices(goldColor, goldGlow),
                          const SizedBox(height: 25),
                          _buildSectionHeader("🎁 عروض خاصة", () {}),
                          const SizedBox(height: 15),
                          _isLoading
                              ? _buildShimmerCarousel()
                              : _buildOffersCarousel(goldColor),
                          const SizedBox(height: 25),
                          _buildSectionHeader("📦 طلبات نشطة", () {}),
                          const SizedBox(height: 15),
                          _isLoading
                              ? _buildShimmerOrders()
                              : _buildActiveOrders(goldColor),
                          const SizedBox(height: 100),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        floatingActionButton: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) => Transform.scale(
            scale: 1 + _pulseController.value * 0.05,
            child: Container(
              decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [
                BoxShadow(
                    color: goldGlow.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 4)
              ]),
              child: FloatingActionButton.extended(
                onPressed: () => _showQuickOrderSheet(context),
                backgroundColor: goldColor,
                icon: const Icon(Icons.bolt, color: Colors.black, size: 28),
                label: const Text("طلب سريع",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ================== بطاقة الرصيد المعدلة (باستخدام StreamBuilder) ==================
  Widget _buildBalanceCard(Color gold, Color goldGlow) {
    return _animateSlideUp(
      child: StreamBuilder<DocumentSnapshot>(
        stream: _getUserDataStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _buildStaticBalanceCard(
                gold, goldGlow); // Fallback إلى بيانات ثابتة
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerBalanceCard(); // شيمر أثناء التحميل
          }
          // استخراج البيانات من Firestore
          var userData = snapshot.data?.data() as Map<String, dynamic>?;
          String balance = userData?['balance']?.toString() ?? "0";
          String plan = userData?['plan'] ?? "عادي";
          int remainingOrders = userData?['remainingOrders'] ?? 0;

          return Container(
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
                  Text("$balance ج.س",
                      style: TextStyle(
                          color: gold,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20)),
                    child: Text("⭐ $plan",
                        style: const TextStyle(
                            color: Color(0xFFD4AF37), fontSize: 12)),
                  ),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text("طلبات متبقية",
                      style: TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 5),
                  Text("$remainingOrders",
                      style: TextStyle(
                          color: gold,
                          fontSize: 28,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: 80,
                    height: 4,
                    decoration: BoxDecoration(
                        color: Colors.grey[800],
                        borderRadius: BorderRadius.circular(2)),
                    child: Container(
                      width:
                          remainingOrders > 0 ? (remainingOrders / 30) * 80 : 0,
                      height: 4,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(colors: [gold, goldGlow]),
                          borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // بطاقة احتياطية (في حال فشل تحميل البيانات)
  Widget _buildStaticBalanceCard(Color gold, Color goldGlow) {
    return Container(
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
              color: goldGlow.withOpacity(0.1), blurRadius: 20, spreadRadius: 2)
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("رصيدك الحالي",
                style: TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 5),
            Text("0 ج.س",
                style: TextStyle(
                    color: gold, fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20)),
              child: const Text("⭐ عادي",
                  style: TextStyle(color: Color(0xFFD4AF37), fontSize: 12)),
            ),
          ]),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            const Text("طلبات متبقية",
                style: TextStyle(color: Colors.white70, fontSize: 12)),
            const SizedBox(height: 5),
            const Text("0",
                style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 28,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: 80,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[800],
                  borderRadius: BorderRadius.circular(2)),
              child: Container(
                  width: 0,
                  height: 4,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [gold, goldGlow]),
                      borderRadius: BorderRadius.circular(2))),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildShimmerBalanceCard() {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: Container(
        height: 130,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(24)),
      ),
    );
  }

  // ================== باقي الوظائف (كما هي دون تغيير) ==================
  Widget _buildMapPreview(Color gold) {
    return _animateSlideUp(
      delay: 100,
      child: GestureDetector(
        onTap: () => _showTopToast("فتح الخريطة التفاعلية"),
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: gold.withOpacity(0.4), width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: gold.withOpacity(0.2), blurRadius: 15, spreadRadius: 2)
            ],
            image: const DecorationImage(
              image: NetworkImage(
                  'https://upload.wikimedia.org/wikipedia/commons/thumb/9/9a/Sudan_Map.svg/800px-Sudan_Map.svg.png'),
              fit: BoxFit.cover,
              opacity: 0.7,
            ),
          ),
          child: Stack(children: [
            Positioned(
              bottom: 12,
              left: 12,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(20)),
                child: const Text("📍 موقعك: بورتسودان - حي المطار",
                    style: TextStyle(color: Colors.white, fontSize: 12)),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _buildShimmerCarousel() {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: Container(
          height: 140,
          width: double.infinity,
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(20))),
    );
  }

  Widget _buildShimmerOrders() {
    return Shimmer.fromColors(
      baseColor: Colors.white10,
      highlightColor: Colors.white24,
      child: Column(
        children: List.generate(
            2,
            (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 80,
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20)))),
      ),
    );
  }

  Widget _buildOffersCarousel(Color gold) {
    return SizedBox(
      height: 140,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _offers.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (context, index) {
          final offer = _offers[index];
          return _animateSlideUp(
            delay: 200 + index * 50,
            child: Container(
              width: MediaQuery.of(context).size.width - 80,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [const Color(0xFF1A0A0A), const Color(0xFF2A1515)],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: gold.withOpacity(0.3), width: 1.5),
                boxShadow: [
                  BoxShadow(color: gold.withOpacity(0.15), blurRadius: 15)
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(offer['title'],
                            style: const TextStyle(
                                color: Color(0xFFD4AF37),
                                fontWeight: FontWeight.bold,
                                fontSize: 15)),
                        const SizedBox(height: 5),
                        Text(offer['subtitle'],
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ]),
                  Text(offer['emoji'], style: const TextStyle(fontSize: 42)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildQuickServices(Color gold, Color goldGlow) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 15,
        crossAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemCount: _services.length,
      itemBuilder: (context, index) {
        final service = _services[index];
        return _animateScale(index * 50,
            child: GestureDetector(
              onTap: () => _showTopToast("فتح ${service['name']}"),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: [gold.withOpacity(0.1), Colors.transparent],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: gold.withOpacity(0.2)),
                      boxShadow: [
                        BoxShadow(
                            color: goldGlow.withOpacity(0.1), blurRadius: 10)
                      ],
                    ),
                    child: Icon(service['icon'] as IconData,
                        color: gold, size: 32),
                  ),
                  const SizedBox(height: 8),
                  Text(service['name'],
                      style:
                          const TextStyle(color: Colors.white, fontSize: 12)),
                ],
              ),
            ));
      },
    );
  }

  Widget _buildActiveOrders(Color gold) {
    return Column(
      children: _activeOrders.asMap().entries.map((entry) {
        int idx = entry.key;
        var order = entry.value;
        return _animateSlideRight(
          delay: idx * 80,
          child: GestureDetector(
            onTap: () => _showTopToast("تفاصيل الطلب: ${order['title']}"),
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF141414).withOpacity(0.7),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Text(order['icon'], style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(order['title'],
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Color(order['statusColor'] as int)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(order['status'],
                                  style: TextStyle(
                                      color: Color(order['statusColor'] as int),
                                      fontSize: 11)),
                            ),
                            const SizedBox(width: 10),
                            Text("الوصول خلال ${order['time']}",
                                style: const TextStyle(
                                    color: Colors.grey, fontSize: 11)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_back_ios,
                      color: Colors.grey, size: 16),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSectionHeader(String title, VoidCallback onTap) {
    return Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(title,
          style: const TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
      TextButton(
        onPressed: onTap,
        child: const Text("عرض الكل ←",
            style: TextStyle(color: Color(0xFFD4AF37), fontSize: 13)),
      ),
    ]);
  }

  Widget _animateSlideUp({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 500 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(0, 30 * (1 - value)), child: child)),
      child: child,
    );
  }

  Widget _animateScale(int delay, {required Widget child}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutBack,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.scale(scale: 0.9 + value * 0.1, child: child)),
      child: child,
    );
  }

  Widget _animateSlideRight({required Widget child, int delay = 0}) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 400 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
          opacity: value,
          child: Transform.translate(
              offset: Offset(-20 * (1 - value), 0), child: child)),
      child: child,
    );
  }

  void _showQuickOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151515),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) => Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
          height: 280,
          padding: const EdgeInsets.all(25),
          child: Column(
            children: [
              const Text("بدء طلب جديد",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 15),
              const Text("حدد نوع الخدمة التي تريدها",
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 25),
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _quickOrderType(Icons.restaurant, "مطعم"),
                _quickOrderType(Icons.local_pharmacy, "صيدلية"),
                _quickOrderType(Icons.shopping_basket, "متجر"),
              ]),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD4AF37),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50)),
                ),
                child: const Text("تحديد الموقع والبدء",
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickOrderType(IconData icon, String label) {
    return Column(children: [
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(15)),
        child: Icon(icon, color: const Color(0xFFD4AF37), size: 30),
      ),
      const SizedBox(height: 8),
      Text(label, style: const TextStyle(color: Colors.white)),
    ]);
  }

  void _showTopToast(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
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
            builder: (context, value, child) =>
                Transform.translate(offset: Offset(0, value), child: child),
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFD4AF37), Color(0xFFFFD700)]),
                  borderRadius: BorderRadius.circular(40),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 12)
                  ],
                ),
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
                                fontWeight: FontWeight.bold,
                                fontSize: 14))),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
    overlay.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 2), () => overlayEntry.remove());
  }
}

class StarHome {
  double x, y;
  final double size;
  final double speed;
  final double opacity;
  StarHome(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.opacity});
  factory StarHome.random() {
    final random = Random();
    return StarHome(
      x: random.nextDouble() * 500,
      y: random.nextDouble() * 1000,
      size: 1.5 + random.nextDouble() * 2.5,
      speed: 0.3 + random.nextDouble() * 1.2,
      opacity: 0.2 + random.nextDouble() * 0.5,
    );
  }
}

class StarPainterHome extends CustomPainter {
  final List<StarHome> stars;
  StarPainterHome(this.stars);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var star in stars) {
      paint.color = const Color(0xFFD4AF37).withOpacity(star.opacity);
      canvas.drawCircle(Offset(star.x, star.y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant StarPainterHome oldDelegate) => true;
}
