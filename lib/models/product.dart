class Product {
  final int id;
  final String name;
  final String tagline;
  final String description;
  final String price;
  final String currency;
  final String image;
  final Map<String, String> specs;

  Product({
    required this.id,
    required this.name,
    required this.tagline,
    required this.description,
    required this.price,
    required this.currency,
    required this.image,
    required this.specs,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final rawSpecs = json['specs'] as Map<String, dynamic>? ?? {};
    final specs = rawSpecs.map((key, value) => MapEntry(key, value.toString()));

    return Product(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      tagline: json['tagline'] as String? ?? '',
      description: json['description'] as String? ?? '',
      price: json['price'] as String? ?? '',
      currency: json['currency'] as String? ?? 'USD',
      image: json['image'] as String? ?? '',
      specs: specs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagline': tagline,
      'description': description,
      'price': price,
      'currency': currency,
      'image': image,
      'specs': specs,
    };
  }

  /// Returns the category based on product name
  String get category {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('iphone') || lowerName.contains('phone se')) {
      return 'iPhone';
    } else if (lowerName.contains('macbook')) {
      return 'MacBook';
    } else if (lowerName.contains('ipad')) {
      return 'iPad';
    } else if (lowerName.contains('imac')) {
      return 'iMac';
    } else if (lowerName.contains('watch')) {
      return 'Watch';
    } else if (lowerName.contains('airpods')) {
      return 'AirPods';
    } else if (lowerName.contains('vision')) {
      return 'Vision Pro';
    } else if (lowerName.contains('homepod')) {
      return 'HomePod';
    }
    return 'Diğer';
  }

  /// Numeric price for calculations
  double get numericPrice {
    final cleaned = price.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleaned) ?? 0.0;
  }
}
