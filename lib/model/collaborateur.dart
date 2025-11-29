import 'user.dart';

class Collaborateur extends User {
  bool? disponibilite;
  String? idTopMlewi;

  Collaborateur({
    super.id,super.nom,
    super.prenom,
    super.tel,
    super.email,
    super.password,
    super.role,
    this.disponibilite,
    this.idTopMlewi,
  });

  factory Collaborateur.fromJson(Map<String, dynamic> json) {
    return Collaborateur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      tel: json['tel'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      disponibilite: json['disponibilite'],
      // --- CORRECTION ICI ---
      // Utiliser 'TopMlewiId' pour correspondre à Firestore,
      // au lieu de 'idTopMlewi'.
      idTopMlewi: json['TopMlewiId'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'disponibilite': disponibilite,
      // On garde 'TopMlewiId' pour être cohérent à l'écriture également
      'TopMlewiId': idTopMlewi,
    });
    return data;
  }
}
