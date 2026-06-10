import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  const BackgroundScaffold({
    super.key,
    required this.body,
    this.actions,
    this.currentIndex,
    this.onTabChanged,
    this.showBottomNav = true,
  });

  final Widget body;
  final List<Widget>? actions;
  final int? currentIndex;
  final ValueChanged<int>? onTabChanged;
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.storefront, color: Colors.blue.shade700, size: 20),
            const SizedBox(width: 6),
            Text(
              'Star Retail',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        actions: actions,
      ),
      body: body,
      bottomNavigationBar: showBottomNav
          ? BottomNavigationBar(
              currentIndex: currentIndex ?? 0,
              onTap: onTabChanged,
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.history),
                  label: 'History',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            )
          : null,
    );
  }
}
