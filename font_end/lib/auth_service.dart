import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static String? jwtToken;
  static String? userName;
  static String? userEmail;
  static String? userPhotoUrl;
  // THAY ĐỔI IP NÀY THÀNH IP MẠNG WI-FI THẬT CỦA MÁY TÍNH BẠN (Xem lại ipconfig)
  static const String baseUrl = "http://172.16.7.193:8080/api/auth";

  // 1. Logic gọi API Đăng ký tài khoản
  Future<String?> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return "SUCCESS"; // Thành công
      } else {
        return response.body; // Trả về thông báo lỗi từ Spring Boot
      }
    } catch (e) {
      return "Không thể kết nối không dây tới Server. Hãy kiểm tra Wi-Fi hoặc IP!";
    }
  }

  // 2. Logic gọi API Đăng nhập truyền thống
  Future<Map<String, dynamic>?> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "email": email,
          "password": password,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Trả về cục dữ liệu chứa Token JWT
      } else {
        print("Đăng nhập thất bại: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithGoogle(String idToken) async {
    final url = Uri.parse('$baseUrl/google'); // Sẽ gọi đến endpoint /api/auth/google ở Spring Boot
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": idToken // Gửi mã ID Token mà điện thoại vừa lấy được từ Google sang Spring Boot
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Nhận về chuỗi JWT riêng của hệ thống bạn
      } else {
        print("Spring Boot từ chối xác thực token: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối không dây khi đăng nhập Google: $e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginWithFacebook(String accessToken) async {
    final url = Uri.parse('$baseUrl/facebook'); // Sẽ gọi đến endpoint /api/auth/facebook ở Spring Boot
    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "token": accessToken // Gửi mã Access Token mà điện thoại lấy được từ Facebook
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body); // Nhận về chuỗi JWT riêng của hệ thống bạn
      } else {
        print("Spring Boot từ chối xác thực token Facebook: ${response.body}");
        return null;
      }
    } catch (e) {
      print("Lỗi kết nối không dây khi đăng nhập Facebook: $e");
      return null;
    }
  }
}