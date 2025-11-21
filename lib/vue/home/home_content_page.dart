import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/service/cart_service.dart';
import 'package:provider/provider.dart';

class HomeContentPage extends StatefulWidget {
  const HomeContentPage({super.key});

  @override
  State<HomeContentPage> createState() => _HomeContentPageState();
}

class _HomeContentPageState extends State<HomeContentPage> {
  final List<Map<String, dynamic>> menuItems = [
    {
      'name': 'Tajine de Poulet aux Citrons Confits',
      'description': 'Un plat marocain classique avec poulet',
      'price': 6.5,
      'image': 'assets/images/tajine.png',
      'category': 'Populaire',
    },
    {
      'name': 'Couscous Royal',
      'description': 'Couscous traditionnel avec agneau, poulet,',
      'price': 8.8,
      'image': 'assets/images/couscous.png',
      'category': 'Populaire',
    },
    {
      'name': 'Salade Composée',
      'description': 'Salade fraîcheur aux légumes de saison',
      'price': 4.0,
      'image': 'assets/images/salad.png',
      'category': 'Végétarien',
    },
    {
      'name': 'Pizza Végétarienne',
      'description': 'Délicieuse pizza aux légumes frais',
      'price': 7.5,
      'image': 'assets/images/pizza.png',
      'category': 'Végétarien',
    },
    {
      'name': 'Soupe du Jour',
      'description': 'Soupe maison avec des ingrédients frais',
      'price': 3.0,
      'image': 'assets/images/soup.png',
      'category': 'Nouveautés',
    },
  ];

  List<Map<String, dynamic>> _getMenuItemsByCategory(String category) {
    return menuItems.where((item) => item['category'] == category).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Rechercher des plats...',
                prefixIcon: const Icon(Icons.search),
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Notre Menu',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                TabBar(
                  indicatorColor: Colors.amber[800],
                  labelColor: Colors.amber[800],
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Populaire'),
                    Tab(text: 'Nouveautés'),
                    Tab(text: 'Végétarien'),
                  ],
                ),
                SizedBox(
                  height: 500,
                  child: TabBarView(
                    children: [
                      _buildMenuItemGrid(_getMenuItemsByCategory('Populaire')),
                      _buildMenuItemGrid(_getMenuItemsByCategory('Nouveautés')),
                      _buildMenuItemGrid(_getMenuItemsByCategory('Végétarien')),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemGrid(List<Map<String, dynamic>> items) {
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
        final item = items[index];
        return GestureDetector(
          onTap: () {
            Navigator.pushNamed(
              context,
              '/product_detail',
              arguments: item,
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
                    child: Image.asset(
                      item['image'] ?? 'assets/images/placeholder.png',
                      fit: BoxFit.cover,
                      width: double.infinity,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['description'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${item['price']} DT',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.amber[800]),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Provider.of<CartService>(context, listen: false).addItem(item);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('${item['name']} ajouté au panier!')),
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
