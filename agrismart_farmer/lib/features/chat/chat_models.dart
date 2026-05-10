DateTime _parseDateTime(dynamic value) {
  if (value == null) return DateTime.now();
  if (value is int) {
    // Determine if it's in seconds or milliseconds. Spring Boot uses milliseconds.
    if (value > 1000000000000) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return DateTime.fromMillisecondsSinceEpoch(value * 1000);
  }
  if (value is String) {
    return DateTime.tryParse(value) ?? DateTime.now();
  }
  return DateTime.now();
}

class ChatRoom {
  final String id;
  final List<String> participants;
  final String? productId;
  final String? lastMessage;
  final DateTime lastUpdate;

  ChatRoom({
    required this.id,
    required this.participants,
    this.productId,
    this.lastMessage,
    required this.lastUpdate,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'] ?? '',
      participants: List<String>.from(json['participants'] ?? []),
      productId: json['productId'],
      lastMessage: json['lastMessage'],
      lastUpdate: _parseDateTime(json['lastUpdate']),
    );
  }
}

class ChatMessage {
  final String id;
  final String roomId;
  final String senderEmail;
  final String recipientEmail;
  final String content;
  final DateTime timestamp;
  final bool seen;

  ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderEmail,
    required this.recipientEmail,
    required this.content,
    required this.timestamp,
    this.seen = false,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? '',
      roomId: json['roomId'] ?? '',
      senderEmail: json['senderEmail'] ?? '',
      recipientEmail: json['recipientEmail'] ?? '',
      content: json['content'] ?? '',
      timestamp: _parseDateTime(json['timestamp']),
      seen: json['seen'] ?? false,
    );
  }
}
