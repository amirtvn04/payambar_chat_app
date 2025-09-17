import 'package:chat_app/core/constants/colors.dart';
import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/constants/styles.dart';
import 'package:chat_app/core/enums/enums.dart';
import 'package:chat_app/core/extension/widget_extension.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:chat_app/ui/screens/auth/login/login_viewmodel.dart';
import 'package:chat_app/ui/widgets/button_widget.dart';
import 'package:chat_app/ui/widgets/textfield_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => LoginViewmodel(AuthService()),
      child: Consumer<LoginViewmodel>(builder: (context, model, _) {
        return Scaffold(
          body: Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 1.sw * 0.05, vertical: 10.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                40.verticalSpace,
                Text("Login", style: h),
                5.verticalSpace,
                Text("Please Log In To Your Account!",
                    style: body.copyWith(color: grey)),
                30.verticalSpace,
                CustomTextfield(
                  hintText: "Enter Email",
                  onChanged: model.setEmail,
                ),
                20.verticalSpace,
                CustomTextfield(
                  hintText: "Enter password",
                  onChanged: model.setPassword,
                  isPassword: true,
                ),
                30.verticalSpace,
                CustomButton(
                    loading: model.state == ViewState.loading,
                    onPressed: model.state == ViewState.loading
                        ? null
                        : () async {
                            try {
                              await model.login();
                              context
                                  .showSnackbar("User logged in successfully!");
                            } on FirebaseAuthException catch (e) {
                              context.showSnackbar(e.toString());
                            } catch (e) {
                              context.showSnackbar(e.toString());
                            }
                          },
                    text: "Login"),
                20.verticalSpace,
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have account? ",
                      style: body.copyWith(color: grey),
                    ),
                    InkWell(
                        onTap: () {
                          Navigator.pushNamed(context, signup);
                        },
                        child: Text("Signup",
                            style: body.copyWith(fontWeight: FontWeight.bold)))
                  ],
                ),
              ],
            ),
          ),
        );
      }),
    );
  }
}
