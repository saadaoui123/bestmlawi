import 'package:flutter/material.dart';

class BlogPost {
  final String id;
  final String title;
  final String subtitle;
  final String content;
  final String image;
  final DateTime date;
  final Color color;
  final IconData icon;

  BlogPost({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.content,
    required this.image,
    required this.date,
    required this.color,
    required this.icon,
  });
}

class BlogService extends ChangeNotifier {
  final List<BlogPost> _posts = [
    BlogPost(
      id: '1',
      title: 'Nouvelle Sauce Piquante!',
      subtitle: 'Découvrez notre harissa maison.',
      content: 'Nous sommes fiers de vous présenter notre nouvelle sauce harissa maison, préparée avec des piments frais et des épices traditionnelles. Parfaite pour relever vos mlawis ! Venez la goûter dès aujourd\'hui.',
      image: 'assets/images/harissa.png', // Placeholder
      date: DateTime.now().subtract(const Duration(days: 2)),
      color: Colors.red,
      icon: Icons.local_fire_department,
    ),
    BlogPost(
      id: '2',
      title: 'Livraison Gratuite',
      subtitle: 'Pour toute commande > 30 DT.',
      content: 'Profitez de la livraison gratuite pour toute commande supérieure à 30 DT. Offre valable sur toute la zone de Tunis. Commandez maintenant et faites-vous livrer vos plats préférés sans frais supplémentaires.',
      image: 'assets/images/delivery.png', // Placeholder
      date: DateTime.now().subtract(const Duration(days: 5)),
      color: Colors.green,
      icon: Icons.delivery_dining,
    ),
    BlogPost(
      id: '3',
      title: 'Spécial Ramadan',
      subtitle: 'Menu Iftar disponible bientôt.',
      content: 'Le mois saint approche ! Restez à l\'écoute pour découvrir notre menu spécial Iftar, conçu pour vous offrir une rupture du jeûne gourmande et conviviale. Chorba, Brik, et bien plus encore !',
      image: 'assets/images/ramadan.png', // Placeholder
      date: DateTime.now().subtract(const Duration(days: 10)),
      color: Colors.indigo,
      icon: Icons.nights_stay,
    ),
  ];

  List<BlogPost> get posts => _posts;

  BlogPost getPostById(String id) {
    return _posts.firstWhere((p) => p.id == id);
  }
}
