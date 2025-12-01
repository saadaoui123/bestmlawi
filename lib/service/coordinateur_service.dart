import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:projet_best_mlewi/model/commande.dart';
import 'package:projet_best_mlewi/utils/status_utils.dart'; // IMPORTANT : Importer

class CoordinateurService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CORRIGÉ: Utilise les statuts standards
  Stream<List<Commande>> getCommandesForTopMlawi(String topMlawiId) {
    return _firestore
        .collection('orders')
        .where('topMlawiId', isEqualTo: topMlawiId)
        .where('status', whereIn: [OrderStatus.assignedToPoint, OrderStatus.preparing])
        .snapshots()
        .map((snapshot) {
      var commandes = snapshot.docs.map((doc) => Commande.fromFirestore(doc)).toList();
      commandes.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return commandes;
    });
  }

  Future<void> marquerCommandeEnPreparation(String commandeId) async {
    try {
      await _firestore.collection('orders').doc(commandeId).update({
        'status': OrderStatus.preparing,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur: $e");
    }
  }

  Future<void> marquerCommandePretePourLivraison(String commandeId) async {
    try {
      await _firestore.collection('orders').doc(commandeId).update({
        'status': OrderStatus.readyForDelivery,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur: $e");
    }
  }

  Future<void> annulerCommande(String commandeId) async {
    try {
      await _firestore.collection('orders').doc(commandeId).update({
        'status': OrderStatus.cancelled,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      notifyListeners();
    } catch (e) {
      debugPrint("Erreur: $e");
    }
  }
}
