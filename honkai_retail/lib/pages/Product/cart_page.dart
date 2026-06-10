import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:honkai_retail/core/components/background_scaffold.dart';
import 'package:honkai_retail/core/services/api_service.dart';
import 'package:honkai_retail/main.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  Map<String, Map<String, dynamic>> _itemCache = {};
  Map<String, Uint8List?> _imageCache = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    final ids = cartNotifier.items.map((i) => i.itemId).toList();
    final results = await Future.wait(
      ids.map((id) => ApiService.get('/item/$id')),
    );

    final cache = <String, Map<String, dynamic>>{};
    for (var i = 0; i < ids.length; i++) {
      if (results[i].statusCode == 200) {
        cache[ids[i]] = jsonDecode(results[i].body);
      }
    }

    final imageResults = await Future.wait(
      ids.map((id) => ApiService.get('/item/$id/image')),
    );
    final imageCache = <String, Uint8List?>{};
    for (var i = 0; i < ids.length; i++) {
      final res = imageResults[i];
      imageCache[ids[i]] = res.statusCode == 200 && res.bodyBytes.isNotEmpty
          ? res.bodyBytes
          : null;
    }

    if (!mounted) return;
    setState(() {
      _itemCache = cache;
      _imageCache = imageCache;
      _loading = false;
    });
  }

  int get _total => cartNotifier.items.fold(0, (sum, cartItem) {
    final item = _itemCache[cartItem.itemId];
    if (item == null) return sum;
    return sum + (item['price'] as int) * cartItem.quantity;
  });

  Future<void> _checkout() async {
    for (final cartItem in cartNotifier.items) {
      final item = _itemCache[cartItem.itemId];
      if (item == null) continue;
      if ((item['stock'] as int) < cartItem.quantity) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${item['name']} does not have enough stock')),
        );
        return;
      }
    }

    final results = await Future.wait(
      cartNotifier.items.map(
        (cartItem) => ApiService.post(
          '/item/${cartItem.itemId}/purchase',
          body: {'amount': cartItem.quantity},
          auth: true,
        ),
      ),
    );

    if (!mounted) return;

    final failed = results.where((r) => r.statusCode != 200).toList();
    if (failed.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Checkout failed, please try again')),
      );
      return;
    }

    cartNotifier.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Order placed successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return BackgroundScaffold(
      showBottomNav: false,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListenableBuilder(
              listenable: cartNotifier,
              builder: (context, _) {
                final items = cartNotifier.items;

                if (items.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_cart_outlined,
                          size: 64,
                          color: onSurface.withAlpha(77),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Your cart is empty',
                          style: TextStyle(
                            color: onSurface.withAlpha(128),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: [
                    Expanded(
                      child: ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final cartItem = items[index];
                          final item = _itemCache[cartItem.itemId];
                          final image = _imageCache[cartItem.itemId];

                          if (item == null) return const SizedBox();

                          return GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/product',
                                arguments: _itemCache[cartItem.itemId],
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: cardColor,
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withAlpha(13),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Container(
                                      width: 72,
                                      height: 72,
                                      color: onSurface.withAlpha(13),
                                      child: image != null
                                          ? Image.memory(
                                              image,
                                              fit: BoxFit.cover,
                                            )
                                          : Icon(
                                              Icons.image_not_supported,
                                              color: onSurface.withAlpha(77),
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item['name'],
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: onSurface,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          '\$${item['price']}',
                                          style: TextStyle(
                                            color: primary,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: onSurface.withAlpha(51),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            IconButton(
                                              icon: const Icon(
                                                Icons.remove,
                                                size: 16,
                                              ),
                                              onPressed: () =>
                                                  cartNotifier.updateQuantity(
                                                    cartItem.itemId,
                                                    cartItem.quantity - 1,
                                                  ),
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              iconSize: 16,
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              child: Text(
                                                '${cartItem.quantity}',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: onSurface,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(
                                                Icons.add,
                                                size: 16,
                                              ),
                                              onPressed: () {
                                                final stock =
                                                    _itemCache[cartItem
                                                            .itemId]?['stock']
                                                        as int? ??
                                                    0;
                                                if (cartItem.quantity < stock) {
                                                  cartNotifier.updateQuantity(
                                                    cartItem.itemId,
                                                    cartItem.quantity + 1,
                                                  );
                                                }
                                              },
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              iconSize: 16,
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      GestureDetector(
                                        onTap: () => cartNotifier.remove(
                                          cartItem.itemId,
                                        ),
                                        child: const Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.only(
                        left: 16,
                        top: 12,
                        right: 16,
                        bottom: 32,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(15),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Total',
                                style: TextStyle(
                                  color: onSurface.withAlpha(128),
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                '\$$_total',
                                style: TextStyle(
                                  color: primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _checkout,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text(
                                'Checkout',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
