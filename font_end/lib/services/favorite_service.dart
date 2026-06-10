import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:font_end/models/product.dart';
import 'package:font_end/auth_service.dart';

class FavoriteService {
  static const String baseUrl = "http://192.168.1.29:8080/api/favorites";

  // Lấy danh sách sản phẩm yêu thích
  Future<List<Product>> getFavorites() async {
    if (AuthService.jwtToken == null) return [];
    
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        // Dữ liệu giả định trả về list các Product hoặc một Wrapper chứa Product
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        return body.map((dynamic item) {
          // Thường thì bảng Favorites sẽ chứa các thông tin của Product
          // Giả sử API trả về trực tiếp mảng Product:
          return Product.fromJson(item);
        }).toList();
      } else {
        print("Lỗi lấy favorites: ${response.statusCode}");
      }
    } catch (e) {
      print("Exception lấy favorites: $e");
    }
    return [];
  }

  // Thêm sản phẩm vào yêu thích
  Future<bool> addFavorite(String productId) async {
    if (AuthService.jwtToken == null) return false;
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/$productId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Exception thêm favorite: $e");
    }
    return false;
  }

  // Xóa sản phẩm khỏi yêu thích
  Future<bool> removeFavorite(String productId) async {
    if (AuthService.jwtToken == null) return false;
    
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$productId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print("Exception xóa favorite: $e");
    }
    return false;
  }

  // Kiểm tra xem sản phẩm đã được yêu thích chưa
  Future<bool> checkFavorite(String productId) async {
    if (AuthService.jwtToken == null) return false;
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/check/$productId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return response.body == 'true';
      }
    } catch (e) {
      print("Exception check favorite: $e");
    }
    return false;
  }
}
