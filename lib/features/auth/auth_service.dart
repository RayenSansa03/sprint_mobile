import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import 'user_model.dart';
import 'dart:convert';

class AuthService {
  final StorageService _storage;
  final ApiClient _api;

  AuthService(this._storage, this._api);

  static const String _userKey = 'auth_user';

  Future<User?> login(String email, String password) async {
    try {
      final response = await _api.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        await saveUser(user);
        return user;
      }
    } catch (e) {
      print('Login error: $e');
    }
    return null;
  }

  Future<User?> register(String firstName, String lastName, String email, String password) async {
    try {
      final response = await _api.post('/auth/register', data: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'role': 'PRODUCTEUR',
      });

      if (response.statusCode == 200) {
        final user = User.fromJson(response.data);
        await saveUser(user);
        return user;
      }
    } catch (e) {
      print('Registration error: $e');
    }
    return null;
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
  final api = ref.watch(apiClientProvider);
  return AuthService(storage, api);
});

final authStateProvider = StateProvider<User?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.getCurrentUser();
});
