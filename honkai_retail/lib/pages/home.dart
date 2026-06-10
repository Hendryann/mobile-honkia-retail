import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:honkai_retail/core/components/background_scaffold.dart';
import '../core/components/item_card.dart';
import '../core/services/api_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic>? _userInfo;
  bool _loading = true;
  List<Map<String, dynamic>> _allItems = [];
  List<Map<String, dynamic>> _items = [];
  List<String> get _types =>
      _allItems.map((i) => i['type'] as String).toSet().toList();
  String? _selectedType;
  @override
  void initState() {
    super.initState();
    _load();
  }

  void _applyFilter() {
    setState(() {
      final filtered = _selectedType == null
          ? _allItems
          : _allItems.where((i) => i['type'] == _selectedType).toList();
      _items = filtered.take(4).toList();
    });
  }

  Future<void> _load() async {
    final results = await Future.wait([
      ApiService.get('/userinfo', auth: true),
      ApiService.get('/items'),
    ]);

    setState(() {
      if (results[0].statusCode == 200) {
        _userInfo = jsonDecode(results[0].body);
      }
      if (results[1].statusCode == 200) {
        _allItems = List<Map<String, dynamic>>.from(
          jsonDecode(results[1].body),
        );
        if (!mounted) return;
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BackgroundScaffold(
      actions: [
        IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {},
        ),
      ],
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _WelcomeBanner(name: _userInfo?['name'] ?? ''),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      top: 0,
                      right: 16,
                      bottom: 16,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'New Arrivals',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (context) => SafeArea(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.all(16),
                                        child: Text(
                                          'Filter by Type',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      ListTile(
                                        title: const Text('All'),
                                        leading: Radio<String?>(
                                          value: null,
                                          groupValue: _selectedType,
                                          onChanged: (v) {
                                            setState(() => _selectedType = v);
                                            _applyFilter();
                                            Navigator.pop(context);
                                          },
                                        ),
                                      ),
                                      ..._types.map(
                                        (type) => ListTile(
                                          title: Text(
                                            type[0].toUpperCase() +
                                                type.substring(1),
                                          ),
                                          leading: Radio<String?>(
                                            value: type,
                                            groupValue: _selectedType,
                                            onChanged: (v) {
                                              setState(() => _selectedType = v);
                                              _applyFilter();
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                    ],
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.filter_list, size: 16),
                            label: const Text('Filter'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      top: 0,
                      left: 16,
                      right: 16,
                      bottom: 16,
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            ItemCard(item: _items[index], onTap: () {}),
                        childCount: _items.length,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75,
                          ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _WelcomeBanner extends StatelessWidget {
  const _WelcomeBanner({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.blue.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Discover the latest arrivals below.',
            style: TextStyle(
              color: Colors.white.withOpacity(0.75),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

