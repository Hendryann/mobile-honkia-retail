import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CartItem {
  final Map<String, dynamic> item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  Map<String, dynamic> toJson() => {'item': item, 'quantity': quantity};

  factory CartItem.fromJson(Map<String, dynamic> json) =>
      CartItem(item: json['item'], quantity: json['quantity']);
}

class CartNotifier extends ChangeNotifier {
  static const _key = 'cart';
  List<CartItem> _items = [];

  List<CartItem> get items => _items;
  int get totalItems => _items.fold(0, (sum, i) => sum + i.quantity);
  int get totalPrice =>
      _items.fold(0, (sum, i) => sum + (i.item['price'] as int) * i.quantity);

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

  void add(Map<String, dynamic> item, {int quantity = 1}) {
    final existing = _items
        .where((i) => i.item['id'] == item['id'])
        .firstOrNull;
    if (existing != null) {
      existing.quantity += quantity;
    } else {
      _items.add(CartItem(item: item, quantity: quantity));
    }
    _save();
    notifyListeners();
  }

  void remove(String itemId) {
    _items.removeWhere((i) => i.item['id'] == itemId);
    _save();
    notifyListeners();
  }

  void updateQuantity(String itemId, int quantity) {
    if (quantity <= 0) {
      remove(itemId);
      return;
    }
    final existing = _items.where((i) => i.item['id'] == itemId).firstOrNull;
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
