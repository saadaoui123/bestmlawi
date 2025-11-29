import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/model/collaborateur.dart';

class CoordinateurService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Récupère les commandes pertinentes (assignées ou en préparation) pour un TopMlawi.
  Stream<List<Commande>> getCommandesForTopMlawi(String topMlawiId) {
    return _firestore
        .collection('orders')
    // Filtre 1 : Commandes pour ce point de vente
        .where('topMlawiId', isEqualTo: topMlawiId)
    // CORRECTION : Filtre 2 : Uniquement les statuts que le coordinateur doit gérer
        .where('status', whereIn: ['assigned_to_point', 'preparing'])
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) {
        return [];
      }
      var commandes = snapshot.docs.map((doc) => Commande.fromFirestore(doc)).toList();
      // Tri pour voir les plus récentes en premier
      commandes.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return commandes;
    });
  }

  /// NOUVELLE MÉTHODE : Change l'état d'une commande à "en cours de préparation".
  Future<void> marquerCommandeEnPreparation(String commandeId) async {
    try {
      await _firestore.collection('orders').doc(commandeId).update({
        'status': 'preparing',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour vers 'preparing': $e");
    }
  }

  /// Change l'état d'une commande à "prête pour la livraison".
  /// J'ai renommé la méthode pour plus de clarté.
  Future<void> marquerCommandePretePourLivraison(String commandeId) async {
    try {
      await _firestore.collection('orders').doc(commandeId).update({
        'status': 'ready_for_delivery',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de la mise à jour vers 'ready_for_delivery': $e");
    }
  }

  /// Annule une commande.
  Future<void> annulerCommande(String commandeId) async {
    try {
      await _firestore.collection('orders').doc(commandeId).update({
        'status': 'cancelled',
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur lors de l'annulation de la commande : $e");
    }
  }

  // Le reste du service reste inchangé...
  Stream<List<Collaborateur>> getCollaborateursForTopMlawi(String topMlawiId) {
    // ...
    return const Stream.empty(); // Placeholder
  }
  Future<void> updateDisponibiliteCollaborateur(String collaborateurId, bool isDisponible) async {
    // ...
  }
}
