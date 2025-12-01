import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
  Future<void> updateUserAvailability(bool isAvailable) async {
    final user = currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'isAvailable': isAvailable,
      });
      //notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour de la disponibilité : $e");
      rethrow;
    }
  }
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      debugPrint("Erreur lors de l'envoi de l'email de réinitialisation : $e");
      rethrow;
    }
  }

  // Create account (for manager to create other users without logging out)
  Future<String?> createAccount(String email, String password) async {
    FirebaseApp? secondaryApp;
    try {
      // Initialize a secondary app
      secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      // Get auth instance for secondary app
      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      // Create user
      final userCredential = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );



      return userCredential.user?.uid;
    } catch (e) {
      print('Error creating account: $e');
      rethrow;
    } finally {
      // Clean up
      await secondaryApp?.delete();
    }
  }
}
