import 'package:cloud_firestore/cloud_firestore.dart';

class Commande {
  String? id;
  String? clientId;
  double? total;
  DateTime? date;
  String? status;
  int? tempspreparation;
  String? livreurid;


  Commande({
    this.id,
    this.clientId,
    this.total,
    this.date,
    this.status,
  });

  factory Commande.fromJson(Map<String, dynamic> json, String id) {
    return Commande(
      id: id,
      clientId: json['clientId'],
      total: (json['total'] as num).toDouble(),
      date: (json['date'] as Timestamp).toDate(),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'clientId': clientId,
      'total': total,
      'date': date != null ? Timestamp.fromDate(date!) : null,
      'status': status,
    };
  }
}
