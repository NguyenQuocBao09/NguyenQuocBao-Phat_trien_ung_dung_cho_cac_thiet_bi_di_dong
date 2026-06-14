import 'package:flutter/material.dart';
import 'dart:async';
import 'models/product.dart';
import 'services/product_service.dart';
import 'services/favorite_service.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductService _productService = ProductService();
  late Future<List<Product>> _newProductsFuture;
  late Future<List<Product>> _saleProductsFuture;
  Set<String> _favoriteProductIds = {};

  int _currentSlide = 0;
  late Timer _timer;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _newProductsFuture = _productService.fetchNewProducts();
    _saleProductsFuture = _productService.fetchSaleProducts();
    _loadFavorites();
    FavoriteService.favoritesChangedNotifier.addListener(_onFavoritesChanged);

    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (_currentSlide < 2) {
        _currentSlide++;
      } else {
        _currentSlide = 0;
      }
      
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentSlide,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _onFavoritesChanged() {
    _loadFavorites();
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    FavoriteService.favoritesChangedNotifier.removeListener(_onFavoritesChanged);
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    try {
      final favorites = await FavoriteService().getFavorites();
      if (mounted) {
        setState(() {
          _favoriteProductIds = favorites.where((p) => p.id != null).map((p) => p.id!).toSet();
        });
      }
    } catch (e) {
      // Ignore if not logged in or error
    }
  }

  void _toggleFavorite(String productId) async {
    final isCurrentlyFavorite = _favoriteProductIds.contains(productId);
    setState(() {
      if (isCurrentlyFavorite) {
        _favoriteProductIds.remove(productId);
      } else {
        _favoriteProductIds.add(productId);
      }
    });

    bool success;
    if (isCurrentlyFavorite) {
      success = await FavoriteService().removeFavorite(productId);
    } else {
      success = await FavoriteService().addFavorite(productId);
    }

    if (!success && mounted) {
      setState(() {
        if (isCurrentlyFavorite) {
          _favoriteProductIds.add(productId);
        } else {
          _favoriteProductIds.remove(productId);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to update favorites')),
      );
    } else if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isCurrentlyFavorite ? 'Removed from favorites' : 'Added to favorites'),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: RefreshIndicator(
        color: const Color(0xFFDB3022),
        onRefresh: () async {
          setState(() {
            _newProductsFuture = _productService.fetchNewProducts();
            _saleProductsFuture = _productService.fetchSaleProducts();
          });
          await Future.wait([_newProductsFuture, _saleProductsFuture, _loadFavorites()]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. BANNER SLIDESHOW
              _buildSlideshowBanner(),

              // 2. MỤC "NEW" VÀ DANH SÁCH SẢN PHẨM
              _buildSectionHeader('New', 'You\'ve never seen it before!'),
              _buildProductList(_newProductsFuture, isNew: true),


              // 4. MỤC "SALE" VÀ DANH SÁCH SẢN PHẨM
              _buildSectionHeader('Sale', 'Super summer sale'),
              _buildProductList(_saleProductsFuture, isSale: true),

              const SizedBox(height: 30),

              // 5. COLLAGE CÁC BỘ SƯU TẬP KHÁC
              _buildCollageSection(),
            ],
          ),
        ),
      ),
    );
  }

  // Widget vẽ Slideshow
  Widget _buildSlideshowBanner() {
    final List<Map<String, dynamic>> slides = [
      {'title': 'Fashion\nsale', 'image': 'assets/sls1.png', 'hasButton': true},
      {'title': 'Summer\ncollection', 'image': 'assets/sls2.png', 'hasButton': false},
      {'title': 'New\narrivals', 'image': 'assets/sls3.jpg', 'hasButton': true},
    ];

    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentSlide = index;
              });
            },
            itemCount: slides.length,
            itemBuilder: (context, index) {
              final slide = slides[index];
              return _buildTopBanner(slide['title'], slide['image'], hasCheckButton: slide['hasButton']);
            },
          ),
          // Chấm tròn báo hiệu (Indicators)
          Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentSlide == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentSlide == index ? const Color(0xFFDB3022) : Colors.grey,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget vẽ Banner ngang
  Widget _buildTopBanner(String title, String imagePath, {bool hasCheckButton = false}) {
    return Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey[300], // Màu nền tạm thời nếu không có ảnh
        image: DecorationImage(
          image: AssetImage(imagePath), // Bạn cần copy ảnh vào thư mục assets
          fit: BoxFit.cover,
          onError: (exception, stackTrace) {}, // Ẩn lỗi nếu chưa có ảnh
        ),
      ),
      child: Container(
        // Hiệu ứng làm tối ảnh nhẹ để chữ nổi bật lên
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.black.withOpacity(0.6), Colors.transparent],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        padding: const EdgeInsets.only(left: 16, bottom: 30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.1,
              ),
            ),
            if (hasCheckButton) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: 160,
                height: 36,
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB3022),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Check',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget vẽ Tiêu đề cho các phần New / Sale
  Widget _buildSectionHeader(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const Text(
            'View all',
            style: TextStyle(
              fontSize: 11,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Widget vẽ danh sách trượt ngang của sản phẩm (lấy từ API)
  Widget _buildProductList(Future<List<Product>> future, {bool isNew = false, bool isSale = false}) {
    return FutureBuilder<List<Product>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 280,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 280,
            child: Center(child: Text('Lỗi tải dữ liệu: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const SizedBox(
            height: 150,
            child: Center(child: Text('Chưa có sản phẩm nào (Database rỗng)', style: TextStyle(color: Colors.grey))),
          );
        }

        final products = snapshot.data!;

        return SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _buildProductCard(product, isNew: isNew, isSale: isSale);
            },
          ),
        );
      },
    );
  }

  // Widget vẽ Từng thẻ Sản Phẩm
  Widget _buildProductCard(Product product, {bool isNew = false, bool isSale = false}) {
    final bool isFavorite = product.id != null && _favoriteProductIds.contains(product.id!);
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
        );
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Phần Hình Ảnh và Badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 184,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: product.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: product.imageUrl!.startsWith('assets/')
                            ? Image.asset(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                              )
                            : Image.network(
                                product.imageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, color: Colors.grey),
                              ),
                      )
                    : const Icon(Icons.image, color: Colors.grey),
              ),
              // Badge NEW hoặc % SALE
              if (isNew || isSale)
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isNew ? Colors.black : const Color(0xFFDB3022),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isNew ? 'NEW' : '-${(((product.price ?? 1) - (product.salePrice ?? 0)) / (product.price == null || product.price == 0 ? 1 : product.price!) * 100).round()}%',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              // Nút Favorite trái tim
              Positioned(
                bottom: -16, // Tràn ra nửa ngoài
                right: 0,
                child: GestureDetector(
                  onTap: () {
                    if (product.id != null) {
                      _toggleFavorite(product.id!);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? const Color(0xFFDB3022) : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 8),

          // Đánh giá sao
          Row(
            children: [
              ...List.generate(5, (index) => Icon(
                    index < (product.rating ?? 0).floor() ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  )),
              const SizedBox(width: 4),
              Text('(${product.reviewCount ?? 0})', style: const TextStyle(fontSize: 10, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),

          // Tên thương hiệu
          Text(
            product.brand ?? 'Thương hiệu',
            style: const TextStyle(fontSize: 11, color: Colors.grey),
          ),
          const SizedBox(height: 4),

          // Tên sản phẩm
          Text(
            product.name,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Giá
          Row(
            children: [
              if (product.price != null)
                Text(
                  '${product.price}\$',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              if (product.price != null) const SizedBox(width: 4),
              Text(
                '${product.salePrice ?? product.price ?? 0}\$',
                style: TextStyle(
                  fontSize: 14,
                  color: product.price != null ? const Color(0xFFDB3022) : Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    ));
  }

  // Widget lưới ảnh (Collage) ở phần cuối
  Widget _buildCollageSection() {
    return Column(
      children: [
        // Ảnh 1: New collection ngang to
        Container(
          width: double.infinity,
          height: 300,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/nc.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                bottom: 20,
                right: 20,
                child: Text(
                  'New collection',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.5), blurRadius: 4, offset: const Offset(0, 2))
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        // Nửa dưới chia 2 cột
        Row(
          children: [
            // Cột trái
            Expanded(
              child: Column(
                children: [
                  Container(
                    height: 150,
                    width: double.infinity,
                    color: Colors.white,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.only(left: 20),
                    child: const Text(
                      'Summer\nsale',
                      style: TextStyle(
                        color: Color(0xFFDB3022),
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        height: 1.1,
                      ),
                    ),
                  ),
                  Container(
                    height: 150,
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage('assets/black.jpg'),
                        fit: BoxFit.cover,
                      ),
                    ),
                    alignment: Alignment.bottomLeft,
                    padding: const EdgeInsets.all(20),
                    child: const Text(
                      'Black',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Cột phải
            Expanded(
              child: Container(
                height: 300,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/womens_hoodie_new.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Women\'s\nCoats',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    height: 1.1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
