import 'dart:async';
import 'dart:developer';

import 'package:payambar/core/models/message_model.dart';
import 'package:payambar/core/models/user_model.dart';
import 'package:payambar/core/other/base_viewmodel.dart';
import 'package:payambar/core/services/chat_service.dart';
import 'package:flutter/material.dart';

class ChatViewmodel extends BaseViewmodel {
  final ChatService _chatService;
  final UserModel _currentUser;
  final UserModel _receiver;

  StreamSubscription? _subscription;
  String chatRoomId = "";
  final _messageController = TextEditingController();
  List<Message> _messages = [];

  ChatViewmodel(this._chatService, this._currentUser, this._receiver) {
    _init();
  }

  Future<void> _init() async {
    // گرفتن یا ساختن chatRoom واقعی
    chatRoomId = await _chatService.getOrCreateChatRoom(
      _currentUser.uid!,
      _receiver.uid!,
    );

    // بعد از مشخص شدن chatRoom → reset unread
    await _chatService.resetUnreadCounter(chatRoomId, _currentUser.uid!);

    // گوش دادن به پیام‌ها
    _subscription = _chatService.getMessages(chatRoomId).listen((messages) {
      _messages = messages.docs.map((e) => Message.fromMap(e.data())).toList();
      notifyListeners();
    });
  }

  TextEditingController get controller => _messageController;
  List<Message> get messages => _messages;

  Future<void> saveMessage() async {
    if (_messageController.text.isEmpty) return;

    final now = DateTime.now();
    final message = Message(
      id: now.millisecondsSinceEpoch.toString(),
      content: _messageController.text,
      senderId: _currentUser.uid,
      receiverId: _receiver.uid,
      timestamp: now,
    );

    await _chatService.savePrivateMessage(message.toMap(), chatRoomId);
    _messageController.clear();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
