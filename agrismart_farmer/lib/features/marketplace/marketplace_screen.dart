import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../features/auth/auth_service.dart';
import 'marketplace_models.dart';
import 'widgets/shimmer_product.dart';
import 'widgets/heart_beat_button.dart';

class MarketplaceScreen extends ConsumerStatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  ConsumerState<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends ConsumerState<MarketplaceScreen> {
  String selectedCategory = 'All';
  bool _isLoading = true;
  List<Product> _products = [];
  final List<String> categories = ['All', 'Biens', 'Seeds', 'Fertilizer', 'Tools', 'Vegetables', 'Fruits'];
  
  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    setState(() => _isLoading = true);
    final service = ref.read(marketplaceServiceProvider);
    final results = await service.getProducts();
    if (mounted) {
      setState(() {
        _products = results;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);
    final myEmail = user?.email ?? '';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text('AgriSmart Marché'),
          actions: [
            Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.mail_outline),
                  onPressed: () => context.push('/chat/inbox'),
                  tooltip: 'Messagerie',
                ),
                // Notification Badge Effect
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(minWidth: 8, minHeight: 8),
                  ),
                ),
              ],
            ),
            IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
            if (user?.role?.toUpperCase() == 'VIEWER')
              IconButton(
                icon: const Icon(Icons.logout_rounded, color: Colors.red),
                onPressed: () async {
                  await ref.read(authServiceProvider).logout();
                  ref.read(authStateProvider.notifier).state = null;
                  if (mounted) context.go('/login');
                },
                tooltip: 'Se déconnecter',
              ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: "Toutes les offres"),
              Tab(text: "Mes articles"),
            ],
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: user?.role?.toUpperCase() == 'VIEWER' ? null : Padding(
          padding: const EdgeInsets.only(bottom: 80), // Offset to avoid navbar overlap
          child: FloatingActionButton.extended(
            onPressed: () async {
              final result = await context.push('/marketplace/add');
              if (result == true) {
                _fetchProducts(); // Refresh if added
              }
            },
            backgroundColor: AppColors.primary,
            elevation: 8,
            icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
            label: const Text("Vendre un article", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        body: TabBarView(
          children: [
            // Tab 1: All Offers
            RefreshIndicator(
              onRefresh: _fetchProducts,
              child: Column(
                children: [
                  _buildSearchField(),
                  _buildCategories(),
                  Expanded(
                    child: _isLoading ? _buildShimmerGrid() : _buildProductGrid(false, myEmail),
                  ),
                ],
              ),
            ),
            // Tab 2: My Articles
            RefreshIndicator(
              onRefresh: _fetchProducts,
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: _isLoading ? _buildShimmerGrid() : _buildProductGrid(true, myEmail),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Chercher des produits agricoles...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final isSelected = selectedCategory == categories[index];
          return ChoiceChip(
            label: Text(categories[index]),
            selected: isSelected,
            onSelected: (val) => setState(() => selectedCategory = categories[index]),
            selectedColor: AppColors.primary,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            backgroundColor: Colors.white,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          );
        },
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.7,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: 4,
      itemBuilder: (context, index) => const ProductShimmer(),
    );
  }

  Widget _buildProductGrid(bool onlyMine, String myEmail) {
    List<Product> filteredProducts = _products;
    
    if (onlyMine) {
      filteredProducts = filteredProducts.where((p) => p.sellerId == myEmail).toList();
    } else {
      if (selectedCategory != 'All') {
        // Assume description holds category for now as per our add logic
        filteredProducts = filteredProducts.where((p) => p.description != null && p.description!.contains(selectedCategory)).toList();
      }
    }

    if (filteredProducts.isEmpty) {
      return Center(
        child: Text(
          onlyMine ? "Vous n'avez publié aucun article." : "Aucun article trouvé dans cette catégorie.",
          style: TextStyle(color: Colors.grey.shade600),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: filteredProducts.length,
      itemBuilder: (context, index) => _buildProductCard(filteredProducts[index], onlyMine),
    );
  }

  Widget _buildProductCard(Product product, bool isMine) {
    String firstImage = product.imageUrl ?? '';
    if (firstImage.contains(',')) {
      firstImage = firstImage.split(',').first;
    }

    return GestureDetector(
      onTap: () => context.push('/marketplace/detail', extra: product),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Hero(
                      tag: 'product_image_${product.id}',
                      child: Image.network(
                        firstImage,
                        height: double.infinity,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey.shade100,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  if (!isMine) 
                    Positioned(
                      top: 10,
                      right: 10,
                      child: HeartBeatButton(
                        isFavorited: false,
                        onTap: () {},
                      ),
                    ),
                  if (isMine)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black87,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text('Mon Article', style: TextStyle(color: Colors.white, fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  if (product.description != null)
                    Text(
                      product.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
                    ),
                  const SizedBox(height: 6),
                  Text(
                    '${product.price.toStringAsFixed(0)} GNF',
                    style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Text(' / ${product.unit}', style: const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
