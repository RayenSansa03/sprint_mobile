import 'dart:io' show Platform;
import '../../core/network/api_client.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class Product {
  final String id;
  final String name;
  final double price;
  final String unit;
  final String? category;
  final String? imageUrl;
  final String? sellerId;
  final String? sellerName;
  final String? location;
  final String? description;
  final String? sellerPhone;
  final bool isAvailable;
  final String? status;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.unit,
    this.category,
    this.imageUrl,
    this.sellerId,
    this.sellerName,
    this.location,
    this.description,
    this.sellerPhone,
    this.isAvailable = true,
    this.status,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Mapping from Backend Offer to Flutter Product
    String? rawUrl = json['imageUrl'];
    if (rawUrl != null) {
      // Si on est sur Android, on doit remplacer localhost par 10.0.2.2 et port 8080/8082 par 8082
      if (!kIsWeb && Platform.isAndroid) {
        rawUrl = rawUrl.replaceAll('localhost:8080', '10.0.2.2:8082');
        rawUrl = rawUrl.replaceAll('localhost:8082', '10.0.2.2:8082');
      } else {
        rawUrl = rawUrl.replaceAll('localhost:8080', 'localhost:8082');
      }
    }

    return Product(
      id: json['id'] ?? '',
      name: json['product'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] ?? '',
      imageUrl: rawUrl,
      sellerId: json['ownerEmail'],
      sellerName: json['sellerName'] ?? json['producer'],
      location: json['availability'],
      description: json['description'],
      sellerPhone: json['sellerPhone'],
      status: json['status'],
      isAvailable: json['status'] == 'validated',
    );
  }
}

class MarketplaceService {
  final ApiClient _api;

  MarketplaceService(this._api);

  Future<List<Product>> getProducts() async {
    try {
      final response = await _api.get('market/offers');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => Product.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
    return [];
  }

  Future<String?> uploadImage(XFile file) async {
    try {
      final bytes = await file.readAsBytes();
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: file.name),
      });

      final response = await _api.post('upload', data: formData);
      if (response.statusCode == 200) {
        String rawUrl = response.data['url'] as String;
        // Le serveur Spring Boot (FileController) renvoie http://localhost:8080/uploads/...
        // On doit le réécrire pour pointer vers le vrai port du serveur (8082) en considérant Android (10.0.2.2)
        String fileName = rawUrl.split('/uploads/').last;
        String baseUrl = kIsWeb ? 'http://localhost:8082' : (Platform.isAndroid ? 'http://10.0.2.2:8082' : 'http://localhost:8082');
        return '$baseUrl/uploads/$fileName';
      }
    } catch (e) {
      print('Error uploading image: $e');
    }
    return null;
  }

  Future<bool> addOffer(Map<String, dynamic> offerData) async {
    try {
      final response = await _api.post('market/offers', data: offerData);
      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print('Error adding offer: $e');
      return false;
    }
  }
}

final marketplaceServiceProvider = Provider<MarketplaceService>((ref) {
  final api = ref.watch(apiClientProvider);
  return MarketplaceService(api);
});
