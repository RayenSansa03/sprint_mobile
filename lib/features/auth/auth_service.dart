import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/storage_service.dart';
import 'user_model.dart';
import 'dart:convert';

class AuthService {
  final StorageService _storage;

  AuthService(this._storage);

  static const String _userKey = 'auth_user';

  Future<User?> login(String email, String password) async {
    // Simulate API delay
    await Future.delayed(const Duration(seconds: 1));

    if (email == 'farmer@smart.com' && password == 'password') {
      final user = User(
        id: '1',
        name: 'Marcus Farmer',
        email: email,
        token: 'mock_token_123',
        phone: '+216 12 345 678',
        location: 'Bizerte, Tunisia',
        cropType: 'Cereals & Vegetables',
      );
      await saveUser(user);
      return user;
    }
    return null;
  }

  Future<User?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      email: email,
      token: 'mock_token_new',
    );
    await saveUser(user);
    return user;
  }

  Future<void> saveUser(User user) async {
    await _storage.setString(_userKey, jsonEncode(user.toJson()));
  }

  User? getCurrentUser() {
    final userData = _storage.getString(_userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  Future<void> logout() async {
    await _storage.remove(_userKey);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return AuthService(storage);
});

final authStateProvider = StateProvider<User?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.getCurrentUser();
});
