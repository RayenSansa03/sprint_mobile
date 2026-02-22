import 'package:freezed_annotation/freezed_annotation.dart';

part 'marketplace_models.freezed.dart';
part 'marketplace_models.g.dart';

@freezed
class Product with _$Product {
  const factory Product({
    required String id,
    required String name,
    required double price,
    required String unit,
    required String category,
    required String imageUrl,
    required String sellerId,
    required String sellerName,
    required String location,
    @Default(true) bool isAvailable,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}

class MarketplaceService {
  Future<List<Product>> getProducts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return [
      const Product(
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
      const Product(
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
      const Product(
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
      const Product(
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
  }
}
