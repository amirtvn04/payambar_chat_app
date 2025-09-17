import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomTextfield extends StatelessWidget {
  const CustomTextfield(
      {super.key,
        this.focusNode,
        this.controller,
        this.hintText,
        this.onChanged,
        this.onTap,
        this.isPassword = false,
        this.isChatText = false,
        this.isSearch = false,
        this.initialValue, // اضافه کردن
        this.enabled = true, // اضافه کردن
        this.keyboardType, // اضافه کردن برای پشتیبانی از keyboard type
        this.maxLines = 1}); // اضافه کردن

  final void Function(String)? onChanged;
  final String? hintText;
  final FocusNode? focusNode;
  final bool isSearch;
  final bool isChatText;
  final TextEditingController? controller;
  final void Function()? onTap;
  final bool isPassword;
  final String? initialValue; // اضافه شده
  final bool enabled; // اضافه شده
  final TextInputType? keyboardType; // اضافه شده
  final int maxLines; // اضافه شده

  @override
  Widget build(BuildContext context) {
    // اگر initialValue داده شده اما controller نداریم، یک controller موقت ایجاد می‌کنیم
    final textController = controller ??
        (initialValue != null ? TextEditingController(text: initialValue) : null);

    return SizedBox(
      height: isChatText ? 35.h : null,
      child: TextField(
        controller: textController,
        onChanged: onChanged,
        focusNode: focusNode,
        obscureText: isPassword,
        enabled: enabled, // اضافه شده
        keyboardType: keyboardType, // اضافه شده
        maxLines: maxLines, // اضافه شده
        decoration: InputDecoration(
            contentPadding:
            isChatText ? EdgeInsets.symmetric(horizontal: 12.w) : null,
            filled: true,
            fillColor: isChatText
                ? white
                : !enabled
                ? grey.withOpacity(0.05) // رنگ متفاوت برای حالت غیرفعال
                : grey.withOpacity(0.12),
            hintText: hintText,
            hintStyle: body.copyWith(
              color: !enabled ? grey.withOpacity(0.5) : grey, // تغییر رنگ hint در حالت غیرفعال
            ),
            suffixIcon: isSearch
                ? Container(
              height: 55,
              width: 55,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(12.r)),
              child: Image.asset(searchIcon),
            )
                : isChatText
                ? InkWell(onTap: onTap, child: const Icon(Icons.send))
                : null,
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(isChatText ? 25.r : 10.r),
                borderSide: BorderSide.none)),
      ),
    );
  }
}