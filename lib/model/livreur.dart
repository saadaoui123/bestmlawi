import 'package:cloud_firestore/cloud_firestore.dart';
import 'collaborateur.dart'; // Importer le modèle parent

class Livreur extends Collaborateur {
  final GeoPoint? currentLocation;
  final int activeOrders;
  final String? photoUrl;

  Livreur({
    required String id,
    String? nom,
    String? prenom,
    int? tel,
    String? email,
    bool? disponibilite,
    String? idTopMlewi,
    // Propriétés spécifiques à Livreur
    this.currentLocation,
    required this.activeOrders,
    this.photoUrl,
  }) : super(
    id: id,
    nom: nom,
    prenom: prenom,
    tel: tel,
    email: email,
    role: 'livreur', // Le rôle est fixé à 'livreur'
    disponibilite: disponibilite,
    idTopMlewi: idTopMlewi,
  );

  factory Livreur.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Livreur(
      id: doc.id,
      nom: data['nom'],
      prenom: data['prenom'],
      tel: data['tel'],
      email: data['email'],
      disponibilite: data['disponibilite'],
      idTopMlewi: data['idTopMlewi'],
      currentLocation: data['currentLocation'],
      activeOrders: data['activeOrders'] ?? 0,
      photoUrl: data['photoUrl'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'currentLocation': currentLocation,
      'activeOrders': activeOrders,
      'photoUrl': photoUrl,
    });
    return data;
  }

  bool get canTakeOrder => (disponibilite ?? false) && activeOrders < 3;

  get isAvailable => null;
}
