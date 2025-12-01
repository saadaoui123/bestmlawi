import 'package:flutter/material.dart';

/// Un fichier central pour gérer la logique des statuts de commande.

// --- 1. ÉNUMÉRATION DES STATUTS (La source de vérité absolue) ---
// Utiliser une classe avec des constantes empêche les fautes de frappe dans le code.
class OrderStatus {
  static const String pending = 'pending';
  static const String confirmed = 'confirmed';
  static const String assignedToPoint = 'assigned_to_point';
  static const String preparing = 'preparing';
  static const String readyForDelivery = 'ready_for_delivery';
  static const String assignedToDriver = 'assigned_to_driver';
  static const String delivering = 'delivering';
  static const String delivered = 'delivered';
  static const String cancelled = 'cancelled';
}

// --- 2. FONCTION DE TRADUCTION ---
String getStatusText(String status) {
  switch (status.toLowerCase()) {
    case OrderStatus.pending:
      return 'En attente';
    case OrderStatus.confirmed:
      return 'Confirmée';
    case OrderStatus.assignedToPoint:
      return 'Au point';
    case OrderStatus.preparing:
      return 'En Préparation';
    case OrderStatus.readyForDelivery:
      return 'Prête';
    case OrderStatus.assignedToDriver:
      return 'Assignée (Livreur)';
    case OrderStatus.delivering:
      return 'En livraison';
    case OrderStatus.delivered:
      return 'Livrée';
    case OrderStatus.cancelled:
      return 'Annulée';
    default:
      return status; // Affiche le statut brut s'il est inconnu
  }
}

// --- 3. FONCTION POUR LES COULEURS ---
Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case OrderStatus.pending:
      return Colors.orange;
    case OrderStatus.confirmed:
      return Colors.blue;
    case OrderStatus.assignedToPoint:
      return Colors.purple;
    case OrderStatus.preparing:
      return Colors.deepPurple;
    case OrderStatus.readyForDelivery:
      return Colors.lightGreen.shade700;
    case OrderStatus.assignedToDriver:
    case OrderStatus.delivering:
      return Colors.green;
    case OrderStatus.delivered:
      return Colors.grey[700]!;
    case OrderStatus.cancelled:
      return Colors.red;
    default:
      return Colors.black;
  }
}
