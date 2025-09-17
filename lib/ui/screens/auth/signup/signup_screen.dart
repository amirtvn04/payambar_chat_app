import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/core/services/database_service.dart';
import 'package:chat_app/core/services/storage_service.dart';
import 'package:chat_app/ui/screens/auth/signup/signup_viewmodel.dart';
import 'package:chat_app/ui/widgets/button_widget.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class SignupScreen extends StatelessWidget {
  const SignupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<SignupViewmodel>(
      create: (context) =>
          SignupViewmodel(AuthService(), DatabaseService(), StorageService()),
      child: Consumer<SignupViewmodel>(builder: (context, model, _) {
        return Scaffold(
          body: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                40.verticalSpace,
                Text("Create your account", style: h),
                5.verticalSpace,
                Text("Please provide the details",
                    style: body.copyWith(color: grey)),
                30.verticalSpace,
                InkWell(
                  onTap: () {
                    model.pickImage();
                  },
                  child: model.image == null
                      ? CircleAvatar(
                          radius: 40.r,
                          child: const Icon(Icons.camera_alt),
                        )
                      : CircleAvatar(
                          radius: 40.r,
                          backgroundImage: FileImage(model.image!),
                        ),
                ),
                20.verticalSpace,
                CustomTextfield(
                  hintText: "Enter Name",
                  onChanged: model.setName,
                ),
                20.verticalSpace,
                CustomTextfield(
                  hintText: "Enter Email",
                  onChanged: model.setEmail,
                ),
                20.verticalSpace,
                CustomTextfield(
                  hintText: "Enter Password",
                  onChanged: model.setPassword,
                  isPassword: true,
                ),
                20.verticalSpace,
                CustomTextfield(
                  hintText: "Confirm Password",
                  onChanged: model.setConfirmPassword,
                  isPassword: true,
                ),
                30.verticalSpace,
                CustomButton(
                    loading: model.state == ViewState.loading,
                    onPressed: model.state == ViewState.loading
                        ? null
                        : () async {
                            try {
                              await model.signup();
                              context
                                  .showSnackbar("User signed up successfully!");

                              Navigator.pop(context);
                            } on FirebaseAuthException catch (e) {
                              context.showSnackbar(e.toString());
                            } catch (e) {
                              context.showSnackbar(e.toString());
                            }
                          },
                    text: "Sign Up"),
                20.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have account? ",
                      style: body.copyWith(color: grey),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, login);
                        },
                        child: Text("Login",
                            style: body.copyWith(fontWeight: FontWeight.bold)))
                  ],
                )
              ],
            ),
          ),
        );
      }),
    );
  }
}
