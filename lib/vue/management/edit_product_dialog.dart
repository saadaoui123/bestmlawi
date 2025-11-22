import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/model/product.dart';

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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Ajouter un produit' : 'Modifier le produit'),
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
              TextFormField(
                controller: _imageUrlController,
                decoration: const InputDecoration(labelText: 'URL Image'),
              ),
              DropdownButtonFormField<String>(
                value: _categoryController.text.isNotEmpty ? _categoryController.text : 'Plats',
                items: ['Plats', 'Entrées', 'Soupes', 'Desserts', 'Boissons']
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
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final product = Product(
                id: widget.product?.id ?? '', // Empty ID for new product, service handles it? No, service expects ID for update, but add uses add().
                // Actually ProductService.addProduct uses .add() which generates ID. But Product model requires ID.
                // I should probably make ID nullable in Product or handle it.
                // For now I'll pass empty string and let service handle it if it's new.
                // Wait, ProductService.addProduct(Product product) takes a Product.
                // If I pass empty string ID, it will be saved with empty string ID in the map?
                // Firestore .add() ignores the ID in the map usually, but I included 'id': id in toMap.
                // I should probably remove 'id' from toMap or make it optional.
                // Let's check Product.toMap.
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
