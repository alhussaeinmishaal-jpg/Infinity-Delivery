import 'package:flutter/material.dart';
import 'dart:math';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  late AnimationController _starsController;
  late List<StarOrder> _stars;
  int _selectedTab = 0;

  final List<Map<String, dynamic>> _currentOrders = [
    {
      'id': 'ORD-001',
      'title': 'وجبة بيتزا - مطعم ماما',
      'date': 'اليوم، 7:30 م',
      'status': 'في الطريق',
      'price': '12,500 ج.س',
      'statusColor': 0xFFD4AF37
    },
    {
      'id': 'ORD-002',
      'title': 'أدوية - صيدلية المنارة',
      'date': 'اليوم، 5:15 م',
      'status': 'تم الاستلام',
      'price': '8,200 ج.س',
      'statusColor': 0xFF4CAF50
    },
  ];
  final List<Map<String, dynamic>> _pastOrders = [
    {
      'id': 'ORD-003',
      'title': 'مشتريات - سوبر ماركت الأمان',
      'date': 'الأمس، 2:00 م',
      'status': 'مكتمل',
      'price': '25,000 ج.س',
      'statusColor': 0xFF4CAF50
    },
    {
      'id': 'ORD-004',
      'title': 'هدية - محل ورد',
      'date': '2025-04-20',
      'status': 'مكتمل',
      'price': '5,500 ج.س',
      'statusColor': 0xFF4CAF50
    },
  ];
  final List<Map<String, dynamic>> _cancelledOrders = [
    {
      'id': 'ORD-005',
      'title': 'وجبة برجر - فاست فود',
      'date': '2025-04-18',
      'status': 'ملغي',
      'price': '9,000 ج.س',
      'statusColor': 0xFFFF4444
    },
  ];

  @override
  void initState() {
    super.initState();
    _starsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat();
    _stars = List.generate(40, (index) => StarOrder.random());
  }

  @override
  void dispose() {
    _starsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBodyBehindAppBar: false,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text("طلباتي",
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
                      painter: StarPainterOrders(_stars), size: size);
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
                      children: [
                        const SizedBox(height: 10),
                        _buildTabs(goldColor),
                        const SizedBox(height: 20),
                        _buildOrdersList(),
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

  Widget _buildTabs(Color gold) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(30)),
      child: Row(
        children: [
          _tabItem(0, "الحالية", gold),
          _tabItem(1, "السابقة", gold),
          _tabItem(2, "الملغاة", gold),
        ],
      ),
    );
  }

  Widget _tabItem(int index, String label, Color gold) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
              color: isActive ? gold : Colors.transparent,
              borderRadius: BorderRadius.circular(25)),
          child: Center(
            child: Text(label,
                style: TextStyle(
                    color: isActive ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold)),
          ),
        ),
      ),
    );
  }

  Widget _buildOrdersList() {
    List<Map<String, dynamic>> orders;
    if (_selectedTab == 0)
      orders = _currentOrders;
    else if (_selectedTab == 1)
      orders = _pastOrders;
    else
      orders = _cancelledOrders;

    if (orders.isEmpty) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(40),
              child: Text("لا توجد طلبات",
                  style: TextStyle(color: Colors.white70))));
    }

    return Column(
        children: orders.map((order) => _buildOrderCard(order)).toList());
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
            offset: Offset(-20 * (1 - value), 0), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF141414).withOpacity(0.8),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order['title'],
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16)),
                  const SizedBox(height: 5),
                  Row(children: [
                    Text(order['date'],
                        style:
                            const TextStyle(color: Colors.grey, fontSize: 12)),
                    const SizedBox(width: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                          color: Color(order['statusColor'] as int)
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20)),
                      child: Text(order['status'],
                          style: TextStyle(
                              color: Color(order['statusColor'] as int),
                              fontSize: 11)),
                    ),
                  ]),
                  const SizedBox(height: 5),
                  Text("المبلغ: ${order['price']}",
                      style: const TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 13,
                          fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const Icon(Icons.arrow_back_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

class StarOrder {
  double x, y;
  final double size, speed, opacity;
  StarOrder(
      {required this.x,
      required this.y,
      required this.size,
      required this.speed,
      required this.opacity});
  factory StarOrder.random() {
    final r = Random();
    return StarOrder(
        x: r.nextDouble() * 500,
        y: r.nextDouble() * 1000,
        size: 1.5 + r.nextDouble() * 2.5,
        speed: 0.3 + r.nextDouble() * 1.2,
        opacity: 0.2 + r.nextDouble() * 0.5);
  }
}

class StarPainterOrders extends CustomPainter {
  final List<StarOrder> stars;
  StarPainterOrders(this.stars);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    for (var s in stars) {
      paint.color = const Color(0xFFD4AF37).withOpacity(s.opacity);
      canvas.drawCircle(Offset(s.x, s.y), s.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
