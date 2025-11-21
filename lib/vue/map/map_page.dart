import 'package:flutter/material.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Carte de Livraison'),
          automaticallyImplyLeading: false, // Hide back button as it's part of the main shell
        ),
        const Expanded(
          child: Center(
            child: Text('Contenu de la page Carte'),
          ),
        ),
      ],
    );
  }
}
