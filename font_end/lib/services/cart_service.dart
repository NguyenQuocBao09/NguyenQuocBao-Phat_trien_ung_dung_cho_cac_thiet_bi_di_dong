import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:font_end/auth_service.dart';
import 'package:font_end/models/cart_item.dart';

class CartService extends ChangeNotifier {
  static const String baseUrl = "http://172.16.7.193:8080/api/cart";
  List<CartItem> _items = [];

  List<CartItem> get items => _items;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> fetchCart() async {
    if (AuthService.jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
        _items = body.map((dynamic item) => CartItem.fromJson(item)).toList();
        notifyListeners();
      }
    } catch (e) {
      print("Lỗi tải giỏ hàng: $e");
    }
  }

  Future<bool> addToCart(String productId, String color, String size, int quantity) async {
    if (AuthService.jwtToken == null) return false;

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/add'),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
        body: jsonEncode({
          "productId": productId,
          "color": color,
          "size": size,
          "quantity": quantity,
        }),
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
        return true;
      }
    } catch (e) {
      print("Lỗi thêm vào giỏ: $e");
    }
    return false;
  }

  Future<void> updateQuantity(String cartItemId, int quantity) async {
    if (AuthService.jwtToken == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/update/$cartItemId?quantity=$quantity'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      }
    } catch (e) {
      print("Lỗi cập nhật số lượng: $e");
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    if (AuthService.jwtToken == null) return;

    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/remove/$cartItemId'),
        headers: {
          "Authorization": "Bearer ${AuthService.jwtToken!}",
        },
      );

      if (response.statusCode == 200) {
        await fetchCart(); // Refresh cart
      }
    } catch (e) {
      print("Lỗi xóa khỏi giỏ: $e");
    }
  }
}

final CartService cartService = CartService();
