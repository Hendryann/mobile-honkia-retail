import 'package:flutter/material.dart';
import 'package:honkai_retail/core/auth_gate.dart';
import '../pages/login_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    '/': (context) => const AuthGate(),
    '/login': (context) => const LoginPage(),
    '/home': (context) => const Scaffold(body: Center(child: Text('Home'))),
  };
}
