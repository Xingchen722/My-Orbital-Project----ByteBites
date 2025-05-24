
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'screens/register_screen.dart';

void main() {
  runApp(const ByteBitesApp());
}

class ByteBitesApp extends StatelessWidget {
  const ByteBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteBites',
      theme: ThemeData.dark(),
      home: LoginScreen(), // TODO: 登录界面还需实现 把const取消了
      routes: {
        '/register': (context) => const RegisterScreen(),
      },
    );
  }
}
