import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/storage/storage_service.dart';
import 'user_model.dart';
import 'dart:convert';
import '../../core/network/api_client.dart';

/// Erreur personnalisée levée si le rôle de l'utilisateur n'est pas PRODUCTEUR
class NotFarmerException implements Exception {
  final String message;
  const NotFarmerException([this.message = 'Cette application est réservée aux agriculteurs (PRODUCTEUR).']);
  @override
  String toString() => message;
}

class AuthService {
  final StorageService _storage;
  final ApiClient _api;

  AuthService(this._storage, this._api);

  static const String _userKey = 'auth_user';

  /// Connexion — vérifie que le rôle est bien PRODUCTEUR
  Future<User?> login(String email, String password) async {
    final response = await _api.post('auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final role = (data['role'] ?? '').toString().toUpperCase();

      // Seuls les PRODUCTEUR et VIEWER peuvent accéder à l'app
      if (role != 'PRODUCTEUR' && role != 'VIEWER') {
        throw const NotFarmerException();
      }

      final user = User.fromJson(data);
      final updatedUser = user.copyWith(
        name: '${user.firstName ?? ""} ${user.lastName ?? ""}'.trim(),
      );
      await saveUser(updatedUser);
      return updatedUser;
    }
    return null;
  }

  /// Étape 1 de l'inscription — envoie le code de vérification par email
  /// Le rôle est automatiquement fixé à PRODUCTEUR (agriculteur)
  Future<void> requestSignupCode({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    final response = await _api.post('auth/signup/request-code', data: {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
      'role': 'PRODUCTEUR', // fixe — app réservée aux agriculteurs
    });

    if (response.statusCode != 200) {
      final error = response.data is Map ? (response.data['error'] ?? 'ERREUR_INCONNUE') : 'ERREUR_INCONNUE';
      throw Exception(error);
    }
  }

  /// Étape 2 de l'inscription — vérifie le code et crée le compte
  Future<User?> verifySignupCode(String email, String code) async {
    final response = await _api.post('auth/signup/verify-code', data: {
      'email': email,
      'code': code,
    });

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final user = User.fromJson(data);
      final updatedUser = user.copyWith(
        name: '${user.firstName ?? ""} ${user.lastName ?? ""}'.trim(),
      );
      await saveUser(updatedUser);
      return updatedUser;
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
