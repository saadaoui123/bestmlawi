import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/model/product.dart';

class ProductService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all products
  Stream<List<Product>> getAllProducts() {
    return _firestore
        .collection('products')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }

  // Get products by category
  Stream<List<Product>> getProductsByCategory(String category) {
    return _firestore
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Product.fromFirestore(doc))
            .toList());
  }

  // Add product
  Future<void> addProduct(Product product) async {
    await _firestore.collection('products').add(product.toMap());
    notifyListeners();
  }

  // Update product
  Future<void> updateProduct(Product product) async {
    await _firestore.collection('products').doc(product.id).update(product.toMap());
    notifyListeners();
  }

  // Delete product
  Future<void> deleteProduct(String productId) async {
    await _firestore.collection('products').doc(productId).delete();
    notifyListeners();
  }

  // Search products (client-side filtering for now as Firestore search is limited)
  Future<List<Product>> searchProducts(String query) async {
    final snapshot = await _firestore.collection('products').get();
    final products = snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    
    return products.where((p) => 
      p.name.toLowerCase().contains(query.toLowerCase()) || 
      p.description.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }
}
