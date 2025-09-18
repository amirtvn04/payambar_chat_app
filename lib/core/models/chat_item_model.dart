import 'package:chat_app/core/models/user_model.dart';
import 'group_model.dart';

enum ChatType { private, group }

class ChatItem {
  final ChatType type;
  final UserModel? user;
  final GroupModel? group;
  final Map<String, dynamic>? lastMessage;
  final int? unreadCounter;

  ChatItem({
    required this.type,
    this.user,
    this.group,
    this.lastMessage,
    this.unreadCounter,
  });

  String get name => type == ChatType.private ? user?.name ?? '' : group?.name ?? '';
  String get id => type == ChatType.private ? user?.uid ?? '' : group?.groupId ?? '';
  String? get imageUrl => type == ChatType.private ? user?.imageUrl : null;

  ChatItem copyWith({
    ChatType? type,
    UserModel? user,
    GroupModel? group,
    Map<String, dynamic>? lastMessage,
    int? unreadCounter,
  }) {
    return ChatItem(
      type: type ?? this.type,
      user: user ?? this.user,
      group: group ?? this.group,
      lastMessage: lastMessage ?? this.lastMessage,
      unreadCounter: unreadCounter ?? this.unreadCounter,
    );
  }
}