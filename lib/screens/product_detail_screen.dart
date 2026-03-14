import 'package:flutter/material.dart';
import '../main.dart';
import '../models/product.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _contentController;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;
  bool _addedToCart = false;

  @override
  void initState() {
    super.initState();
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOut,
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    ));
    _contentController.forward();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  void _addToCart(Product product) {
    final cart = CartInherited.of(context);
    cart.addItem(product);
    setState(() {
      _addedToCart = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Color(0xFF30D158), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${product.name} sepete eklendi',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2C2C2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
        action: SnackBarAction(
          label: 'Sepete Git',
          textColor: const Color(0xFF007AFF),
          onPressed: () => Navigator.pushNamed(context, '/cart'),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _addedToCart = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final product = ModalRoute.of(context)!.settings.arguments as Product;
    final cart = CartInherited.of(context);
    final isInCart = cart.isInCart(product.id);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildImageHeader(product),
              SliverToBoxAdapter(
                child: SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: _buildContent(product),
                  ),
                ),
              ),
            ],
          ),
          _buildBottomBar(product, isInCart),
        ],
      ),
    );
  }

  Widget _buildImageHeader(Product product) {
    return SliverAppBar(
      expandedHeight: 380,
      pinned: true,
      backgroundColor: const Color(0xFF1C1C1E),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 18, color: Colors.white),
        ),
      ),
      actions: [
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/cart'),
          child: Container(
            margin: const EdgeInsets.all(8),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.shopping_bag_outlined,
                size: 20, color: Colors.white),
          ),
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    const Color(0xFF1C1C1E),
                    const Color(0xFF2C2C2E).withOpacity(0.5),
                    Colors.black,
                  ],
                ),
              ),
            ),
            // Product image
            Hero(
              tag: 'product-${product.id}',
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(40, 60, 40, 40),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              Color(0xFF007AFF)),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported_rounded,
                        size: 80,
                        color: Color(0xFF8E8E93),
                      );
                    },
                  ),
                ),
              ),
            ),
            // Bottom gradient for text readability
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Product product) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF007AFF).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              product.category,
              style: const TextStyle(
                color: Color(0xFF007AFF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Product name
          Text(
            product.name,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.5,
              color: Colors.white,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 8),

          // Tagline
          Text(
            product.tagline,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.3,
              color: Colors.white.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 20),

          // Price
          Text(
            product.price,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              letterSpacing: -1.0,
              color: Color(0xFF007AFF),
            ),
          ),
          const SizedBox(height: 28),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFF38383A),
          ),
          const SizedBox(height: 28),

          // Specs
          const Text(
            'Teknik Özellikler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          _buildSpecsList(product.specs),
          const SizedBox(height: 28),

          // Divider
          Container(
            height: 1,
            color: const Color(0xFF38383A),
          ),
          const SizedBox(height: 28),

          // Description
          const Text(
            'Açıklama',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.5,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            product.description,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              height: 1.6,
              letterSpacing: -0.2,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecsList(Map<String, String> specs) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF38383A),
          width: 0.5,
        ),
      ),
      child: Column(
        children: specs.entries.toList().asMap().entries.map((entry) {
          final index = entry.key;
          final spec = entry.value;
          final isLast = index == specs.length - 1;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatSpecKey(spec.key),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.5),
                      ),
                    ),
                    Text(
                      spec.value,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  height: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 18),
                  color: const Color(0xFF38383A),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  String _formatSpecKey(String key) {
    switch (key.toLowerCase()) {
      case 'chip':
        return 'İşlemci';
      case 'material':
        return 'Malzeme';
      case 'camera':
        return 'Kamera';
      case 'display':
        return 'Ekran';
      case 'battery':
        return 'Batarya';
      case 'weight':
        return 'Ağırlık';
      case 'design':
        return 'Tasarım';
      case 'ports':
        return 'Portlar';
      case 'colors':
        return 'Renkler';
      case 'screen':
        return 'Ekran';
      case 'pencil':
        return 'Apple Pencil';
      case 'connectivity':
        return 'Bağlantı';
      case 'case':
        return 'Kasa';
      case 'brightness':
        return 'Parlaklık';
      case 'gps':
        return 'GPS';
      case 'feature':
        return 'Özellik';
      case 'carbon':
        return 'Karbon';
      case 'os':
        return 'İşletim Sistemi';
      case 'control':
        return 'Kontrol';
      case 'audio':
        return 'Ses';
      case 'driver':
        return 'Sürücü';
      case 'cancellation':
        return 'Gürültü Engelleme';
      case 'materials':
        return 'Malzemeler';
      case 'home':
        return 'Ev';
      case 'sensing':
        return 'Algılama';
      case 'size':
        return 'Boyut';
      case 'id':
        return 'Kimlik';
      default:
        return key[0].toUpperCase() + key.substring(1);
    }
  }

  Widget _buildBottomBar(Product product, bool isInCart) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.8),
              Colors.black,
            ],
            stops: const [0.0, 0.3, 1.0],
          ),
        ),
        child: Row(
          children: [
            // Price
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Fiyat',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  Text(
                    product.price,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -1.0,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            // Add to cart button
            GestureDetector(
              onTap: () => _addToCart(product),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: _addedToCart
                        ? [const Color(0xFF30D158), const Color(0xFF34C759)]
                        : [const Color(0xFF007AFF), const Color(0xFF5856D6)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: (_addedToCart
                              ? const Color(0xFF30D158)
                              : const Color(0xFF007AFF))
                          .withOpacity(0.4),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _addedToCart
                          ? Icons.check_rounded
                          : Icons.shopping_bag_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _addedToCart ? 'Eklendi' : 'Sepete Ekle',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.3,
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
}
