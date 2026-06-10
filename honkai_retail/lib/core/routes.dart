import 'package:flutter/material.dart';
import 'package:honkai_retail/core/auth_gate.dart';
import 'package:honkai_retail/pages/Main/main_layout.dart';
import 'package:honkai_retail/pages/Main/profile_page.dart';
import 'package:honkai_retail/pages/Product/cart_page.dart';
import 'package:honkai_retail/pages/Product/product_detail_page.dart';
import 'package:honkai_retail/pages/login_page.dart';

class AppRoutes {
  static Map<String, WidgetBuilder> get routes => {
    '/': (context) => const AuthGate(),
    '/login': (context) => const LoginPage(),
    '/home': (context) => const MainLayout(),
    '/profile': (context) => const ProfilePage(),
    '/product': (context) {
      final item =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ProductDetailPage(item: item);
    },
    '/cart': (context) => const CartPage(),
  };
}
