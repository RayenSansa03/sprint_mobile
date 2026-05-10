import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/storage/storage_service.dart';
import 'dart:convert';
import 'chatbot_model.dart';
import 'package:uuid/uuid.dart';

final chatbotServiceProvider = Provider<ChatbotService>((ref) {
  final api = ref.watch(apiClientProvider);
  final storage = ref.watch(storageServiceProvider);
  return ChatbotService(api, storage);
});

class ChatbotService {
  final ApiClient _api;
  final StorageService _storage;
  final _uuid = const Uuid();

  ChatbotService(this._api, this._storage);

  Future<ChatMessage> sendMessage(String text, {String? diagnosticContext}) async {
    // Read user credentials from storage
    final userJson = _storage.getString('auth_user');
    String email = 'anonymous';
    String role = 'visiteur';

    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson);
        email = userMap['email'] ?? email;
        role = userMap['role'] ?? role;
      } catch (_) {}
    }

    try {
      final response = await _api.post('ai/chat', data: {
        'user_id': email,
        'user_role': role,
        'query': text,
        'diagnostic_context': diagnosticContext,
      });

      final data = response.data;
      List<String> suggestedPages = [];
      if (data['suggested_pages'] != null) {
        suggestedPages = List<String>.from(data['suggested_pages']);
      }

      return ChatMessage(
        id: _uuid.v4(),
        text: data['response'] ?? 'Pas de réponse du bot.',
        isUser: false,
        intent: data['intent'],
        suggestedPages: suggestedPages,
      );
    } catch (e) {
      if (e is DioException) {
        final errData = e.response?.data;
        if (errData is Map && errData['error'] != null) {
          throw Exception(errData['error']);
        }
      }
      throw Exception('Erreur $e');
    }
  }
}

// StateNotifier to manage chat history
class ChatbotController extends StateNotifier<List<ChatMessage>> {
  final ChatbotService _service;
  final _uuid = const Uuid();
  bool isLoading = false;

  ChatbotController(this._service) : super([
    ChatMessage(
      id: 'welcome',
      text: 'Bonjour ! Je suis AgriSmart IA. Comment puis-je vous aider aujourd\'hui ?',
      isUser: false,
    )
  ]);

  Future<void> sendQuery(String text, {String? diagnosticContext}) async {
    if (text.trim().isEmpty) return;

    final userMsg = ChatMessage(
      id: _uuid.v4(),
      text: text,
      isUser: true,
    );

    state = [...state, userMsg];
    isLoading = true;

    try {
      final botMsg = await _service.sendMessage(text, diagnosticContext: diagnosticContext);
      state = [...state, botMsg];
    } catch (e) {
      state = [...state, ChatMessage(
        id: _uuid.v4(),
        text: '❌ Impossible d\'obtenir une réponse : ${e.toString().replaceAll('Exception: ', '')}',
        isUser: false,
      )];
    } finally {
      isLoading = false;
    }
  }
}

final chatbotControllerProvider = StateNotifierProvider<ChatbotController, List<ChatMessage>>((ref) {
  final service = ref.watch(chatbotServiceProvider);
  return ChatbotController(service);
});

// A separate, auto-disposing provider specifically for the Scan screen.
// This ensures that its messages don't mix with the main chatbot, 
// and that it clears its history whenever the user leaves the scan result screen.
final scanChatbotControllerProvider = StateNotifierProvider.autoDispose<ChatbotController, List<ChatMessage>>((ref) {
  final service = ref.watch(chatbotServiceProvider);
  return ChatbotController(service);
});
