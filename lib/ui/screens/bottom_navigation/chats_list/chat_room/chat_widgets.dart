import 'package:payambar/core/constants/colors.dart';
import 'package:payambar/core/constants/styles.dart';
import 'package:payambar/core/models/message_model.dart';
import 'package:payambar/ui/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../../../../core/models/group_model.dart';

class BottomField extends StatelessWidget {
  const BottomField({super.key, this.onTap, this.onChanged, this.controller});
  final void Function()? onTap;
  final void Function(String)? onChanged;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: grey.withOpacity(0.2),
      padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 25.h),
      child: Row(
        children: [
          InkWell(
            onTap: null,
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: white,
              child: const Icon(Icons.add),
            ),
          ),
          10.horizontalSpace,
          Expanded(
              child: CustomTextfield(
                controller: controller,
                isChatText: true,
                hintText: "Write message..",
                onChanged: onChanged,
                onTap: onTap,
              ))
        ],
      ),
    );
  }
}

class ChatBubble extends StatelessWidget {
  const ChatBubble(
      {super.key, this.isCurrentUser = true, required this.message});
  final bool isCurrentUser;
  final Message message;

  @override
  Widget build(BuildContext context) {
    final borderRadius = isCurrentUser
        ? BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
        bottomLeft: Radius.circular(16.r))
        : BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
        bottomRight: Radius.circular(16.r));
    final alignment =
    isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: 1.sw * 0.75, minWidth: 50.w),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: isCurrentUser ? primary : grey.withOpacity(0.2),
            borderRadius: borderRadius),
        child: Column(
          crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Text(
              message.content!,
              style: body.copyWith(color: isCurrentUser ? white : null),
            ),
            5.verticalSpace,
            Text(
              DateFormat('hh:mm a').format(message.timestamp!),
              style: small.copyWith(color: isCurrentUser ? white : null),
            )
          ],
        ),
      ),
    );
  }
}

class GroupChatBubble extends StatelessWidget {
  const GroupChatBubble({
    super.key,
    this.isCurrentUser = true,
    required this.message,
    required this.group,
  });

  final bool isCurrentUser;
  final Message message;
  final GroupModel group;

  @override
  Widget build(BuildContext context) {
    final borderRadius = isCurrentUser
        ? BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
        bottomLeft: Radius.circular(16.r))
        : BorderRadius.only(
        topLeft: Radius.circular(16.r),
        topRight: Radius.circular(16.r),
        bottomRight: Radius.circular(16.r));

    final alignment = isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
      alignment: alignment,
      child: Container(
        constraints: BoxConstraints(maxWidth: 1.sw * 0.75, minWidth: 50.w),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
            color: isCurrentUser ? primary : grey.withOpacity(0.2),
            borderRadius: borderRadius),
        child: Column(
          crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            if (!isCurrentUser) // نمایش نام فرستنده برای پیام‌های دیگران
              Text(
                message.senderName ?? 'Unknown',
                style: small.copyWith(
                  color: isCurrentUser ? white : Colors.blue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!isCurrentUser) 5.verticalSpace,
            Text(
              message.content!,
              style: body.copyWith(color: isCurrentUser ? white : null),
            ),
            5.verticalSpace,
            Text(
              DateFormat('hh:mm a').format(message.timestamp!),
              style: small.copyWith(color: isCurrentUser ? white : null),
            )
          ],
        ),
      ),
    );
  }
}