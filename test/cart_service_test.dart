import 'package:flutter_test/flutter_test.dart';
import 'package:projet_best_mlewi/service/cart_service.dart';

void main() {
  group('CartService Tests', () {
    late CartService cartService;

    setUp(() {
      cartService = CartService();
    });

    test('Initial cart should be empty', () {
      expect(cartService.items.length, 0);
      expect(cartService.totalItems, 0);
      expect(cartService.totalPrice, 0.0);
    });

    test('Add item should increase count and price', () {
      final product = {
        'name': 'Mlawi',
        'price': 5.0,
        'image': 'mlawi.png',
      };

      cartService.addItem(product);

      expect(cartService.items.length, 1);
      expect(cartService.totalItems, 1);
      expect(cartService.totalPrice, 5.0);
      expect(cartService.items.first.name, 'Mlawi');
    });

    test('Add same item twice should increase quantity', () {
      final product = {
        'name': 'Mlawi',
        'price': 5.0,
        'image': 'mlawi.png',
      };

      cartService.addItem(product);
      cartService.addItem(product);

      expect(cartService.items.length, 1); // Still 1 item type
      expect(cartService.totalItems, 2); // 2 total items
      expect(cartService.totalPrice, 10.0);
      expect(cartService.items.first.quantity, 2);
    });

    test('Remove item should decrease quantity or remove item', () {
      final product = {
        'name': 'Mlawi',
        'price': 5.0,
        'image': 'mlawi.png',
      };

      cartService.addItem(product);
      cartService.addItem(product); // Quantity 2

      final item = cartService.items.first;
      cartService.removeItem(item);

      expect(cartService.totalItems, 1);
      expect(cartService.items.length, 1);

      cartService.removeItem(item); // Quantity 0, should remove

      expect(cartService.totalItems, 0);
      expect(cartService.items.length, 0);
    });

    test('Clear specific item should remove it completely', () {
      final product = {
        'name': 'Mlawi',
        'price': 5.0,
        'image': 'mlawi.png',
      };

      cartService.addItem(product);
      cartService.addItem(product);

      final item = cartService.items.first;
      cartService.clearSpecificItem(item);

      expect(cartService.items.length, 0);
    });

    test('Clear cart should remove all items', () {
      final product1 = {
        'name': 'Mlawi',
        'price': 5.0,
        'image': 'mlawi.png',
      };
      final product2 = {
        'name': 'Chapatte',
        'price': 4.0,
        'image': 'chapatte.png',
      };

      cartService.addItem(product1);
      cartService.addItem(product2);

      expect(cartService.items.length, 2);

      cartService.clearCart();

      expect(cartService.items.length, 0);
      expect(cartService.totalPrice, 0.0);
    });
  });
}
