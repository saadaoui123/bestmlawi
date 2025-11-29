import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/model/livreur.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';

class LivreurService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // La collection principale pour tous les utilisateurs, y compris les livreurs.
  final String _collectionPath = 'users';

  // Récupère tous les livreurs disponibles
  Stream<List<Livreur>> getAvailableLivreurs() {
    return _firestore
        .collection(_collectionPath)
        .where('role', isEqualTo: 'livreur') // Filtrer par rôle
        .where('disponibilite', isEqualTo: true) // Utiliser le nouveau champ
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Livreur.fromFirestore(doc))
        .where((livreur) => livreur.canTakeOrder)
        .toList());
  }

  // Récupère tous les livreurs
  Stream<List<Livreur>> getAllLivreurs() {
    return _firestore
        .collection(_collectionPath)
        .where('role', isEqualTo: 'livreur')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Livreur.fromFirestore(doc))
        .toList());
  }

  // Récupère un livreur par son ID
  Future<Livreur?> getLivreurById(String id) async {
    try {
      final doc = await _firestore.collection(_collectionPath).doc(id).get();
      if (doc.exists) {
        return Livreur.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching livreur: $e');
      return null;
    }
  }

  // Assigne une commande à un livreur
  Future<void> assignOrderToLivreur(String orderId, String livreurId, NotificationService notificationService) async {
    final batch = _firestore.batch();

    // Met à jour la commande
    batch.update(
      _firestore.collection('orders').doc(orderId),
      {
        'livreurId': livreurId,
        'assignedToLivreurAt': FieldValue.serverTimestamp(),
        'status': 'assigned_to_driver',
      },
    );

    // Incrémente les commandes actives du livreur dans la collection 'users'
    batch.update(
      _firestore.collection(_collectionPath).doc(livreurId),
      {'activeOrders': FieldValue.increment(1)},
    );

    await batch.commit();

    // Envoie la notification
    await notificationService.sendNotification(
      userId: livreurId,
      title: 'Nouvelle commande',
      body: 'Une nouvelle commande vous a été assignée',
      type: 'order_assigned',
      relatedId: orderId,
    );

    notifyListeners();
  }

  // Met à jour le statut de disponibilité d'un livreur
  Future<void> updateLivreurStatus(String livreurId, bool isAvailable) async {
    await _firestore.collection(_collectionPath).doc(livreurId).update({
      'disponibilite': isAvailable, // Utiliser le nouveau champ
    });
    notifyListeners();
  }

  // Crée un nouveau livreur (déprécié si la création se fait via AuthService/UserService)
  Future<void> createLivreur(Livreur livreur) async {
    // La création devrait passer par UserService pour créer User et Auth en même temps
    await _firestore.collection(_collectionPath).add(livreur.toJson());
    notifyListeners();
  }

  // Crée un nouveau livreur avec un ID spécifique
  Future<void> createLivreurWithId(Livreur livreur, String id) async {
    // Utilise la collection 'users' et la méthode toJson
    await _firestore.collection(_collectionPath).doc(id).set(livreur.toJson());
    notifyListeners();
  }

  // Met à jour un livreur
  Future<void> updateLivreur(Livreur livreur) async {
    // Utilise la collection 'users' et la méthode toJson
    await _firestore.collection(_collectionPath).doc(livreur.id).update(livreur.toJson());
    notifyListeners();
  }

  // Supprime un livreur
  Future<void> deleteLivreur(String livreurId) async {
    // La suppression d'un livreur devrait aussi supprimer son compte d'authentification.
    // Cette logique est souvent placée dans un UserService.
    await _firestore.collection(_collectionPath).doc(livreurId).delete();
    notifyListeners();
  }
}
