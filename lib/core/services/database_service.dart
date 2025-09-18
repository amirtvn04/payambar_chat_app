import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_model.dart';

class DatabaseService {
  final _fire = FirebaseFirestore.instance;

  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      await _fire.collection("users").doc(userData["uid"]).set(userData);
      log("User saved successfully");
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>?> loadUser(String uid) async {
    try {
      final res = await _fire.collection("users").doc(uid).get();
      return res.data();
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchUsers(String currentUserId) async {
    try {
      final res = await _fire
          .collection("users")
          .where("uid", isNotEqualTo: currentUserId)
          .get();

      return res.docs.map((e) => e.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserStream(
      String currentUserId) =>
      _fire
          .collection("users")
          .where("uid", isNotEqualTo: currentUserId)
          .snapshots();

  // متدهای جدید برای مدیریت گروه‌ها
  Future<void> createGroup(Map<String, dynamic> groupData) async {
    try {
      await _fire.collection("groups").doc(groupData["groupId"]).set(groupData);
      log("Group created successfully");
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>?> fetchUserGroups(String userId) async {
    try {
      final res = await _fire
          .collection("groups")
          .where("members", arrayContains: userId)
          .get();

      return res.docs.map((e) => e.data()).toList();
    } catch (e) {
      rethrow;
    }
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> fetchUserGroupsStream(String userId) {
    return _fire
        .collection("groups")
        .where("members", arrayContains: userId)
        .snapshots();
  }

  Future<Map<String, dynamic>?> loadGroup(String groupId) async {
    try {
      final res = await _fire.collection("groups").doc(groupId).get();
      return res.data();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateGroup(String groupId, Map<String, dynamic> updates) async {
    try {
      await _fire.collection("groups").doc(groupId).update(updates);
      log("Group updated successfully");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addMemberToGroup(String groupId, String userId) async {
    try {
      await _fire.collection("groups").doc(groupId).update({
        'members': FieldValue.arrayUnion([userId])
      });
      log("Member added to group successfully");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> removeMemberFromGroup(String groupId, String userId) async {
    try {
      await _fire.collection("groups").doc(groupId).update({
        'members': FieldValue.arrayRemove([userId])
      });
      log("Member removed from group successfully");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateLastMessage(String groupId, Map<String, dynamic> messageData) async {
    try {
      await _fire.collection("groups").doc(groupId).update({
        'lastMessage': messageData,
        'unreadCounter': FieldValue.increment(1)
      });
      log("Last message updated successfully");
    } catch (e) {
      rethrow;
    }
  }

  Future<void> resetUnreadCounter(String groupId, String userId) async {
    try {
      // این متد می‌تواند بر اساس نیاز شما پیاده‌سازی شود
      // برای سادگی، فعلاً فقط unreadCounter را صفر می‌کنیم
      await _fire.collection("groups").doc(groupId).update({
        'unreadCounter': 0
      });
      log("Unread counter reset successfully");
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> fetchUsersByIds(List<String> userIds) async {
    try {
      if (userIds.isEmpty) return [];

      final res = await _fire
          .collection("users")
          .where("uid", whereIn: userIds)
          .get();

      return res.docs.map((e) => UserModel.fromMap(e.data())).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> updates) async {
    try {
      await _fire.collection("users").doc(userId).update(updates);
      log("User updated successfully");
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getChatRoomInfo(String chatRoomId, String userId) async {
    try {
      final doc = await _fire.collection("chatRooms").doc(chatRoomId).get();
      if (doc.exists) {
        return {
          'lastMessage': doc.data()?['lastMessage'],
          'unreadCounter': doc.data()?['unreadCounters']?[userId] ?? 0
        };
      }
      return {'lastMessage': null, 'unreadCounter': 0};
    } catch (e) {
      return {'lastMessage': null, 'unreadCounter': 0};
    }
  }

  Future<Map<String, dynamic>> getGroupInfo(String groupId, String userId) async {
    try {
      final doc = await _fire.collection("groups").doc(groupId).get();
      if (doc.exists) {
        return {
          'lastMessage': doc.data()?['lastMessage'],
          'unreadCounter': doc.data()?['unreadCounters']?[userId] ?? 0
        };
      }
      return {'lastMessage': null, 'unreadCounter': 0};
    } catch (e) {
      return {'lastMessage': null, 'unreadCounter': 0};
    }
  }
}