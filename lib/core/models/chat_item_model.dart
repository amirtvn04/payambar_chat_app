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
}