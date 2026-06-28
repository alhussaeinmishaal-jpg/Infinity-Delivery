import 'package:flutter/material.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _phoneController = TextEditingController();

  // قاعدة بيانات تجريبية للأرقام المسجلة فعلياً في Infinity Delivery
  final List<String> _registeredNumbers = ["0912345678", "0123456789"];

  void _verifyAndSendCode() {
    String phone = _phoneController.text.trim();

    // 1. التحقق من أن الحقل ليس فارغاً
    if (phone.isEmpty) {
      _showSnackBar("يرجى إدخال رقم الهاتف أولاً", Colors.redAccent);
      return;
    }

    // 2. التحقق مما إذا كان الرقم مسجلاً في النظام
    if (_registeredNumbers.contains(phone)) {
      // الحالة: الرقم موجود ومسجل
      _showSnackBar("تم العثور على حسابك، جاري إرسال رمز التحقق إلى $phone",
          Colors.green);
    } else {
      // الحالة: الرقم غير موجود (مستخدم جديد)
      _showSnackBar("هذا الرقم غير مسجل لدينا، يرجى إنشاء حساب جديد أولاً",
          Colors.orange);
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.right),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFD4AF37);

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: goldColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_reset_rounded,
                    size: 100, color: goldColor),
                const SizedBox(height: 30),
                const Text(
                  "استعادة الحساب",
                  style: TextStyle(
                      color: goldColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 15),
                const Text(
                  "أدخل رقم هاتفك لنتأكد من وجود حسابك وإرسال رمز الاستعادة",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const SizedBox(height: 40),

                // حقل رقم الهاتف
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: "رقم الهاتف",
                    labelStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.phone, color: goldColor),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: goldColor),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // زر التحقق والإرسال
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _verifyAndSendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: goldColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      "تحقق من الحساب",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("العودة لتسجيل الدخول",
                      style: TextStyle(color: Colors.white54)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
