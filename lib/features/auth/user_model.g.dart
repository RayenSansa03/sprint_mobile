// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserImpl _$$UserImplFromJson(Map<String, dynamic> json) => _$UserImpl(
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      token: json['token'] as String,
      role: json['role'] as String,
      id: json['id'] as String?,
      name: json['name'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] as String?,
      cropType: json['cropType'] as String?,
    );

Map<String, dynamic> _$$UserImplToJson(_$UserImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'token': instance.token,
      'role': instance.role,
      'id': instance.id,
      'name': instance.name,
      'profilePictureUrl': instance.profilePictureUrl,
      'phone': instance.phone,
      'location': instance.location,
      'cropType': instance.cropType,
    };
