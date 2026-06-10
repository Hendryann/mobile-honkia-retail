import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:honkai_retail/core/services/api_service.dart';
import 'package:honkai_retail/main.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? _userInfo;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final res = await ApiService.get('/userinfo', auth: true);
    if (!mounted) return;
    if (res.statusCode == 200) {
      setState(() => _userInfo = jsonDecode(res.body));
    }
  }

  Future<void> _logout() async {
    await const FlutterSecureStorage().delete(key: 'jwt');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _userInfo?['name'] ?? '',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _userInfo?['isadmin'] == 1 ? 'Administrator' : 'Member',
                style: TextStyle(color: onSurface.withAlpha(128), fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListenableBuilder(
            listenable: themeNotifier,
            builder: (context, _) => ListTile(
              leading: Icon(Icons.palette_outlined, color: primary),
              title: Text('Appearance', style: TextStyle(color: onSurface)),
              subtitle: Text(
                themeNotifier.currentName == 'dark'
                    ? 'Dark mode'
                    : 'Light mode',
                style: TextStyle(color: onSurface.withAlpha(128), fontSize: 12),
              ),
              trailing: Switch(
                value: themeNotifier.currentName == 'dark',
                onChanged: (v) => themeNotifier.setTheme(v ? 'dark' : 'light'),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ),
      ],
    );
  }
}
