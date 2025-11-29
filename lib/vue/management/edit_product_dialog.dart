import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:projet_best_mlewi/model/product.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:typed_data';
import 'package:flutter_image_compress/flutter_image_compress.dart';

class EditProductDialog extends StatefulWidget {
  final Product? product;

  const EditProductDialog({super.key, this.product});

  @override
  State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  late TextEditingController _categoryController;

  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageBytes;
  String? _imageFileName;
  bool _uploading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _descriptionController = TextEditingController(text: widget.product?.description ?? '');
    _priceController = TextEditingController(text: widget.product?.price.toString() ?? '');
    _imageUrlController = TextEditingController(text: widget.product?.imageUrl ?? '');
    _categoryController = TextEditingController(text: widget.product?.category ?? 'Plats');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        Uint8List finalBytes = bytes;
        
        // Try to compress image
        try {
          final compressedBytes = await FlutterImageCompress.compressWithList(
            bytes,
            minHeight: 1080,
            minWidth: 1080,
            quality: 70,
          );
          finalBytes = compressedBytes;
        } catch (e) {
          debugPrint('Compression error: $e');
          // Fallback to original bytes if compression fails
        }

        setState(() {
          _imageBytes = finalBytes;
          _imageFileName = image.name ?? 'image_${DateTime.now().millisecondsSinceEpoch}.jpg';
        });
        
        // Upload to Firebase Storage
        await _uploadImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la sélection: $e')),
        );
      }
    }
  }

  Future<void> _uploadImage() async {
    if (_imageBytes == null || _imageFileName == null) return;

    setState(() => _uploading = true);

    try {
      // Create a reference to Firebase Storage
      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('products/${DateTime.now().millisecondsSinceEpoch}_$_imageFileName');

      // Upload the file
      final uploadTask = imageRef.putData(_imageBytes!);
      
      // Wait for upload to complete
      final snapshot = await uploadTask;
      
      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();
      
      setState(() {
        _imageUrlController.text = downloadUrl;
        _uploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image uploadée avec succès!')),
        );
      }
    } catch (e) {
      setState(() => _uploading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur d\'upload: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Ajouter un plat' : 'Modifier le plat'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextFormField(
                controller: _priceController,
                decoration: const InputDecoration(labelText: 'Prix (DT)'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Champ requis';
                  if (double.tryParse(value) == null) return 'Prix invalide';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              // Image selection section
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _imageUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL Image',
                        hintText: 'ou utilisez le bouton →',
                      ),
                      enabled: !_uploading,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _uploading ? null : _pickImage,
                    icon: _uploading 
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.image),
                    label: Text(_uploading ? 'Upload...' : 'Choisir'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              if (_imageBytes != null) ...[
                const SizedBox(height: 8),
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categoryController.text.isNotEmpty ? _categoryController.text : 'Plats',
                items: [
                  'Plats',
                  'Mlawi',
                  'Sandwichs',
                  'Tacos',
                  'Pizza',
                  'Plats Tunisiens',
                  'Entrées',
                  'Soupes',
                  'Desserts',
                  'Boissons'
                ]
                    .map((label) => DropdownMenuItem(
                          value: label,
                          child: Text(label),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _categoryController.text = value;
                    });
                  }
                },
                decoration: const InputDecoration(labelText: 'Catégorie'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: _uploading ? null : () {
            if (_formKey.currentState!.validate()) {
              final product = Product(
                id: widget.product?.id ?? '',
                name: _nameController.text,
                description: _descriptionController.text,
                price: double.parse(_priceController.text),
                imageUrl: _imageUrlController.text,
                category: _categoryController.text,
              );
              Navigator.pop(context, product);
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
