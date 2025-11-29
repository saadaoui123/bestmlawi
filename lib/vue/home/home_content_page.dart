import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/service/cart_service.dart';
import 'package:projet_best_mlewi/service/product_service.dart';
import 'package:projet_best_mlewi/model/product.dart';
import 'package:provider/provider.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  // 1. Variables pour gérer l'état de la recherche
  final TextEditingController _searchController = TextEditingController();
  List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Écouter les changements du contrôleur de recherche
    _searchController.addListener(() {
      if (_searchQuery != _searchController.text) {
        setState(() {
          _searchQuery = _searchController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 2. Méthode pour obtenir la liste filtrée (plus propre sans état séparé)
  List<Product> _getFilteredProducts() {
    if (_searchQuery.isEmpty) {
      return _allProducts;
    } else {
      return _allProducts
          .where((product) =>
      product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          product.description.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }
  }

  // Helper method to validate image URLs
  bool _isValidImageUrl(String url) {
    if (url.isEmpty) return false;
    // Reject Google search URLs and other invalid URLs
    if (url.contains('google.com/search')) return false;
    // Accept Firebase Storage URLs and common image hosting
    if (url.startsWith('https://firebasestorage.googleapis.com/')) return true;
    // Accept URLs ending with image extensions
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.webp', '.bmp'];
    return imageExtensions.any((ext) => url.toLowerCase().endsWith(ext));
  }

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController, // Utilisation du contrôleur
              decoration: InputDecoration(
                hintText: 'Rechercher des plats...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                image: const DecorationImage(
                  image: AssetImage('assets/images/banner.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: const Center(
                child: Text(
                  'Découvrez nos saveurs authentiques, livrées à votre porte.',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notre Menu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DefaultTabController(
            length: 4,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: Colors.amber[800],
                  labelColor: Colors.amber[800],
                  unselectedLabelColor: Colors.grey,
                  isScrollable: true,
                  tabs: const [
                    Tab(text: 'Plats'),
                    Tab(text: 'Entrées'),
                    Tab(text: 'Soupes'),
                    Tab(text: 'Desserts'),
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: StreamBuilder<List<Product>>(
                    stream: productService.getAllProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Erreur: ${snapshot.error}'));
                      }

                      _allProducts = snapshot.data ?? [];
                      final filteredList = _getFilteredProducts();

                      if (_searchQuery.isNotEmpty && filteredList.isEmpty) {
                        return const Center(
                          child: Text('Aucun plat ne correspond à votre recherche.'),
                        );
                      }

                      return TabBarView(
                        children: [
                          _buildMenuItemGrid(filteredList.where((p) => p.category == 'Plats').toList()),
                          _buildMenuItemGrid(filteredList.where((p) => p.category == 'Entrées').toList()),
                          _buildMenuItemGrid(filteredList.where((p) => p.category == 'Soupes').toList()),
                          _buildMenuItemGrid(filteredList.where((p) => p.category == 'Desserts').toList()),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemGrid(List<Product> items) {
    if (items.isEmpty) {
      return Center(child: Text(_searchQuery.isEmpty ? 'Aucun produit dans cette catégorie' : ''));
    }
    return GridView.builder(
      padding: const EdgeInsets.all(16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 0.75,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final product = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product_detail',
              arguments: product.toMap(),
            );
          },
          child: Card(
            elevation: 4,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                    child: product.imageUrl.isNotEmpty && _isValidImageUrl(product.imageUrl)
                        ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) =>
                          Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                          ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[200],
                          child: const Center(child: CircularProgressIndicator()),
                        );
                      },
                    )
                        : Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.restaurant, size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        product.description,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${product.price.toStringAsFixed(2)} DT',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber[800]),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<CartService>(context, listen: false).addItem(product.toMap());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${product.name} ajouté au panier!')),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.amber[800],
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Ajouter'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
