import 'message_model.dart';

class ChatRoom {
  final String chatRoomId;
  final List<String> participants;
  final Message? lastMessage;
  final Map<String, int> unreadCounters; // {userId: count}
  final DateTime? lastUpdated;

  ChatRoom({
    required this.chatRoomId,
    required this.participants,
    this.lastMessage,
    required this.unreadCounters,
    this.lastUpdated,
  });
}