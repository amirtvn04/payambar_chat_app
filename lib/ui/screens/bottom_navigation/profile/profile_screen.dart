import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/storage_service.dart';
import 'package:chat_app/ui/screens/bottom_navigation/profile/profile_viewmodel.dart';
import 'package:chat_app/ui/screens/other/user_provider.dart';
import 'package:chat_app/ui/widgets/button_widget.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../core/enums/enums.dart';
import '../../../../core/models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = Provider.of<UserProvider>(context).user;

    return ChangeNotifierProvider<ProfileViewmodel>(
      create: (context) => ProfileViewmodel(
        DatabaseService(),
        StorageService(),
        currentUser!,
      ),
      child: Consumer<ProfileViewmodel>(builder: (context, model, _) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                30.verticalSpace,
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Account Center", style: h)),
                5.verticalSpace,
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("You can change your name and other personal information here.", style: body.copyWith(color: grey))),
                20.verticalSpace,

                // اطلاعات کاربر
                CustomTextfield(
                  hintText: "Name",
                  initialValue: model.name,
                  onChanged: model.setName,
                ),
                20.verticalSpace,

                CustomTextfield(
                  hintText: "Email",
                  initialValue: model.email,
                  enabled: false, // ایمیل غیرقابل ویرایش
                  // style: body.copyWith(color: grey),
                ),
                20.verticalSpace,

                // CustomTextfield(۱
                //   hintText: "Bio",
                //   initialValue: model.bio,
                //   onChanged: model.setBio,
                //   maxLines: 3,
                // ),
                // 30.verticalSpace,

                // دکمه ذخیره
                CustomButton(
                  loading: model.state == ViewState.loading,
                  onPressed: model.state == ViewState.loading
                      ? null
                      : () async {
                    try {
                      await model.updateProfile();
                      context.showSnackbar("Profile updated successfully!");

                      // به‌روزرسانی user در provider
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      userProvider.setUser(UserModel(
                        uid: currentUser?.uid,
                        name: model.name,
                        email: currentUser?.email,
                        imageUrl: model.imageUrl,
                        bio: model.bio,
                        lastMessage: currentUser?.lastMessage,
                        unreadCounter: currentUser?.unreadCounter,
                      ));

                    } catch (e) {
                      context.showSnackbar(e.toString());
                    }
                  },
                  text: "Save Changes",
                ),
                20.verticalSpace,

                // دکمه خروج
                CustomButton(
                  text: "Logout",
                  // backgroundColor: Colors.red,
                  onPressed: () {
                    Provider.of<UserProvider>(context, listen: false).clearUser();
                    AuthService().logout();
                  },
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}