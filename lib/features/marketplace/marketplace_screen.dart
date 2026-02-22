import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import 'marketplace_models.dart';

class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  String selectedCategory = 'All';
  final List<String> categories = ['All', 'Seeds', 'Fertilizer', 'Tools', 'Vegetables'];
  
  // Mock data would usually come from a provider
  final List<Product> products = const [
    Product(
      id: '1',
      name: 'Organic Maize',
      price: 15.00,
      unit: 'bag',
      category: 'Seeds',
      imageUrl: 'https://images.unsplash.com/photo-1551717743-49943600b467?w=400',
      sellerId: 's1',
      sellerName: 'Marcus',
      location: 'North Zone',
    ),
    Product(
      id: '2',
      name: 'Nitrogen Fertilizer',
      price: 45.00,
      unit: 'bag',
      category: 'Fertilizer',
      imageUrl: 'https://images.unsplash.com/photo-1628352081506-83c43123ed6d?w=400',
      sellerId: 's2',
      sellerName: 'AgriCorp',
      location: 'South Zone',
    ),
    Product(
      id: '3',
      name: 'Heavy Duty Hoe',
      price: 12.50,
      unit: 'unit',
      category: 'Tools',
      imageUrl: 'https://images.unsplash.com/photo-1473448912268-2022ce9509d8?w=400',
      sellerId: 's3',
      sellerName: 'ToolsPlus',
      location: 'East Zone',
    ),
    Product(
      id: '4',
      name: 'Fresh Tomatoes',
      price: 3.00,
      unit: 'kg',
      category: 'Vegetables',
      imageUrl: 'https://images.unsplash.com/photo-1546473427-e1ad6d66ccb5?w=400',
      sellerId: 's1',
      sellerName: 'Marcus',
      location: 'North Zone',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AgriSmart'),
        actions: [
          IconButton(icon: const Icon(Icons.notifications_none), onPressed: () {}),
          IconButton(icon: const Icon(Icons.shopping_cart_outlined), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search agricultural products...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: const Color(0xFFF1F5F9),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
              ),
            ),
          ),
          _buildCategories(),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: products.length,
              itemBuilder: (context, index) => _buildProductCard(products[index]),
            ),
          ),
        ],
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
            labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.textPrimary),
            backgroundColor: Colors.white,
            side: BorderSide.none,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          );
        },
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
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
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Image.network(product.imageUrl, height: 120, width: double.infinity, fit: BoxFit.cover),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 14,
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: const Icon(Icons.favorite_border, size: 16, color: Colors.green),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(' / ${product.unit}', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size.fromHeight(36),
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('BUY / SELL', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
