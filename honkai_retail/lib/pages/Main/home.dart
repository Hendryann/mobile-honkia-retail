import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:honkai_retail/core/components/item_card.dart';
import 'package:honkai_retail/core/services/api_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Map<String, dynamic>? _userInfo;
  bool _loading = true;
  List<Map<String, dynamic>> _items = [];
  List<String> _types = [];
  String? _selectedType;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _fetchItems() async {
    final url = _selectedType == null
        ? '/items?limit=4'
        : '/items?limit=4&category=$_selectedType';
    final res = await ApiService.get(url);
    if (res.statusCode == 200) {
      setState(() {
        _items = List<Map<String, dynamic>>.from(jsonDecode(res.body));
      });
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);

    final userRes = ApiService.get('/userinfo', auth: true);
    final typesRes = ApiService.get('/item/types');
    final itemsRes = ApiService.get('/items?limit=4');

    final (user, types, items) = await (userRes, typesRes, itemsRes).wait;

    if (!mounted) return;
    setState(() {
      if (user.statusCode == 200) _userInfo = jsonDecode(user.body);
      if (types.statusCode == 200) {
        _types = List<String>.from(jsonDecode(types.body));
      }
      if (items.statusCode == 200) {
        _items = List<Map<String, dynamic>>.from(jsonDecode(items.body));
      }
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return _loading
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
                    right: 16,
                    bottom: 16,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'New Arrivals',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: onSurface,
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
                                    Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Text(
                                        'Filter by Type',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: onSurface,
                                        ),
                                      ),
                                    ),
                                    ListTile(
                                      title: const Text('All'),
                                      leading: Radio<String?>(
                                        value: null,
                                        groupValue: _selectedType,
                                        onChanged: (v) async {
                                          setState(() => _selectedType = v);
                                          Navigator.pop(context);
                                          await _fetchItems();
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
                                          onChanged: (v) async {
                                            setState(() => _selectedType = v);
                                            Navigator.pop(context);
                                            await _fetchItems();
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
                          icon: Icon(
                            Icons.filter_list,
                            size: 16,
                            color: primary,
                          ),
                          label: Text(
                            'Filter',
                            style: TextStyle(color: primary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    bottom: 24,
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => ItemCard(
                        item: _items[index],
                        onTap: () => Navigator.pushNamed(
                          context,
                          '/product',
                          arguments: _items[index],
                        ),
                      ),
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
            style: TextStyle(color: Colors.white.withAlpha(217), fontSize: 14),
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
            style: TextStyle(color: Colors.white.withAlpha(191), fontSize: 13),
          ),
        ],
      ),
    );
  }
}
