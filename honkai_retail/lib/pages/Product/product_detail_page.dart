import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:honkai_retail/core/components/background_scaffold.dart';
import 'package:honkai_retail/core/services/api_service.dart';
import 'package:honkai_retail/main.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key, required this.item});
  final Map<String, dynamic> item;

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  Uint8List? _image;
  bool _imageLoading = true;
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  Future<void> _loadImage() async {
    final res = await ApiService.get('/item/${widget.item['id']}/image');
    if (!mounted) return;
    setState(() {
      if (res.statusCode == 200 && res.bodyBytes.isNotEmpty) {
        _image = res.bodyBytes;
      }
      _imageLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final stock = item['stock'] as int;
    final inStock = stock > 0;
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final primary = Theme.of(context).colorScheme.primary;

    return BackgroundScaffold(
      showBottomNav: false,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 280,
                    width: double.infinity,
                    color: onSurface.withAlpha(13),
                    child: _imageLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _image != null
                        ? Image.memory(_image!, fit: BoxFit.cover)
                        : Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: onSurface.withAlpha(77),
                            ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['type'].toString()[0].toUpperCase() +
                              item['type'].toString().substring(1),
                          style: TextStyle(
                            color: onSurface.withAlpha(128),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item['name'],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Text(
                              '\$${item['price']}',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: primary,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              inStock ? '$stock in stock' : 'OUT OF STOCK',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: inStock ? Colors.orange : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Text(
                          'Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: onSurface,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['description'],
                          style: TextStyle(
                            color: onSurface.withAlpha(179),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: onSurface.withAlpha(51)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                      ),
                      Text(
                        '$_quantity',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: onSurface,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: _quantity < stock
                            ? () => setState(() => _quantity++)
                            : null,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: inStock
                        ? () {
                            cartNotifier.add(item, quantity: _quantity);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to Cart')),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Add to Cart',
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
      ),
    );
  }
}
