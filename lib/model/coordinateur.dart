import 'collaborateur.dart';

class Coordinateur extends Collaborateur {
  Coordinateur({
    super.id,
    super.nom,
    super.prenom,
    super.tel,
    super.email,
    super.password,
    super.role,
    super.disponibilite,
    super.idTopMlewi,
  });
  factory Coordinateur.fromJson(Map<String, dynamic> json) {
    return Coordinateur(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      tel: json['tel'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      disponibilite: json['disponibilite'],
      idTopMlewi: json['topMlawiId'],
    );
  }
  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    return data;
  }
}
