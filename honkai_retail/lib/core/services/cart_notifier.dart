import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final String itemId;
  int quantity;

  CartItem({required this.itemId, this.quantity = 1});

  Map<String, dynamic> toJson() => {'itemId': itemId, 'quantity': quantity};

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      CartItem(itemId: json['itemId'], quantity: json['quantity']);
}

class CartNotifier extends ChangeNotifier {
  static const _key = 'cart';
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);

  CartNotifier() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final list = jsonDecode(raw) as List;
      _items = list.map((e) => CartItem.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_items.map((e) => e.toJson()).toList()),
    );
  }

  void add(String itemId, {int quantity = 1}) {
    final existing = _items.where((i) => i.itemId == itemId).firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(CartItem(itemId: itemId, quantity: quantity));
    }
    _save();
    notifyListeners();
  }

  void remove(String itemId) {
    _items.removeWhere((i) => i.itemId == itemId);
    _save();
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      remove(itemId);
      return;
    }
    final existing = _items.where((i) => i.itemId == itemId).firstOrNull;
    if (existing != null) {
      existing.quantity = quantity;
      _save();
      notifyListeners();
    }
  }

  void clear() {
    _items = [];
    _save();
    notifyListeners();
  }
}

