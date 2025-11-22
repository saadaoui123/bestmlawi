import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  static String collection = "user";

  String? id;
  String? nom;
  String? prenom;
  String? email;
  String? role;
  String? password;
  int? tel;


  User({this.id, this.nom, this.prenom,this.tel,this.email,this.password,this.role});

  static User fromJson(Map<String, dynamic> json) {
    return User(
        id: json['id']?.toString(), nom: json['nom'].toString(),prenom: json['prenom'].toString(), tel: json['tel'],email: json['email'].toString(),password: json['password'],role: json['role'].toString());
  }

  factory User.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return User(
      id: doc.id,
      nom: data['nom']?.toString(),
      prenom: data['prenom']?.toString(),
      tel: data['tel'],
      email: data['email']?.toString(),
      role: data['role']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nom': nom,
      'tel': tel,
      'prenom':prenom,
      'password':password,
      'email':email,
      'role':role
    };
  }
}
