import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final _fire = FirebaseFirestore.instance;

  // === متدهای عمومی ===

  // ایجاد یا دریافت chat room
  Future<String> getOrCreateChatRoom(String user1Id, String user2Id) async {
    String chatRoomId = _generateChatRoomId(user1Id, user2Id);

    final doc = await _fire.collection("chatRooms").doc(chatRoomId).get();

    if (!doc.exists) {
      await _fire.collection("chatRooms").doc(chatRoomId).set({
        'participants': [user1Id, user2Id],
        'type': 'private',
        'unreadCounters': {
          user1Id: 0,
          user2Id: 0,
        },
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    return chatRoomId;
  }

  String _generateChatRoomId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id]..sort();
    return "${ids[0]}_${ids[1]}";
  }

  // === متدهای چت خصوصی ===

  Future<void> savePrivateMessage(Map<String, dynamic> message, String chatRoomId) async {
    try {
      // بررسی وجود chat room
      final chatRoomDoc = await _fire.collection("chatRooms").doc(chatRoomId).get();

      if (!chatRoomDoc.exists) {
        // اگر chat room وجود ندارد، ابتدا آن را ایجاد کنید
        await _fire.collection("chatRooms").doc(chatRoomId).set({
          'participants': [message['senderId'], message['receiverId']],
          'type': 'private',
          'unreadCounters': {
            message['senderId']: 0,
            message['receiverId']: 0,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }

      // ذخیره پیام
      await _fire
          .collection("chatRooms")
          .doc(chatRoomId)
          .collection("messages")
          .add(message);

      // آپدیت last message
      await _updateLastMessage(chatRoomId, message);

      final String senderId = message['senderId'];
      final participants = await _getChatRoomParticipants(chatRoomId);
      final String receiverId = participants.firstWhere((id) => id != senderId);

      await _incrementUnreadCounter(chatRoomId, receiverId);

    } catch (e) {
      rethrow;
    }
  }

  // === متدهای چت گروهی ===

  // ذخیره پیام گروهی
  Future<void> saveGroupMessage(Map<String, dynamic> message, String groupId) async {
    try {
      // بررسی وجود گروه
      final groupDoc = await _fire.collection("groups").doc(groupId).get();

      if (!groupDoc.exists) {
        throw Exception("Group does not exist");
      }

      // ذخیره پیام در گروه
      await _fire
          .collection("groups")
          .doc(groupId)
          .collection("messages")
          .add(message);

      // آپدیت last message در گروه
      await updateGroupLastMessage(groupId, message);

      // افزایش unread counter برای تمام اعضا به جز فرستنده
      final String senderId = message['senderId'];
      final List<String> members = List<String>.from(groupDoc.data()?['members'] ?? []);

      for (String memberId in members) {
        if (memberId != senderId) {
          await _incrementGroupUnreadCounter(groupId, memberId);
        }
      }
    } catch (e) {
      rethrow;
    }
  }
  // دریافت پیام‌های گروه
  Stream<QuerySnapshot<Map<String, dynamic>>> getGroupMessages(String groupId) {
    return _fire
        .collection("groups")
        .doc(groupId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // آپدیت last message گروه
  Future<void> updateGroupLastMessage(String groupId, Map<String, dynamic> messageData) async {
    await _fire.collection("groups").doc(groupId).update({
      "lastMessage": messageData,
      "lastUpdated": FieldValue.serverTimestamp(),
    });
  }

  // افزایش unread counter گروه
  Future<void> _incrementGroupUnreadCounter(String groupId, String userId) async {
    await _fire.collection("groups").doc(groupId).update({
      'unreadCounters.$userId': FieldValue.increment(1),
    });
  }

  // reset unread counter گروه
  Future<void> resetGroupUnreadCounter(String groupId, String userId) async {
    await _fire.collection("groups").doc(groupId).update({
      'unreadCounters.$userId': 0,
    });
  }

  // دریافت اطلاعات گروه
  Stream<DocumentSnapshot<Map<String, dynamic>>> getGroupStream(String groupId) {
    return _fire.collection("groups").doc(groupId).snapshots();
  }

  // === متدهای کمکی ===

  Future<void> _updateLastMessage(String chatRoomId, Map<String, dynamic> message) async {
    await _fire.collection("chatRooms").doc(chatRoomId).update({
      'lastMessage': message,
      'lastUpdated': FieldValue.serverTimestamp(),
    });
  }

  Future<List<String>> _getChatRoomParticipants(String chatRoomId) async {
    final doc = await _fire.collection("chatRooms").doc(chatRoomId).get();
    return List<String>.from(doc.data()?['participants'] ?? []);
  }

  Future<void> _incrementUnreadCounter(String chatRoomId, String userId) async {
    await _fire.collection("chatRooms").doc(chatRoomId).update({
      'unreadCounters.$userId': FieldValue.increment(1),
    });
  }

  // reset unread counter چت خصوصی
  Future<void> resetUnreadCounter(String chatRoomId, String userId) async {
    await _fire.collection("chatRooms").doc(chatRoomId).update({
      'unreadCounters.$userId': 0,
    });
  }

  // دریافت پیام‌های چت خصوصی
  Stream<QuerySnapshot<Map<String, dynamic>>> getMessages(String chatRoomId) {
    return _fire
        .collection("chatRooms")
        .doc(chatRoomId)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

  // دریافت اطلاعات chat room
  Stream<DocumentSnapshot<Map<String, dynamic>>> getChatRoomStream(String chatRoomId) {
    return _fire.collection("chatRooms").doc(chatRoomId).snapshots();
  }

  // دریافت تمام chat rooms های یک کاربر
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserChatRooms(String userId) {
    return _fire
        .collection("chatRooms")
        .where('participants', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  // دریافت تمام گروه‌های یک کاربر
  Stream<QuerySnapshot<Map<String, dynamic>>> getUserGroups(String userId) {
    return _fire
        .collection("groups")
        .where('members', arrayContains: userId)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }
}