import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/auth_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'dart:convert';
import '../../core/storage/storage_service.dart';

class ApiClient {
  final Dio _dio;
  final Ref _ref;

  ApiClient(this._dio, this._ref) {
    String baseUrl = 'http://172.20.10.3:8085/api/';
    
    try {
      if (kIsWeb) {
        baseUrl = 'http://localhost:8085/api/';
      }
    } catch (_) {} // Handle any platform check errors safely

    _dio.options.baseUrl = baseUrl; 
    _dio.options.connectTimeout = const Duration(seconds: 90);
    _dio.options.receiveTimeout = const Duration(seconds: 90);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          try {
            final storage = _ref.read(storageServiceProvider);
            final userJson = storage.getString('auth_user');
            if (userJson != null) {
              final userMap = jsonDecode(userJson);
              final token = userMap['token'];
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }
            }
          } catch (_) {}
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          if (e.response?.statusCode == 401) {
            try {
              final storage = _ref.read(storageServiceProvider);
              storage.remove('auth_user');
            } catch (_) {}
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}

final dioProvider = Provider<Dio>((ref) => Dio());

final apiClientProvider = Provider<ApiClient>((ref) {
  final dio = ref.watch(dioProvider);
  return ApiClient(dio, ref);
});
