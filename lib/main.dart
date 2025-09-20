import 'package:payambar/core/services/database_service.dart';
import 'package:payambar/core/utils/route_utils.dart';
import 'package:payambar/firebase_options.dart';
import 'package:payambar/ui/screens/other/user_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:payambar/ui/screens/wrapper/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ChatApp());
}

class ChatApp extends StatelessWidget {
  const ChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      builder: (context, child) => ChangeNotifierProvider(
        create: (context) => UserProvider(DatabaseService()),
        child: const MaterialApp(
          title: 'Payambar',
          debugShowCheckedModeBanner: false,
          onGenerateRoute: RouteUtils.onGenerateRoute,
          home: Wrapper(),
        ),
      ),
    );
  }
}
