import 'package:flutter/material.dart';
import 'package:honkai_retail/core/components/background_scaffold.dart';
import 'package:honkai_retail/pages/home.dart';
import 'package:honkai_retail/pages/profile_page.dart';

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
      body: _pages[_index],
    );
  }
}
