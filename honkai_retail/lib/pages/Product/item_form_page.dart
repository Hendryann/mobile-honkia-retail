import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:honkai_retail/core/services/api_service.dart';
import 'package:honkai_retail/core/components/background_scaffold.dart';

class ItemFormPage extends StatefulWidget {
  const ItemFormPage({super.key, this.item});
  final Map<String, dynamic>? item;

  @override
  State<ItemFormPage> createState() => _ItemFormPageState();
}

class _ItemFormPageState extends State<ItemFormPage> {
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _stockController = TextEditingController();
  final _priceController = TextEditingController();
  File? _imageFile;
  bool _loading = false;
  String? _error;

  bool get _isEdit => widget.item != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      _nameController.text = widget.item!['name'];
      _typeController.text = widget.item!['type'];
      _descriptionController.text = widget.item!['description'];
      _stockController.text = widget.item!['stock'].toString();
      _priceController.text = widget.item!['price'].toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _descriptionController.dispose();
    _stockController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  String? _validate() {
    if (_nameController.text.isEmpty) return 'Name cannot be empty';
    if (_typeController.text.isEmpty) return 'Type cannot be empty';
    if (_descriptionController.text.isEmpty) {
      return 'Description cannot be empty';
    }
    final stock = int.tryParse(_stockController.text);
    if (stock == null || stock < 0) {
      return 'Stock must be a valid positive number';
    }
    final price = int.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      return 'Price must be a valid positive number';
    }
    return null;
  }

  Future<void> _submit() async {
    final error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final body = {
        'name': _nameController.text,
        'type': _typeController.text.toLowerCase(),
        'description': _descriptionController.text,
        'stock': int.parse(_stockController.text),
        'price': int.parse(_priceController.text),
      };

      String? itemId;

      if (_isEdit) {
        final res = await ApiService.patch(
          '/item/${widget.item!['id']}',
          body: body,
          auth: true,
        );
        if (!mounted) return;
        if (res.statusCode != 200) {
          setState(() => _error = 'Failed to update item');
          return;
        }
        itemId = widget.item!['id'];
      } else {
        final res = await ApiService.post('/item/new', body: body, auth: true);
        if (!mounted) return;
        if (res.statusCode != 200) {
          setState(() => _error = 'Failed to create item');
          return;
        }
        itemId = jsonDecode(res.body)['id'];
      }

      // Upload image if selected
      if (_imageFile != null && itemId != null) {
        final bytes = await _imageFile!.readAsBytes();
        final res = await ApiService.put(
          '/item/$itemId/image',
          body: bytes,
          auth: true,
          contentType: 'application/octet-stream',
        );
        if (!mounted) return;
        if (res.statusCode != 200) {
          setState(() => _error = 'Item saved but image upload failed');
          return;
        }
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'Could not reach server');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final cardColor = Theme.of(context).cardColor;
    final onSurface = Theme.of(context).colorScheme.onSurface;

    return BackgroundScaffold(
      showBottomNav: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: _showImageSourceSheet,
              child: Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: onSurface.withAlpha(13),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: onSurface.withAlpha(51)),
                ),
                child: _imageFile != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(_imageFile!, fit: BoxFit.cover),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: onSurface.withAlpha(77),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap to add image',
                            style: TextStyle(color: onSurface.withAlpha(128)),
                          ),
                        ],
                      ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Field(
                    label: 'Name',
                    controller: _nameController,
                    onSurface: onSurface,
                    primary: primary,
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Type',
                    controller: _typeController,
                    onSurface: onSurface,
                    primary: primary,
                    hint: 'e.g. tool, resource',
                  ),
                  const SizedBox(height: 16),
                  _Field(
                    label: 'Description',
                    controller: _descriptionController,
                    onSurface: onSurface,
                    primary: primary,
                    maxLines: 4,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Stock',
                          controller: _stockController,
                          onSurface: onSurface,
                          primary: primary,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _Field(
                          label: 'Price',
                          controller: _priceController,
                          onSurface: onSurface,
                          primary: primary,
                          keyboardType: TextInputType.number,
                          prefix: '\$',
                        ),
                      ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      _error!,
                      style: const TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _submit,
                      icon: _loading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isEdit ? 'Save Changes' : 'Add Item'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    required this.onSurface,
    required this.primary,
    this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.prefix,
  });

  final String label;
  final TextEditingController controller;
  final Color onSurface;
  final Color primary;
  final String? hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? prefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: onSurface, fontSize: 13)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixText: prefix,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: onSurface.withAlpha(51),
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
