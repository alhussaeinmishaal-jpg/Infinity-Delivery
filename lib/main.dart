import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

// استيراد الشاشات
import 'package:infinity_delivery/screens/splash_screen.dart';
import 'package:infinity_delivery/screens/login_screen.dart';
import 'package:infinity_delivery/screens/register_screen.dart';
import 'package:infinity_delivery/screens/forgot_password_screen.dart';
import 'package:infinity_delivery/screens/home_screen.dart';
import 'package:infinity_delivery/screens/orders_screen.dart';
import 'package:infinity_delivery/screens/membership_screen.dart';
import 'package:infinity_delivery/screens/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. تهيئة Firebase
  try {
    await Firebase.initializeApp();
    debugPrint("✅ تم الاتصال بـ Firebase بنجاح");
  } catch (e) {
    debugPrint("❌ فشل الاتصال بـ Firebase: $e");
  }

  // ملاحظة: أزلنا فحص isLoggedIn من هنا ونقلناه داخل شاشة الأنميشن
  // لضمان ظهور الأنميشن للجميع أولاً.
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Infinity Delivery',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: goldColor,
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: goldColor,
          brightness: Brightness.dark,
        ),
      ),

      // الشاشة الابتدائية هي الأنميشن دائماً لجميع المستخدمين
      initialRoute: '/',

      routes: {
        '/': (context) => const SplashLoader(), // شاشة الأنميشن
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const MainWrapper(),
      },
    );
  }
}

// ================== الهيكل الرئيسي مع الشريط السفلي ==================
// (يبقى كود MainWrapper كما هو دون تغيير)
class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _currentIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const HomeScreen(),
      const OrdersScreen(),
      const MembershipScreen(),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);
    const inactiveColor = Color(0xFF888888);

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.95),
            border: Border(top: BorderSide(color: goldColor.withOpacity(0.3))),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(0, Icons.home_outlined, Icons.home_rounded,
                    "الرئيسية", goldColor, inactiveColor),
                _buildNavItem(1, Icons.shopping_bag_outlined,
                    Icons.shopping_bag, "طلباتي", goldColor, inactiveColor),
                _buildNavItem(2, Icons.attach_money_outlined,
                    Icons.attach_money, "الأسعار", goldColor, inactiveColor),
                _buildNavItem(3, Icons.person_outline_rounded,
                    Icons.person_rounded, "حسابي", goldColor, inactiveColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData inactiveIcon, IconData activeIcon,
      String label, Color active, Color inactive) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: isActive ? active.withOpacity(0.15) : Colors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) =>
                  ScaleTransition(scale: animation, child: child),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                key: ValueKey(isActive),
                color: isActive ? active : inactive,
                size: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? active : inactive,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}