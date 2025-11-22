import 'package:flutter/material.dart';

class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final double rating;
  final int reviewCount;
  final List<String> ingredients;

  // Keep backward compatibility with 'image' parameter
  String get image => imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    this.rating = 4.5,
    this.reviewCount = 0,
    this.ingredients = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'imageUrl': imageUrl,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'ingredients': ingredients,
    };
  }
}

class ProductService extends ChangeNotifier {
  List<Product> _products = [
    Product(
      id: '1',
      name: 'Couscous Tunisien',
      description: 'Couscous traditionnel avec légumes et viande',
      price: 15.0,
      imageUrl: 'https://images.unsplash.com/photo-1623428187969-5da2dcea5ebf?w=400',
      category: 'Plats',
    ),
    Product(
      id: '2',
      name: 'Brik à l\'oeuf',
      description: 'Brik croustillant farci d\'un oeuf et de thon',
      price: 5.0,
      imageUrl: 'https://images.unsplash.com/photo-1601050690597-df0568f70950?w=400',
      category: 'Entrées',
    ),
    Product(
      id: '3',
      name: 'Tajine Tunisien',
      description: 'Tajine aux légumes et viande',
      price: 12.0,
      imageUrl: 'https://images.unsplash.com/photo-1574484284002-952d92456975?w=400',
      category: 'Plats',
    ),
    Product(
      id: '4',
      name: 'Salade Mechouia',
      description: 'Salade de poivrons grillés',
      price: 6.0,
      imageUrl: 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400',
      category: 'Entrées',
    ),
    Product(
      id: '5',
      name: 'Lablabi',
      description: 'Soupe de pois chiches épicée',
      price: 4.0,
      imageUrl: 'https://images.unsplash.com/photo-1547592166-23ac45744acd?w=400',
      category: 'Soupes',
    ),
    Product(
      id: '6',
      name: 'Makroudh',
      description: 'Pâtisserie traditionnelle aux dattes',
      price: 8.0,
      imageUrl: 'https://images.unsplash.com/photo-1587241321921-91a834d82ffc?w=400',
      category: 'Desserts',
    ),
    Product(
      id: '7',
      name: 'Chorba',
      description: 'Soupe tunisienne aux vermicelles',
      price: 5.0,
      imageUrl: 'https://images.unsplash.com/photo-1604908176997-125f25cc6f3d?w=400',
      category: 'Soupes',
    ),
    Product(
      id: '8',
      name: 'Pizza Tunisienne',
      description: 'Pizza au thon et harissa',
      price: 10.0,
      imageUrl: 'https://images.unsplash.com/photo-1513104890138-7c749659a591?w=400',
      category: 'Plats',
    ),
  ];

  List<Product> get products => _products;

  List<Product> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<Product> searchProducts(String query) {
    return _products.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) || 
      p.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
