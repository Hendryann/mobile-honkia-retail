import 'package:flutter/material.dart';
import 'package:honkai_retail/core/components/background_scaffold.dart';
import 'package:honkai_retail/pages/Main/profile_page.dart';
import 'package:honkai_retail/pages/Main/home.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  final _pages = const [
    Home(),
    Center(child: Text('History')), // stub
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      currentIndex: _index,
      onTabChanged: (i) => setState(() => _index = i),
      actions: _index == 0
          ? [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () => Navigator.pushNamed(context, '/search'),
              ),
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
            ]
          : null,
      body: _pages[_index],
    );
  }
}
