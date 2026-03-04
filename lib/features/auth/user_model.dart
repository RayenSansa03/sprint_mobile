import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class User with _$User {
  const factory User({
    required String email,
    required String firstName,
    required String lastName,
    required String token,
    required String role,
    String? id,
    String? name,
    String? profilePictureUrl,
    String? phone,
    String? location,
    String? cropType,
  }) = _User;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
}

extension UserX on User {
  String get fullName => '$firstName $lastName';
  String get displayName => name ?? fullName;
}
