import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/models/group_model.dart';
import 'package:chat_app/core/models/chat_item_model.dart'; // اضافه کردن import
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_list_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'create_group_screen.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    return ChangeNotifierProvider(
      create: (context) => ChatListViewmodel(DatabaseService(), currentUser!),
      child: Consumer<ChatListViewmodel>(builder: (context, model, _) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateGroupScreen()),
            ),
            backgroundColor: primary,
            child: const Icon(Icons.group_add, color: Colors.white),
          ),
          body: Padding(
            padding:
            EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 10.h),
            child: Column(
              children: [
                30.verticalSpace,
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Chats", style: h)),
                20.verticalSpace,
                CustomTextfield(
                  isSearch: true,
                  hintText: "Search here...",
                  onChanged: model.search,
                ),
                10.verticalSpace,
                model.state == ViewState.loading
                    ? const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : model.filteredChats.isEmpty
                    ? const Expanded(
                  child: Center(
                    child: Text("No chats yet"),
                  ),
                )
                    : Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                        vertical: 5, horizontal: 0),
                    itemCount: model.filteredChats.length,
                    separatorBuilder: (context, index) =>
                    8.verticalSpace,
                    itemBuilder: (context, index) {
                      final chat = model.filteredChats[index];
                      return ChatTile(
                        chat: chat,
                        onTap: () {
                          if (chat.type == ChatType.private) {
                            Navigator.pushNamed(
                                context, chatRoom,
                                arguments: chat.user);
                          } else {
                            Navigator.pushNamed(
                                context, groupChatRoom,
                                arguments: chat.group);
                          }
                        },
                      );
                    },
                  ),
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, this.onTap, required this.chat});

  final ChatItem chat;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: grey.withOpacity(0.12),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      leading: _buildLeading(),
      title: Text(chat.name),
      subtitle: Text(
        chat.lastMessage != null ? chat.lastMessage!["content"] : "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            chat.lastMessage == null ? "" : _getTime(),
            style: const TextStyle(color: grey),
          ),
          8.verticalSpace,
          chat.unreadCounter == 0 || chat.unreadCounter == null
              ? const SizedBox(height: 15)
              : CircleAvatar(
            radius: 9.r,
            backgroundColor: primary,
            child: Text(
              "${chat.unreadCounter}",
              style: small.copyWith(color: white),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildLeading() {
    if (chat.type == ChatType.private) {
      return chat.user?.imageUrl == null
          ? CircleAvatar(
        backgroundColor: grey.withOpacity(0.5),
        radius: 25,
        child: Text(
          chat.user?.name?[0] ?? 'U',
          style: h,
        ),
      )
          : ClipOval(
        child: Image.network(
          chat.user!.imageUrl!,
          height: 50,
          width: 50,
          fit: BoxFit.cover,
        ),
      );
    } else {
      // برای گروه‌ها
      return CircleAvatar(
        backgroundColor: Colors.blue.withOpacity(0.2),
        radius: 25,
        child: const Icon(
          Icons.group,
          color: Colors.blue,
          size: 30,
        ),
      );
    }
  }

  String _getTime() {
    if (chat.lastMessage == null) return "";

    DateTime now = DateTime.now();
    DateTime lastMessageTime = DateTime.fromMillisecondsSinceEpoch(
        chat.lastMessage!["timestamp"]);

    int minutes = now.difference(lastMessageTime).inMinutes;

    if (minutes < 1) {
      return "Just now";
    } else if (minutes < 60) {
      return "$minutes min ago";
    } else if (minutes < 1440) {
      return "${(minutes / 60).floor()} h ago";
    } else {
      return "${(minutes / 1440).floor()} d ago";
    }
  }
}