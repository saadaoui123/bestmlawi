import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final double price;
  final String image;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    this.quantity = 1,
  });

  Map<String, dynamic> toProductMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
    };
  }
}

class CartService extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addItem(Map<String, dynamic> product) {
    final String name = product['name'] ?? 'Plat inconnu';
    final double price = (product['price'] ?? 0.0).toDouble();
    final String image = product['image'] ?? '';

    final existingItem = _items.firstWhere(
      (item) => item.name == name,
      orElse: () => CartItem(
        name: name,
        price: price,
        image: image,
      ),
    );

    if (_items.contains(existingItem)) {
      existingItem.quantity++;
    } else {
      _items.add(existingItem);
    }
    notifyListeners();
  }

  void removeItem(CartItem item) {
    if (item.quantity > 1) {
      item.quantity--;
    } else {
      _items.remove(item);
    }
    notifyListeners();
  }

  void clearSpecificItem(CartItem item) {
    _items.removeWhere((cartItem) => cartItem.name == item.name);
    notifyListeners();
  }

  double get totalPrice {
    return _items.fold(0.0, (total, current) => total + (current.price * current.quantity));
  }

  int get totalItems {
    return _items.fold(0, (total, current) => total + current.quantity);
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
