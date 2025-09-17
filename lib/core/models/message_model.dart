import 'dart:convert';

class Message {
  final String? id;
  final String? content;
  final String? senderId;
  final String? receiverId;
  final DateTime? timestamp;

  Message({
    this.id,
    this.content,
    this.senderId,
    this.receiverId,
    this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'content': content,
      'senderId': senderId,
      'receiverId': receiverId,
      'timestamp': timestamp?.millisecondsSinceEpoch,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] != null ? map['id'] as String : null,
      content: map['content'] != null ? map['content'] as String : null,
      senderId: map['senderId'] != null ? map['senderId'] as String : null,
      receiverId:
          map['receiverId'] != null ? map['receiverId'] as String : null,
      timestamp: map['timestamp'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory Message.fromJson(String source) =>
      Message.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Message(id: $id, content: $content, senderId: $senderId, receiverId: $receiverId, timestamp: $timestamp)';
  }
}
