import 'package:flutter/material.dart';
import 'package:honkai_retail/core/style/theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  static const _key = 'theme';

  ThemeData _current = AppTheme.light;
  String _currentName = 'light';

  ThemeData get current => _current;
  String get currentName => _currentName;

  ThemeNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && AppTheme.themes.containsKey(saved)) {
      _current = AppTheme.themes[saved]!;
      _currentName = saved;
      notifyListeners();
    }
  }

  Future<void> setTheme(String name) async {
    if (!AppTheme.themes.containsKey(name)) return;
    _current = AppTheme.themes[name]!;
    _currentName = name;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, name);
    notifyListeners();
  }
}
