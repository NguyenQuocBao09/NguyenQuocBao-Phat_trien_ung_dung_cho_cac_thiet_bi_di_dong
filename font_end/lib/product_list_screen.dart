import 'package:flutter/material.dart';
import 'services/product_service.dart';
import 'models/product.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  final String categoryName;

  const ProductListScreen({super.key, required this.categoryName});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  bool isGridView = false;

  final List<String> chips = ['T-shirts', 'Crop tops', 'Sleeveless', 'Blouses'];

  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = ProductService().fetchTopRatedProductsByCategory(widget.categoryName);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          "Women's ${widget.categoryName.toLowerCase()}",
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // 1. Chips Row
          Container(
            height: 40,
            margin: const EdgeInsets.only(top: 12, bottom: 12),
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: chips.length,
              separatorBuilder: (context, index) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    chips[index],
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                );
              },
            ),
          ),

          // 2. Filter Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: const Color(0xFFF9F9F9),
            child: Row(
              children: [
                const Icon(Icons.filter_list, size: 24),
                const SizedBox(width: 8),
                const Text('Filters', style: TextStyle(fontSize: 14)),
                const Spacer(),
                const Icon(Icons.swap_vert, size: 24),
                const SizedBox(width: 8),
                const Text('Price: lowest to high', style: TextStyle(fontSize: 14)),
                const Spacer(),
                IconButton(
                  icon: Icon(isGridView ? Icons.view_list : Icons.grid_view, size: 24),
                  onPressed: () {
                    setState(() {
                      isGridView = !isGridView;
                    });
                  },
                ),
              ],
            ),
          ),

          // 3. Product List / Grid
          Expanded(
            child: RefreshIndicator(
              color: const Color(0xFFDB3022),
              onRefresh: () async {
                setState(() {
                  _productsFuture = ProductService().fetchTopRatedProductsByCategory(widget.categoryName);
                });
                await _productsFuture;
              },
              child: FutureBuilder<List<Product>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Color(0xFFDB3022)));
                  } else if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("Có lỗi xảy ra khi tải sản phẩm.")),
                      ]
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: const [
                        SizedBox(height: 200),
                        Center(child: Text("Không có sản phẩm nào có đánh giá tốt.")),
                      ]
                    );
                  }

                  final products = snapshot.data!;
                  return isGridView ? _buildGridView(products) : _buildListView(products);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Product> products) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
            );
          },
          child: Container(
            height: 140, // Tăng chiều cao để chứa đủ 2 dòng tên sản phẩm
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
            ],
          ),
          child: Row(
            children: [
              // Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                ),
                child: Image.asset(
                  product.imageUrl ?? 'assets/new.jpg',
                  width: 110,
                  height: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 110,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, color: Colors.grey),
                  ),
                ),
              ),
              // Details
              Expanded(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            product.brand ?? 'Lumina',
                            style: const TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const Spacer(),
                          // Rating
                          Row(
                            children: [
                              ...List.generate(5, (starIndex) {
                                double rating = product.rating ?? 0.0;
                                return Icon(
                                  starIndex < rating.floor()
                                      ? Icons.star
                                      : Icons.star_border,
                                  color: Colors.amber,
                                  size: 14,
                                );
                              }),
                              const SizedBox(width: 4),
                              Text('(${product.reviewCount ?? 0})',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                          const Spacer(),
                          // Price
                          Row(
                            children: [
                              if (product.price != null)
                                Text(
                                  '\$${product.price?.toStringAsFixed(0)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              if (product.price != null) const SizedBox(width: 4),
                              Text(
                                '\$${product.salePrice != null ? product.salePrice?.toStringAsFixed(0) : product.price?.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: product.price != null
                                      ? const Color(0xFFDB3022)
                                      : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Favorite button
                    Positioned(
                      bottom: -16,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.all(8),
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
                          Icons.favorite_border,
                          color: Colors.grey,
                          size: 20,
                        ),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ));
      },
    );
  }

  Widget _buildGridView(List<Product> products) {
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.52,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProductDetailScreen(product: product)),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image area
            Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    product.imageUrl ?? 'assets/new.jpg',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
                  ),
                ),
                // Discount Badge
                if (product.price != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFDB3022),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${(((product.price ?? 1) - (product.salePrice ?? 0)) / (product.price == null || product.price == 0 ? 1 : product.price!) * 100).round()}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                // Favorite Button
                Positioned(
                  bottom: -16,
                  right: 0,
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
                      Icons.favorite_border,
                      color: Colors.grey,
                      size: 20,
                    ),
                  ),
                )
              ],
            ),
            const SizedBox(height: 16), // space for the floating favorite button
            // Rating
            Row(
              children: [
                ...List.generate(5, (starIndex) {
                  double rating = product.rating ?? 0.0;
                  return Icon(
                    starIndex < rating.floor()
                        ? Icons.star
                        : Icons.star_border,
                    color: Colors.amber,
                    size: 14,
                  );
                }),
                const SizedBox(width: 4),
                Text('(${product.reviewCount ?? 0})',
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            // Brand
            Text(
              product.brand ?? 'Lumina',
              style: const TextStyle(color: Colors.grey, fontSize: 11),
            ),
            const SizedBox(height: 4),
            // Name
            Text(
              product.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Price
            Row(
              children: [
                if (product.price != null)
                  Text(
                    '\$${product.price?.toStringAsFixed(0)}',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                if (product.price != null) const SizedBox(width: 4),
                Text(
                  '\$${product.salePrice != null ? product.salePrice?.toStringAsFixed(0) : product.price?.toStringAsFixed(0)}',
                  style: TextStyle(
                    color: product.price != null
                        ? const Color(0xFFDB3022)
                        : Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ));
      },
    );
  }
}
