import 'package:flutter_riverpod/flutter_riverpod.dart';
<<<<<<< HEAD
=======
import 'package:dio/dio.dart';
>>>>>>> 3440655736442a9ccf03ebd19da75d4cd08be463
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import 'user_model.dart';
import 'dart:convert';

class AuthService {
  final StorageService _storage;
<<<<<<< HEAD
  final ApiClient _api;

  AuthService(this._storage, this._api);
=======
  final ApiClient _apiClient;

  AuthService(this._storage, this._apiClient) {
    final currentUser = getCurrentUser();
    _apiClient.setAuthToken(currentUser?.token);
  }
>>>>>>> 3440655736442a9ccf03ebd19da75d4cd08be463

  static const String _userKey = 'auth_user';

  Future<User?> login(String email, String password) async {
    try {
<<<<<<< HEAD
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
=======
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      final user = _mapAuthResponseToUser(response.data);
      await saveUser(user);
      _apiClient.setAuthToken(user.token);
      return user;
    } on DioException {
      return null;
>>>>>>> 3440655736442a9ccf03ebd19da75d4cd08be463
    }
  }

<<<<<<< HEAD
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
=======
  Future<User?> register(
    String name,
    String email,
    String password, {
    String lastName = '',
    String role = 'FARMER',
    String organization = '',
  }) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'firstName': name.trim(),
          'lastName': lastName.trim(),
          'role': role,
          'organization': organization,
        },
      );

      final user = _mapAuthResponseToUser(response.data);
      await saveUser(user);
      _apiClient.setAuthToken(user.token);
      return user;
    } on DioException {
      return null;
    }
  }

  User _mapAuthResponseToUser(dynamic data) {
    final json = Map<String, dynamic>.from(data as Map);
    final email = (json['email'] ?? '').toString();
    final firstName = (json['firstName'] ?? '').toString().trim();
    final lastName = (json['lastName'] ?? '').toString().trim();

    return User(
      id: email,
      name: [firstName, lastName].where((part) => part.isNotEmpty).join(' ').trim(),
      email: email,
      token: (json['token'] ?? '').toString(),
    );
>>>>>>> 3440655736442a9ccf03ebd19da75d4cd08be463
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
    _apiClient.setAuthToken(null);
    await _storage.remove(_userKey);
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  final storage = ref.watch(storageServiceProvider);
<<<<<<< HEAD
  final api = ref.watch(apiClientProvider);
  return AuthService(storage, api);
=======
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(storage, apiClient);
>>>>>>> 3440655736442a9ccf03ebd19da75d4cd08be463
});

final authStateProvider = StateProvider<User?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.getCurrentUser();
});
