import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // 1. تعريف المتحكمات للحقول
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  // 2. دالة تسجيل المستخدم الفعلي
  Future<void> _signUp() async {
    // التحقق من إدخال البيانات
    if (_emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _nameController.text.isEmpty) {
      _showError("الرجاء إكمال كافة البيانات");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // أ. إنشاء الحساب في Authentication
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // ب. تخزين بيانات المستخدم الإضافية في Firestore
      // ملاحظة: هذا ما سيجعل المستخدم يظهر في قاعدة بيانات الـ Users لديك
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'uid': userCredential.user!.uid,
        'balance': 0, // رصيد افتتاحي
        'points': 0, // نقاط
        'ordersCount': 0, // عدد طلبات
        'plan': 'عضوية عادية',
        'createdAt': DateTime.now(),
      });

      // ج. الانتقال للشاشة الرئيسية بعد النجاح
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } on FirebaseAuthException catch (e) {
      String msg = "حدث خطأ";
      if (e.code == 'email-already-in-use') msg = "هذا البريد مسجل مسبقاً";
      if (e.code == 'weak-password') msg = "كلمة المرور ضعيفة جداً";
      _showError(msg);
    } catch (e) {
      _showError("فشل الاتصال بالسيرفر: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message, textAlign: TextAlign.center)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A), // متناسق مع تصميم Infinity
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              const Text("∞",
                  style: TextStyle(
                      color: Color(0xFFD4AF37),
                      fontSize: 60,
                      fontWeight: FontWeight.bold)),
              const Text("إنشاء حساب Infinity",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 40),
              _buildInput(_nameController, "الاسم الكامل", Icons.person),
              const SizedBox(height: 15),
              _buildInput(_emailController, "البريد الإلكتروني", Icons.email),
              const SizedBox(height: 15),
              _buildInput(_passwordController, "كلمة المرور", Icons.lock,
                  isPass: true),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator(color: Color(0xFFD4AF37))
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      onPressed: _signUp,
                      child: const Text("إنشاء الحساب",
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                    ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("لديك حساب بالفعل؟ سجل دخولك",
                    style: TextStyle(color: Colors.white54)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon,
      {bool isPass = false}) {
    return TextField(
      controller: ctrl,
      obscureText: isPass,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: const Color(0xFFD4AF37)),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none),
      ),
    );
  }
}
