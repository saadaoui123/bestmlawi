import 'user.dart';

class Collaborateur extends User {
  String? disponibilite;
  int? idTopMlewi;

  Collaborateur({
    super.id,
    super.nom,
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
      idTopMlewi: json['idTopMlewi'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'disponibilite': disponibilite,
      'idTopMlewi': idTopMlewi,
    });
    return data;
  }
}
