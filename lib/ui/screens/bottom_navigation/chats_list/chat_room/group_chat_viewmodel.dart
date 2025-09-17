import 'dart:async';
import 'dart:developer';

import 'package:chat_app/core/models/group_model.dart';
import 'package:chat_app/core/models/message_model.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/other/base_viewmodel.dart';
import 'package:chat_app/core/services/chat_service.dart';
import 'package:flutter/material.dart';

class GroupChatViewmodel extends BaseViewmodel {
  final ChatService _chatService;
  final UserModel _currentUser;
  final GroupModel _group;

  StreamSubscription? _subscription;

  GroupChatViewmodel(this._chatService, this._currentUser, this._group) {
    _subscription = _chatService.getGroupMessages(_group.groupId!).listen((messages) {
      _messages = messages.docs.map((e) => Message.fromMap(e.data())).toList();
      notifyListeners();
    });
  }

  final _messageController = TextEditingController();

  TextEditingController get controller => _messageController;

  List<Message> _messages = [];

  List<Message> get messages => _messages;

  saveMessage() async {
    log("Send Group Message");
    try {
      if (_messageController.text.isEmpty) {
        throw Exception("Please enter some text");
      }
      final now = DateTime.now();

      final message = Message(
        id: now.millisecondsSinceEpoch.toString(),
        content: _messageController.text,
        senderId: _currentUser.uid,
        senderName: _currentUser.name,
        groupId: _group.groupId,
        timestamp: now,
        chatType: ChatType.group,
      );

      await _chatService.saveGroupMessage(message.toMap(), _group.groupId!);

      // آپدیت lastMessage در گروه
      await _chatService.updateGroupLastMessage(_group.groupId!, {
        "content": message.content,
        "timestamp": now.millisecondsSinceEpoch,
        "senderId": _currentUser.uid,
        "senderName": _currentUser.name,
      });

      _messageController.clear();
    } catch (e) {
      rethrow;
    }
  }

  @override
  void dispose() {
    super.dispose();
    _subscription?.cancel();
  }
}