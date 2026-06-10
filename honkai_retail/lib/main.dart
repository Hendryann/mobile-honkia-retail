import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:honkai_retail/core/routes.dart';
import 'package:honkai_retail/core/services/cart_notifier.dart';
import 'package:honkai_retail/core/services/theme_notifier.dart';

late final ThemeNotifier themeNotifier;
late final CartNotifier cartNotifier;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  themeNotifier = ThemeNotifier();
  cartNotifier = CartNotifier();
  await dotenv.load(fileName: '.env');
  await GoogleSignIn.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: themeNotifier,
      builder: (context, _) => MaterialApp(
        title: 'Star Retail',
        debugShowCheckedModeBanner: false,
        theme: themeNotifier.current,
        initialRoute: '/',
        routes: AppRoutes.routes,
      ),
    );
  }
}

