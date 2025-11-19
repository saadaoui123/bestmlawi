import 'user.dart';

class Client extends User {
  double? latitude;
  double? longitude;
  Client({
    super.id,
    super.nom,
    super.prenom,
    super.tel,
    super.email,
    super.password,
    super.role,
    this.latitude,
    this.longitude,


  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      nom: json['nom'],
      prenom: json['prenom'],
      tel: json['tel'],
      email: json['email'],
      password: json['password'],
      role: json['role'],
      latitude: json['latitude'] != null ? (json['latitude'] as num).toDouble() : null,
      longitude: json['longitude'] != null ? (json['longitude'] as num).toDouble() : null,
    );
  }
  @override
  Map<String, dynamic> toJson() {
    final data = super.toJson();
    data.addAll({
      'latitude': latitude,
      'longitude': longitude,
    });
    return data;
  }
}
