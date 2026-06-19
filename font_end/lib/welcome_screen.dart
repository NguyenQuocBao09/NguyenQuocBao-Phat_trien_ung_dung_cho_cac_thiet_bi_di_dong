import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9), // Màu nền xám trắng nhẹ như ảnh
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // Tên ứng dụng "E-Commerce" bôi đậm lớn
              const Text(
                'E-Commerce',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const Spacer(), // Đẩy phần chữ chào mừng và nút bấm xuống giữa/dưới màn hình
              // Dòng chữ chào mừng nhỏ ở giữa
              const Center(
                child: Text(
                  'Welcome to our store',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // --- NÚT SIGN UP ---
              _buildPrimaryButton(
                text: 'SIGN UP',
                onPressed: () {
                  // Điều hướng sang màn hình Đăng ký (RegisterScreen)
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24), // Khoảng cách giữa 2 nút như ảnh
              // --- NÚT LOGIN ---
              _buildPrimaryButton(
                text: 'LOGIN',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget dùng chung để tạo Nút Đỏ (SIGN UP / LOGIN) có đổ bóng chuẩn
  Widget _buildPrimaryButton({
    required String text,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: double.infinity,
      height: 56, // Chiều cao nút chuẩn UI thiết kế
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28), // Bo tròn tối đa 2 đầu nút
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFFDB3022,
            ).withOpacity(0.25), // Đổ bóng màu đỏ nhạt mềm mại
            blurRadius: 8,
            offset: const Offset(0, 4), // Đổ bóng hướng xuống dưới
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(
            0xFFDB3022,
          ), // Màu đỏ chuẩn theo ảnh của bạn
          foregroundColor: Colors.white,
          elevation:
              0, // Tắt hiệu ứng shadow mặc định của ElevatedButton để dùng Container shadow mượt hơn
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }


}
