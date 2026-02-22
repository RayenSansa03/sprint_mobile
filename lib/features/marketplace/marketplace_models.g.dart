// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'marketplace_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ProductImpl _$$ProductImplFromJson(Map<String, dynamic> json) =>
    _$ProductImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String,
      imageUrl: json['imageUrl'] as String,
      sellerId: json['sellerId'] as String,
      sellerName: json['sellerName'] as String,
      location: json['location'] as String,
      isAvailable: json['isAvailable'] as bool? ?? true,
    );

Map<String, dynamic> _$$ProductImplToJson(_$ProductImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'price': instance.price,
      'unit': instance.unit,
      'category': instance.category,
      'imageUrl': instance.imageUrl,
      'sellerId': instance.sellerId,
      'sellerName': instance.sellerName,
      'location': instance.location,
      'isAvailable': instance.isAvailable,
    };
