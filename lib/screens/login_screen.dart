import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  // --- التحكم والبيانات ---
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  String _verificationId = "";
  bool _isCodeSent = false;
  bool _isLoading = false;

  // --- أنيميشن التصميم القديم ---
  late AnimationController _starsController;
  final Color goldColor = const Color(0xFFD4AF37);
  late final List<StarLogin> _stars;

  @override
  void initState() {
    super.initState();
    _starsController =
        AnimationController(vsync: this, duration: const Duration(seconds: 60))
          ..repeat();
    _stars = List.generate(50, (index) => StarLogin.random());
  }

  @override
  void dispose() {
    _starsController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --- منطق الـ OTP (التحقق برقم الهاتف) ---
  Future<void> _sendOtp() async {
    if (_phoneController.text.isEmpty || _phoneController.text.length < 9) {
      _showSnackBar("الرجاء إدخال رقم هاتف صحيح");
      return;
    }
    setState(() => _isLoading = true);

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+249${_phoneController.text.trim()}', // مفتاح السودان
      verificationCompleted: (PhoneAuthCredential credential) async {
        await FirebaseAuth.instance.signInWithCredential(credential);
        _onLoginSuccess();
      },
      verificationFailed: (FirebaseAuthException e) {
        setState(() => _isLoading = false);
        _showSnackBar("خطأ: ${e.message}");
      },
      codeSent: (String verId, int? resendToken) {
        setState(() {
          _verificationId = verId;
          _isCodeSent = true;
          _isLoading = false;
        });
      },
      codeAutoRetrievalTimeout: (String verId) => _verificationId = verId,
    );
  }

  Future<void> _verifyOtp() async {
    if (_otpController.text.length < 6) return;
    setState(() => _isLoading = true);
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: _otpController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _onLoginSuccess();
    } catch (e) {
      _showSnackBar("رمز التحقق غير صحيح");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _onLoginSuccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', true);
    if (mounted) Navigator.pushReplacementNamed(context, '/home');
  }

  void _showSnackBar(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg, textAlign: TextAlign.center)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          _buildAnimatedBackground(), // خلفية النجوم الأصلية
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  // شعار Infinity المتحرك
                  TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: const Duration(seconds: 2),
                    builder: (context, double val, child) => Opacity(
                      opacity: val,
                      child:
                          Icon(Icons.all_inclusive, size: 80, color: goldColor),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Infinity Delivery",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2)),
                  const SizedBox(height: 40),

                  // تبديل الواجهة بين إدخال الهاتف وإدخال الرمز
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child:
                        _isCodeSent ? _buildOtpSection() : _buildPhoneSection(),
                  ),

                  const SizedBox(height: 30),
                  if (_isCodeSent)
                    TextButton(
                      onPressed: () => setState(() => _isCodeSent = false),
                      child: Text("تغيير رقم الهاتف؟",
                          style: TextStyle(color: goldColor.withOpacity(0.6))),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- واجهة إدخال الهاتف ---
  Widget _buildPhoneSection() {
    return Column(
      key: const ValueKey(1),
      children: [
        const Text("أدخل رقم هاتفك لتلقي رمز التحقق",
            style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 25),
        _buildCustomField(_phoneController, "9xxxxxxx", Icons.phone_android),
        const SizedBox(height: 25),
        _buildMainButton("إرسال الرمز", _sendOtp),
      ],
    );
  }

  // --- واجهة إدخال الرمز (OTP) ---
  Widget _buildOtpSection() {
    return Column(
      key: const ValueKey(2),
      children: [
        const Text("تم إرسال الرمز إلى هاتفك",
            style: TextStyle(color: Colors.white70)),
        const SizedBox(height: 25),
        _buildCustomField(
            _otpController, "الرمز المكون من 6 أرقام", Icons.lock_open_rounded),
        const SizedBox(height: 25),
        _buildMainButton("تأكيد الرمز والدخول", _verifyOtp),
      ],
    );
  }

  // --- أدوات التصميم (Widgets) ---
  Widget _buildCustomField(
      TextEditingController ctrl, String hint, IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: goldColor.withOpacity(0.3)),
      ),
      child: TextField(
        controller: ctrl,
        keyboardType: TextInputType.phone,
        textAlign: TextAlign.center,
        style: const TextStyle(
            color: Colors.white, fontSize: 18, letterSpacing: 2),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          prefixIcon: Icon(icon, color: goldColor),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildMainButton(String text, VoidCallback action) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: goldColor,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 10,
          shadowColor: goldColor.withOpacity(0.4),
        ),
        onPressed: _isLoading ? null : action,
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.black)
            : Text(text,
                style: const TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _starsController,
      builder: (context, child) {
        for (var star in _stars) {
          star.y -= star.speed;
          if (star.y < -10) star.y = MediaQuery.of(context).size.height + 10;
        }
        return CustomPaint(
            painter: StarPainterLogin(_stars),
            size: MediaQuery.of(context).size);
      },
    );
  }
}

// --- كلاسات النجوم (نفس التصميم القديم) ---
class StarLogin {
  double x, y, speed, opacity;
  StarLogin(this.x, this.y, this.speed, this.opacity);
  factory StarLogin.random() => StarLogin(
      Random().nextDouble() * 500,
      Random().nextDouble() * 1000,
      0.2 + Random().nextDouble() * 0.5,
      0.1 + Random().nextDouble() * 0.4);
}

class StarPainterLogin extends CustomPainter {
  final List<StarLogin> stars;
  StarPainterLogin(this.stars);
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (var star in stars) {
      paint.color = const Color(0xFFD4AF37).withOpacity(star.opacity);
      canvas.drawCircle(Offset(star.x, star.y), 1.5, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
