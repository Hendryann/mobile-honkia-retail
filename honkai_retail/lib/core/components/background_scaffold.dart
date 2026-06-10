import 'package:flutter/material.dart';

class BackgroundScaffold extends StatelessWidget {
  const BackgroundScaffold({
    super.key,
    required this.body,
    this.actions,
    this.currentIndex,
    this.onTabChanged,
    this.navItems,
    this.showBottomNav = true,
  });

  final Widget body;
  final List<Widget>? actions;
  final int? currentIndex;
  final ValueChanged<int>? onTabChanged;
  final bool showBottomNav;
  final List<BottomNavigationBarItem>? navItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(actions: actions),
      body: body,
      bottomNavigationBar: showBottomNav
          ? BottomNavigationBar(
              currentIndex: currentIndex ?? 0,
              onTap: onTabChanged,
              items:
                  navItems ??
                  const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Home',
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

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, this.actions});

  final List<Widget>? actions;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return AppBar(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(Icons.storefront, color: Colors.white, size: 16),
          ),
          const SizedBox(width: 8),
          Text(
            'Star Retail',
            style: TextStyle(
              color: primary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
      actions: actions,
    );
  }
}
