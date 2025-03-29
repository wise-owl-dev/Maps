import 'package:flutter/material.dart';
import 'package:maps_app/screens/signup/signup_screen.dart';
import 'screens/login/login_screen.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/menu/admin_menu_screen.dart';
import 'screens/menu/operador_menu_screen.dart';
import 'screens/menu/user_menu_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Login App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/admin-menu': (context) => const AdminMenuScreen(),
        '/operador-menu': (context) => const OperadorMenuScreen(),
        '/user-menu': (context) => const UserMenuScreen(),
      },
    );
  }
}
