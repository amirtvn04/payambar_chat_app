import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _fire = FirebaseFirestore.instance;

  // برای هر دو نوع چت
  saveMessage(Map<String, dynamic> message, String chatRoomId) async {
    try {
      await _fire
          .collection("chatRooms")
          .doc(chatRoomId)
          .collection("messages")
          .add(message);
    } catch (e) {
      rethrow;
    }
  }

  // برای چت خصوصی
  updatePrivateLastMessage(String currentUid, String receiverUid, String message,
      int timestamp) async {
    try {
      await _fire.collection("users").doc(currentUid).update({
        "lastMessage": {
          "content": message,
          "timestamp": timestamp,
          "senderId": currentUid
        },
        "unreadCounter": FieldValue.increment(1)
      });

      await _fire.collection("users").doc(receiverUid).update({
        "lastMessage": {
          "content": message,
          "timestamp": timestamp,
          "senderId": currentUid,
        },
        "unreadCounter": 0
      });
    } catch (e) {
      rethrow;
    }
  }

  // برای چت گروهی
  updateGroupLastMessage(String groupId, Map<String, dynamic> messageData) async {
    try {
      await _fire.collection("groups").doc(groupId).update({
        "lastMessage": messageData,
        "unreadCounter": FieldValue.increment(1)
      });
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatRoomId) {
    return _fire
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // متد جدید برای دریافت پیام‌های گروه
  Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMessages(String groupId) {
    return _fire
        .collection("groupChats")
        .doc(groupId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // متد جدید برای ذخیره پیام گروه
  saveGroupMessage(Map<String, dynamic> message, String groupId) async {
    try {
      await _fire
          .collection("groupChats")
          .doc(groupId)
          .collection("messages")
          .add(message);
    } catch (e) {
      rethrow;
    }
  }
}