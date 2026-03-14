import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

class ApiService {
  static const String _baseUrl = 'https://wantapi.com';
  static const String _productsEndpoint = '/products.php';
  static const String bannerUrl = '$_baseUrl/assets/banner.png';

  /// Fetches products from the API
  static Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl$_productsEndpoint'),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        if (jsonData['status'] == 'success') {
          final List<dynamic> productsJson = jsonData['data'] as List<dynamic>;
          return productsJson
              .map((json) => Product.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('API returned error status');
        }
      } else {
        throw Exception('Failed to load products: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}
