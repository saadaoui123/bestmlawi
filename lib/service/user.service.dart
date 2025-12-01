import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/user.dart';

class UserService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Nom de la collection
  final String _collection = User.collection;

  // Get all users stream
  Stream<List<User>> getAllUsers() {
    return _db
        .collection(_collection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => User.fromFirestore(doc))
            .toList());
  }
  Future<void> createOrUpdateUserData(String userId, Map<String, dynamic> data) async {
    try {
      // Utilisation de .set() pour garantir la création du document.
      // SetOptions(merge: true) est une bonne pratique : si le document existe,
      // on met à jour les champs sans écraser les autres.
      await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
      print("Données utilisateur créées/mises à jour avec succès pour l'ID: $userId");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la création/mise à jour des données utilisateur : $e");
      rethrow; // Relance l'erreur pour que l'UI puisse la gérer
    }
  }

  /// Mettre à jour des données existantes pour un utilisateur.
  /// Lève une erreur si le document n'existe pas.
  Future<void> updateUserData(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection(_collection).doc(userId).update(data);
      print("Données utilisateur mises à jour avec succès pour l'ID: $userId");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la mise à jour des données utilisateur : $e");
      rethrow; // Relance l'erreur pour que l'UI puisse la gérer
    }
  }
  /// Créer un utilisateur (Client, Collaborateur, etc.)
  Future<void> createUser(User user) async {
    try {
      final docRef = user.id != null
          ? _db.collection(_collection).doc(user.id.toString())
          : _db.collection(_collection).doc();

      await docRef.set(user.toJson());

      print("Utilisateur ajouté avec succès avec ID : ${docRef.id}");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la création de l'utilisateur : $e");
    }
  }

  /// Lire un utilisateur par ID
  Future<User?> getUserById(String id) async {
    try {
      DocumentSnapshot doc = await _db.collection(_collection).doc(id).get();
      if (doc.exists) {
        return User.fromFirestore(doc);
      }
    } catch (e) {
      print("Erreur lors de la lecture de l'utilisateur : $e");
    }
    return null;
  }

  /// Supprimer un utilisateur
  Future<void> deleteUser(String id) async {
    try {
      await _db.collection(_collection).doc(id).delete();
      print("Utilisateur supprimé avec succès");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la suppression de l'utilisateur : $e");
    }
  }

  /// Mettre à jour un utilisateur
  Future<void> updateUser(User user) async {
    try {
      if (user.id == null) {
        print("Impossible de mettre à jour un utilisateur sans ID");
        return;
      }
      await _db.collection(_collection).doc(user.id.toString()).update(user.toJson());
      print("Utilisateur mis à jour avec succès");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la mise à jour de l'utilisateur : $e");
    }
  }
  Future<void> updateUserDataa(String userId, Map<String, dynamic> data) async {
    try {
      await _db.collection(_collection).doc(userId).update(data);
      print("Données utilisateur mises à jour avec succès pour l'ID: $userId");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la mise à jour des données utilisateur : $e");
      rethrow; // Relance l'erreur pour que l'UI puisse la gérer
    }
  }

  Future<void> createUserWithUid(User user, String uid) async {
    try {
      await _db.collection(User.collection).doc(uid).set(user.toJson());
      print("Utilisateur ajouté avec succès avec UID: $uid");
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la création de l'utilisateur : $e");
    }
  }

  // Update user role
  Future<void> updateUserRole(String userId, String newRole) async {
    try {
      await _db.collection(_collection).doc(userId).update({
        'role': newRole,
      });
      notifyListeners();
    } catch (e) {
      print("Erreur lors de la mise à jour du rôle : $e");
    }
  }
}
