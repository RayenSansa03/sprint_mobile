import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import 'chat_models.dart';

class ChatService {
  final ApiClient _api;

  ChatService(this._api);

  Future<List<ChatRoom>> getMyRooms() async {
    try {
      final response = await _api.get('chat/rooms');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => ChatRoom.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching chat rooms: $e');
    }
    return [];
  }

  Future<List<ChatMessage>> getMessages(String roomId) async {
    try {
      final response = await _api.get('chat/messages/$roomId');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((item) => ChatMessage.fromJson(item)).toList();
      }
    } catch (e) {
      print('Error fetching messages: $e');
    }
    return [];
  }

  Future<ChatMessage?> sendMessage(String recipientEmail, String content, {String? productId}) async {
    try {
      final response = await _api.post('chat/send', data: {
        'recipientEmail': recipientEmail,
        'content': content,
        if (productId != null) 'productId': productId,
      });
      if (response.statusCode == 200) {
        return ChatMessage.fromJson(response.data);
      }
    } catch (e) {
      print('Error sending message: $e');
    }
    return null;
  }
}

final chatServiceProvider = Provider<ChatService>((ref) {
  final api = ref.watch(apiClientProvider);
  return ChatService(api);
});
