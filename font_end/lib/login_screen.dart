import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart'; // 1. Thêm thư viện SDK Google Sign-In
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart'; // Thêm thư viện Facebook
import 'auth_service.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller để quản lý dữ liệu nhập vào
  final TextEditingController _emailController = TextEditingController(text: '');
  final TextEditingController _passwordController = TextEditingController();

  // Khởi tạo lớp dịch vụ gọi API Spring Boot
  final AuthService _authService = AuthService();

  // Biến trạng thái dùng để hiển thị vòng xoay loading khi đang đợi server phản hồi
  bool _isLoading = false;

  // 2. HÀM XỬ LÝ LOGIC ĐĂNG NHẬP TRUYỀN THỐNG (EMAIL/PASSWORD)
  void _handleLogin() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Vui lòng nhập đầy đủ thông tin!', Colors.orange);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var result = await _authService.login(email, password);

    setState(() {
      _isLoading = false;
    });

    if (result != null) {
      String jwtToken = result['token'];
      AuthService.jwtToken = jwtToken;
      String name = result['name'];
      AuthService.userName = name;
      AuthService.userEmail = email;
      AuthService.userPhotoUrl = null;
      _showSnackBar('Đăng nhập thành công! Chào mừng $name', Colors.green);
      print("Token JWT nhận về: $jwtToken");
      
      Future.delayed(const Duration(seconds: 1), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      });
    } else {
      _showSnackBar('Đăng nhập thất bại! Sai tài khoản hoặc lỗi kết nối mạng.', Colors.red);
    }
  }

  // 3. HÀM XỬ LÝ LOGIC ĐĂNG NHẬP BẰNG GOOGLE (MỚI BỔ SUNG)
  void _handleGoogleLogin() async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
    });

    final GoogleSignIn googleSignIn = GoogleSignIn(
      clientId: "517192482027-3a76gplpoqeeaq9df8gicmqhcumlmtdq.apps.googleusercontent.com", // ◄ DÁN VÀO ĐÂY
      scopes: ['email', 'profile'],
    );

    try {
      // Đăng xuất trước để buộc hiển thị bảng chọn tài khoản (Account Picker) mỗi khi bấm
      try {
        await googleSignIn.signOut();
      } catch (e) {
        print("Lỗi khi đăng xuất cũ: $e");
      }
      
      // Kích hoạt hiển thị bảng chọn tài khoản Gmail trên màn hình điện thoại
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isLoading = false;
        });
        return; // Người dùng chủ động bấm hủy thoát nửa chừng
      }

      // Lấy thông tin chứng thực Token bảo mật từ tài khoản vừa chọn
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final String? idToken = googleAuth.idToken;

      if (idToken != null) {
        // Đẩy chuỗi mã Token này qua mạng Wi-Fi xuống endpoint /api/auth/google ở Spring Boot
        var result = await _authService.loginWithGoogle(idToken);

        // Tắt trạng thái loading
        setState(() {
          _isLoading = false;
        });

        if (result != null) {
          // XÁC THỰC CHÉO THÀNH CÔNG VỚI GOOGLE SERVER
          String jwtToken = result['token'];
          AuthService.jwtToken = jwtToken;
          String name = result['name'];
          AuthService.userName = name;
          AuthService.userEmail = googleUser.email;
          AuthService.userPhotoUrl = googleUser.photoUrl;

          _showSnackBar('Đăng nhập Google thành công! Chào mừng $name', Colors.green);
          print("JWT hệ thống cấp sau khi đối chiếu Google: $jwtToken");
          
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            }
          });
        } else {
          _showSnackBar('Server Spring Boot từ chối xác thực tài khoản Google này!', Colors.red);
        }
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Lỗi kích hoạt SDK Google: $error', Colors.red);
      print("Chi tiết lỗi SDK Google: $error");
    }
  }

  // 4. HÀM XỬ LÝ LOGIC ĐĂNG NHẬP BẰNG FACEBOOK
  void _handleFacebookLogin() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['email', 'public_profile'],
      );

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        
        setState(() {
          _isLoading = true;
        });

        var apiResult = await _authService.loginWithFacebook(accessToken.tokenString);

        setState(() {
          _isLoading = false;
        });

        if (apiResult != null) {
          // XÁC THỰC CHÉO THÀNH CÔNG
          String jwtToken = apiResult['token'];
          AuthService.jwtToken = jwtToken;
          String name = apiResult['name'];
          AuthService.userName = name;
          AuthService.userEmail = null;
          AuthService.userPhotoUrl = null;

          _showSnackBar('Đăng nhập Facebook thành công! Chào mừng $name', Colors.green);
          print("JWT hệ thống cấp sau khi đối chiếu Facebook: $jwtToken");
          
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainScreen()),
              );
            }
          });
        } else {
          _showSnackBar('Server Spring Boot từ chối xác thực tài khoản Facebook này!', Colors.red);
        }
      } else if (result.status == LoginStatus.cancelled) {
        // Đã hủy đăng nhập
      } else {
        _showSnackBar('Lỗi đăng nhập Facebook: ${result.message}', Colors.red);
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      _showSnackBar('Lỗi kích hoạt SDK Facebook: $error', Colors.red);
      print("Chi tiết lỗi SDK Facebook: $error");
    }
  }

  // Hàm tiện ích dùng để hiển thị thông báo SnackBar nhanh lên màn hình điện thoại
  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                const Text(
                  'Login',
                  style: TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 32),

                // --- Ô NHẬP EMAIL ---
                _buildInputField(
                  label: 'Email',
                  controller: _emailController,
                  suffixIcon: const Icon(Icons.check, color: Colors.green, size: 22),
                ),
                const SizedBox(height: 16),

                // --- Ô NHẬP PASSWORD ---
                _buildInputField(
                  label: 'Password',
                  controller: _passwordController,
                  isPassword: true,
                ),
                const SizedBox(height: 16),

                // --- QUÊN MẬT KHẨU ---
                Align(
                  alignment: Alignment.centerRight,
                  child: InkWell(
                    onTap: () {
                      // Xử lý khi bấm Quên mật khẩu
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Forgot your password? ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        Icon(
                          Icons.arrow_right_alt,
                          color: Color(0xFFDB3022),
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 28),

                // --- NÚT LOGIN ĐỎ ---
                Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFDB3022).withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFDB3022),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'LOGIN',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                  ),
                ),
                
                const Spacer(), // Đẩy phần Mạng Xã Hội xuống cuối cùng
                const SizedBox(height: 20),

                // --- ĐĂNG NHẬP BẰNG MXH ---
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Or login with social account',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 4. LIÊN KẾT HÀM XỬ LÝ VÀO NÚT GOOGLE ĐỎ TRÒN TẠI ĐÂY
                          _buildSocialButton(
                            isGoogle: true, 
                            onPressed: _isLoading ? () {} : _handleGoogleLogin,
                          ),
                          const SizedBox(width: 20),
                          _buildSocialButton(
                            isGoogle: false, 
                            onPressed: _isLoading ? () {} : _handleFacebookLogin,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20), // Khoảng cách nhỏ ở đáy
                    ],
                  ),
                ),
              ],
            ),
          ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    Widget? suffixIcon,
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Colors.black38),
          ),
          TextField(
            controller: controller,
            obscureText: isPassword,
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 4),
              border: InputBorder.none,
              suffixIcon: suffixIcon,
              suffixIconConstraints: const BoxConstraints(minHeight: 24, minWidth: 24),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({required bool isGoogle, required VoidCallback onPressed}) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        width: 92,
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: isGoogle
              ? Image.asset(
                  'assets/gg.jpg',
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                )
              : const Icon(
                  Icons.facebook, 
                  color: Color(0xFF3B5998), 
                  size: 32,
                ),
        ),
      ),
    );
  }
}