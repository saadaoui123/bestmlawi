import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/product_service.dart';
import 'package:projet_best_mlewi/model/product.dart';
import 'edit_product_dialog.dart';

class ProductsManagementTab extends StatelessWidget {
  const ProductsManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);

    return Scaffold(
      body: StreamBuilder<List<Product>>(
        stream: productService.getAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text('Aucun produit trouvé'));
          }

          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: product.imageUrl.isNotEmpty ? NetworkImage(product.imageUrl) : null,
                  child: product.imageUrl.isEmpty ? const Icon(Icons.fastfood) : null,
                ),
                title: Text(product.name),
                subtitle: Text('${product.price.toStringAsFixed(2)} DT - ${product.category}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () async {
                        final updatedProduct = await showDialog<Product>(
                          context: context,
                          builder: (context) => EditProductDialog(product: product),
                        );
                        if (updatedProduct != null) {
                          // Preserve ID for update
                          final productToUpdate = Product(
                            id: product.id,
                            name: updatedProduct.name,
                            description: updatedProduct.description,
                            price: updatedProduct.price,
                            imageUrl: updatedProduct.imageUrl,
                            category: updatedProduct.category,
                            rating: product.rating,
                            reviewCount: product.reviewCount,
                            ingredients: product.ingredients,
                          );
                          productService.updateProduct(productToUpdate);
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Confirmer la suppression'),
                            content: Text('Voulez-vous vraiment supprimer ${product.name} ?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Annuler'),
                              ),
                              TextButton(
                                onPressed: () {
                                  productService.deleteProduct(product.id);
                                  Navigator.pop(context);
                                },
                                child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newProduct = await showDialog<Product>(
            context: context,
            builder: (context) => const EditProductDialog(),
          );
          if (newProduct != null) {
            productService.addProduct(newProduct);
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
