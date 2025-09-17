import 'dart:async';

import 'package:chat_app/core/constants/string.dart';
import 'package:chat_app/core/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer(const Duration(seconds: 3), () {
      Navigator.pushNamed(context, wrapper);
    });
  }

  @override
  void dispose() {
    super.dispose();

    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Center(
            child: InkWell(
              onTap: () {
                AuthService().logout();
              },
              child: Image.asset(
                logo,
                height: 170,
                width: 170,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
