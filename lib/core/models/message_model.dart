import 'dart:convert';

enum MessageType { text, image, file }
enum ChatType { private, group }

class Message {
  final String? id;
  final String? content;
  final String? senderId;
  final String? senderName; // اضافه کردن نام فرستنده
  final String? receiverId; // برای چت خصوصی
  final String? groupId; // برای چت گروهی
  final DateTime? timestamp;
  final MessageType type;
  final ChatType chatType;

  Message({
    this.id,
    this.content,
    this.senderId,
    this.senderName,
    this.receiverId,
    this.groupId,
    this.timestamp,
    this.type = MessageType.text,
    this.chatType = ChatType.private,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'senderId': senderId,
      'senderName': senderName,
      'receiverId': receiverId,
      'groupId': groupId,
      'timestamp': timestamp?.millisecondsSinceEpoch,
      'type': type.toString(),
      'chatType': chatType.toString(),
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] != null ? map['id'] as String : null,
      content: map['content'] != null ? map['content'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      senderName: map['senderName'] != null ? map['senderName'] as String : null,
      receiverId: map['receiverId'] != null ? map['receiverId'] as String : null,
      groupId: map['groupId'] != null ? map['groupId'] as String : null,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : null,
      type: map['type'] != null
          ? MessageType.values.firstWhere((e) => e.toString() == map['type'])
          : MessageType.text,
      chatType: map['chatType'] != null
          ? ChatType.values.firstWhere((e) => e.toString() == map['chatType'])
          : ChatType.private,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(id: $id, content: $content, senderId: $senderId, senderName: $senderName, receiverId: $receiverId, groupId: $groupId, timestamp: $timestamp, type: $type, chatType: $chatType)';
  }
}