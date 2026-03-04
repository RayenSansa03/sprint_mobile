import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';

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
    required String description,
    required String sellerPhone,
    @Default(true) bool isAvailable,
  }) = _Product;

  factory Product.fromJson(Map<String, dynamic> json) => _$ProductFromJson(json);
}



class MarketplaceService {
  final ApiClient _api;

  MarketplaceService(this._api);

  Future<List<Product>> getProducts() async {
    try {
      final response = await _api.get('/market/offers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => Product(
          id: json['id'] ?? '',
          name: json['product'] ?? '',
          price: (json['price'] as num?)?.toDouble() ?? 0.0,
          unit: json['unit'] ?? 'kg',
          category: json['quality'] ?? 'Standard',
          imageUrl: (json['imageUrl'] as String?)?.isNotEmpty == true 
              ? json['imageUrl'] 
              : 'https://images.unsplash.com/photo-1551717743-49943600b467?w=400',
          sellerId: json['ownerEmail'] ?? '',
          sellerName: json['producer'] ?? 'Agriculteur',
          location: json['availability'] ?? 'Tunisie',
          description: json['description'] ?? '',
          sellerPhone: '+216 22 333 444', // Mock or fetch from user profile if available
          isAvailable: json['status'] == 'validated',
        )).toList();
      }
    } catch (e) {
      print('Marketplace fetch error: $e');
    }
    return [];
  }
}

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final api = ref.watch(apiClientProvider);
  return MarketplaceService(api);
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(marketplaceServiceProvider);
  return service.getProducts();
});
