import 'package:flutter/material.dart';

class ManagementPage extends StatelessWidget {
  const ManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text('Gestion'),
          automaticallyImplyLeading: false, // Hide back button as it's part of the main shell
        ),
        const Expanded(
          child: Center(
            child: Text('Contenu de la page Gestion'),
          ),
        ),
      ],
    );
  }
}
