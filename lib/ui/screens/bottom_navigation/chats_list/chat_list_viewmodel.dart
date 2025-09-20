import 'dart:developer';
import 'package:payambar/core/enums/enums.dart';
import 'package:payambar/core/models/user_model.dart';
import 'package:payambar/core/models/group_model.dart';
import 'package:payambar/core/models/chat_item_model.dart'; // اضافه کردن مدل ChatItem
import 'package:payambar/core/other/base_viewmodel.dart';
import 'package:payambar/core/services/database_service.dart';

class ChatListViewmodel extends BaseViewmodel {
  final DatabaseService _db;
  final UserModel _currentUser;

  ChatListViewmodel(this._db, this._currentUser) {
    fetchChats();
  }

  List<ChatItem> _chats = [];
  List<ChatItem> _filteredChats = [];

  List<ChatItem> get chats => _chats;
  List<ChatItem> get filteredChats => _filteredChats;

  void search(String query) {
    if (query.isEmpty) {
      _filteredChats = _chats;
    } else {
      _filteredChats = _chats.where((chat) {
        return chat.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  Future<void> fetchChats() async {
    setstate(ViewState.loading);

    try {
      // دریافت کاربران
      final users = await _db.fetchUsers(_currentUser.uid!);
      final userList = users?.map((e) => UserModel.fromMap(e)).toList() ?? [];

      // دریافت گروه‌ها
      final groups = await _db.fetchUserGroups(_currentUser.uid!);
      final groupList = groups?.map((e) => GroupModel.fromMap(e)).toList() ?? [];

      // دریافت اطلاعات last message و unread counter برای هر چت
      final chatItems = await _createChatItems(userList, groupList);

      _chats = chatItems;
      _filteredChats = _chats;
      setstate(ViewState.idle);

    } catch (e) {
      setstate(ViewState.idle);
      log("Error Fetching Chats: $e");
    }
  }

  Future<List<ChatItem>> _createChatItems(List<UserModel> users, List<GroupModel> groups) async {
    final List<ChatItem> chatItems = [];

    // برای کاربران
    for (var user in users) {
      final chatRoomId = _generateChatRoomId(_currentUser.uid!, user.uid!);
      final chatInfo = await _db.getChatRoomInfo(chatRoomId, _currentUser.uid!);

      chatItems.add(ChatItem(
        type: ChatType.private,
        user: user,
        lastMessage: chatInfo['lastMessage'],
        unreadCounter: chatInfo['unreadCounter'],
      ));
    }

    // برای گروه‌ها
    for (var group in groups) {
      final groupInfo = await _db.getGroupInfo(group.groupId!, _currentUser.uid!);

      chatItems.add(ChatItem(
        type: ChatType.group,
        group: group,
        lastMessage: groupInfo['lastMessage'],
        unreadCounter: groupInfo['unreadCounter'],
      ));
    }

    // مرتب‌سازی بر اساس last message
    chatItems.sort((a, b) {
      final aTime = a.lastMessage?['timestamp'] ?? 0;
      final bTime = b.lastMessage?['timestamp'] ?? 0;
      return bTime.compareTo(aTime);
    });

    return chatItems;
  }

  String _generateChatRoomId(String user1Id, String user2Id) {
    List<String> ids = [user1Id, user2Id]..sort();
    return "${ids[0]}_${ids[1]}";
  }
}