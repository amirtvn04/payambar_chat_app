import 'dart:developer';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/models/group_model.dart';
import 'package:chat_app/core/models/chat_item_model.dart'; // اضافه کردن مدل ChatItem
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/database_service.dart';

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

  void search(String value) {
    if (value.isEmpty) {
      _filteredChats = _chats;
    } else {
      _filteredChats = _chats.where((chat) {
        return chat.name.toLowerCase().contains(value.toLowerCase());
      }).toList();
    }
    notifyListeners();
  }

  void fetchChats() async {
    try {
      setstate(ViewState.loading);

      // گوش دادن به استریم کاربران
      _db.fetchUserStream(_currentUser.uid!).listen((userData) {
        final users =
            userData.docs.map((e) => UserModel.fromMap(e.data())).toList();

        // گوش دادن به استریم گروه‌ها
        _db.fetchUserGroupsStream(_currentUser.uid!).listen((groupData) {
          final groups =
              groupData.docs.map((e) => GroupModel.fromMap(e.data())).toList();

          // ترکیب کاربران و گروه‌ها در یک لیست
          _combineChats(users, groups);
        });
      });

      setstate(ViewState.idle);
    } catch (e) {
      setstate(ViewState.idle);
      log("Error Fetching Chats: $e");
    }
  }

  void _combineChats(List<UserModel> users, List<GroupModel> groups) {
    // تبدیل کاربران به ChatItem
    final userChats = users
        .map((user) => ChatItem(
              type: ChatType.private,
              user: user,
              lastMessage: user.lastMessage,
              unreadCounter: user.unreadCounter,
            ))
        .toList();

    // تبدیل گروه‌ها به ChatItem
    final groupChats = groups
        .map((group) => ChatItem(
              type: ChatType.group,
              group: group,
              lastMessage: group.lastMessage,
              unreadCounter: group.unreadCounter,
            ))
        .toList();

    // ترکیب و مرتب‌سازی
    _chats = [...userChats, ...groupChats];
    _sortChatsByLastMessage();

    _filteredChats = _chats;
    notifyListeners();
  }

  void _sortChatsByLastMessage() {
    _chats.sort((a, b) {
      final aTime = a.lastMessage?['timestamp'] ?? 0;
      final bTime = b.lastMessage?['timestamp'] ?? 0;
      return bTime.compareTo(aTime); // جدیدترین اول
    });
  }

  // متد برای بازنشانی شمارنده پیام‌های نخوانده
  Future<void> resetUnreadCounter(String chatId, ChatType type) async {
    try {
      // برای گروه
      await _db.resetUnreadCounter(chatId, _currentUser.uid!);

      // به‌روزرسانی لیست محلی
      final index = _chats.indexWhere((chat) => chat.id == chatId);
      if (index != -1) {
        _chats[index] = ChatItem(
          type: _chats[index].type,
          user: _chats[index].user,
          group: _chats[index].group,
          lastMessage: _chats[index].lastMessage,
          unreadCounter: 0,
        );
        _filteredChats = _chats;
        notifyListeners();
      }
    } catch (e) {
      log("Error resetting unread counter: $e");
    }
  }
}
