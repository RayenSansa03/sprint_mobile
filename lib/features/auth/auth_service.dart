import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import 'user_model.dart';
import 'dart:convert';

class AuthService {
  final StorageService _storage;
  final ApiClient _apiClient;

  AuthService(this._storage, this._apiClient) {
    final currentUser = getCurrentUser();
    _apiClient.setAuthToken(currentUser?.token);
  }

  static const String _userKey = 'auth_user';

  Future<User?> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/login',
        data: {
          'email': email.trim(),
          'password': password,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      final user = _mapAuthResponseToUser(response.data, fallbackEmail: email);
      await saveUser(user);
      _apiClient.setAuthToken(user.token);
      return user;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<User?> register(String firstName, String lastName, String email, String password) async {
    try {
      final response = await _apiClient.post(
        '/auth/register',
        data: {
          'email': email.trim(),
          'password': password,
          'firstName': firstName.trim(),
          'lastName': lastName.trim(),
          'role': 'PRODUCTEUR',
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        return null;
      }

      final user = _mapAuthResponseToUser(
        response.data,
        fallbackEmail: email,
        fallbackFirstName: firstName,
        fallbackLastName: lastName,
        fallbackRole: 'PRODUCTEUR',
      );
      await saveUser(user);
      _apiClient.setAuthToken(user.token);
      return user;
    } on DioException {
      return null;
    } catch (_) {
      return null;
    }
  }

  User _mapAuthResponseToUser(
    dynamic data, {
    String fallbackEmail = '',
    String fallbackFirstName = '',
    String fallbackLastName = '',
    String fallbackRole = 'PRODUCTEUR',
  }) {
    final json = data is Map<String, dynamic>
        ? data
        : Map<String, dynamic>.from(data as Map);

    final email = (json['email'] ?? fallbackEmail).toString().trim();
    final firstName = (json['firstName'] ?? fallbackFirstName).toString().trim();
    final lastName = (json['lastName'] ?? fallbackLastName).toString().trim();
    final role = (json['role'] ?? fallbackRole).toString().trim();

    return User(
      email: email,
      firstName: firstName,
      lastName: lastName,
      token: (json['token'] ?? '').toString(),
      role: role.isEmpty ? fallbackRole : role,
      id: (json['id'] ?? '').toString().isEmpty ? null : (json['id'] ?? '').toString(),
      name: [firstName, lastName].where((part) => part.isNotEmpty).join(' ').trim(),
    );
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
  final apiClient = ref.watch(apiClientProvider);
  return AuthService(storage, apiClient);
});

final authStateProvider = StateProvider<User?>((ref) {
  final service = ref.watch(authServiceProvider);
  return service.getCurrentUser();
});
