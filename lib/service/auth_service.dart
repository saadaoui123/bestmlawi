import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get user role
  Future<String> getUserRole(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data()?['role'] ?? 'client';
      }
      return 'client';
    } catch (e) {
      return 'client';
    }
  }

  // Check if user is manager
  Future<bool> isManager() async {
    final user = currentUser;
    if (user == null) return false;
    
    final role = await getUserRole(user.uid);
    return role == 'gerant' || role == 'manager';
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
