import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:honkai_retail/core/components/background_scaffold.dart';
import 'package:honkai_retail/core/services/api_service.dart';
import 'package:honkai_retail/pages/Main/profile_page.dart';
import 'package:honkai_retail/pages/Product/inventory_page.dart';
import 'package:honkai_retail/pages/Main/home.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;
  bool _isAdmin = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final res = await ApiService.get('/userinfo', auth: true);
    if (!mounted) return;
    setState(() {
      if (res.statusCode == 200) {
        final user = jsonDecode(res.body);
        _isAdmin = user['isadmin'] == 1;
      }
      _loading = false;
    });
  }

  List<Widget> get _pages => [
    const Home(),
    if (_isAdmin) const InventoryPage(),
    const ProfilePage(),
  ];

  List<BottomNavigationBarItem> get _navItems => [
    const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
    if (_isAdmin)
      const BottomNavigationBarItem(
        icon: Icon(Icons.inventory_2_outlined),
        label: 'Inventory',
      ),
    const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
      navItems: _navItems,
      body: _pages[_index],
    );
  }
}

