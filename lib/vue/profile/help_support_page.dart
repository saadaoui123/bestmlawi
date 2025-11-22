import 'package:flutter/material.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aide & Support'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.phone, color: Theme.of(context).primaryColor),
                      const SizedBox(width: 12),
                      const Text(
                        'Contactez-nous',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildContactItem(Icons.phone_outlined, 'Téléphone', '+216 XX XXX XXX'),
                  _buildContactItem(Icons.email_outlined, 'Email', 'support@bestmlawi.tn'),
                  _buildContactItem(Icons.access_time, 'Horaires', '10h - 23h, 7j/7'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Questions fréquentes',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          _buildFAQItem(
            context,
            'Comment passer une commande?',
            'Parcourez notre menu, ajoutez des articles à votre panier, puis cliquez sur "Commander" pour finaliser votre commande.',
          ),
          _buildFAQItem(
            context,
            'Quels sont les modes de paiement acceptés?',
            'Nous acceptons le paiement en espèces à la livraison et par carte bancaire.',
          ),
          _buildFAQItem(
            context,
            'Quel est le délai de livraison?',
            'La livraison prend généralement entre 30 et 45 minutes selon votre localisation.',
          ),
          _buildFAQItem(
            context,
            'Puis-je annuler ma commande?',
            'Vous pouvez annuler votre commande dans les 5 minutes suivant sa validation.',
          ),
          _buildFAQItem(
            context,
            'Comment suivre ma commande?',
            'Vous pouvez suivre votre commande en temps réel dans la section "Mes Commandes".',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAQItem(BuildContext context, String question, String answer) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        title: Text(
          question,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              answer,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }
}
