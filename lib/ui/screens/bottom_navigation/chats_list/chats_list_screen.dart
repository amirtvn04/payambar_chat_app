import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/models/user_model.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/ui/screens/bottom_navigation/chats_list/chat_list_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class ChatsListScreen extends StatelessWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;
    return ChangeNotifierProvider(
      create: (context) => ChatListViewmodel(DatabaseService(), currentUser!),
      child: Consumer<ChatListViewmodel>(builder: (context, model, _) {
        return Padding(
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
                  : model.users.isEmpty
                      ? const Expanded(
                          child: Center(
                            child: Text("No Users yet"),
                          ),
                        )
                      : Expanded(
                          child: ListView.separated(
                            padding: const EdgeInsets.symmetric(
                                vertical: 5, horizontal: 0),
                            itemCount: model.filteredUsers.length,
                            separatorBuilder: (context, index) =>
                                8.verticalSpace,
                            itemBuilder: (context, index) {
                              final user = model.filteredUsers[index];
                              return ChatTile(
                                user: user,
                                onTap: () => Navigator.pushNamed(
                                    context, chatRoom,
                                    arguments: user),
                              );
                            },
                          ),
                        )
            ],
          ),
        );
      }),
    );
  }
}

class ChatTile extends StatelessWidget {
  const ChatTile({super.key, this.onTap, required this.user});
  final UserModel user;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      tileColor: grey.withOpacity(0.12),
      contentPadding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      leading: user.imageUrl == null
          ? CircleAvatar(
              backgroundColor: grey.withOpacity(0.5),
              radius: 25,
              child: Text(
                user.name![0],
                style: h,
              ),
            )
          : ClipOval(
              child: Image.network(
                user.imageUrl!,
                height: 50,
                width: 50,
                fit: BoxFit.fill,
              ),
            ),
      title: Text(user.name!),
      subtitle: Text(
        user.lastMessage != null ? user.lastMessage!["content"] : "",
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            user.lastMessage == null ? "" : getTime(),
            style: const TextStyle(color: grey),
          ),
          8.verticalSpace,
          user.unreadCounter == 0 || user.unreadCounter == null
              ? const SizedBox(
                  height: 15,
                )
              : CircleAvatar(
                  radius: 9.r,
                  backgroundColor: primary,
                  child: Text(
                    "${user.unreadCounter}",
                    style: small.copyWith(color: white),
                  ),
                )
        ],
      ),
    );
  }

  String getTime() {
    DateTime now = DateTime.now();

    DateTime lastMessageTime = user.lastMessage == null
        ? DateTime.now()
        : DateTime.fromMillisecondsSinceEpoch(user.lastMessage!["timestamp"]);

    int minutes = now.difference(lastMessageTime).inMinutes % 60;

    if (minutes < 60) {
      return "$minutes minutes ago";
    } else {
      return "${now.difference(lastMessageTime).inHours % 24} hours ago";
    }
  }
}
