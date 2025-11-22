import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/settings_service.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settings, child) {
        if (settings.isLoading) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Paramètres'),
              centerTitle: true,
            ),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Paramètres'),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Notifications',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SwitchListTile(
            title: const Text('Notifications push'),
            subtitle: const Text('Recevoir des notifications sur votre appareil'),
            value: settings.notifications,
            activeColor: Colors.orange,
            onChanged: settings.updateNotifications,
          ),
          SwitchListTile(
            title: const Text('Notifications par email'),
            subtitle: const Text('Recevoir des offres par email'),
            value: settings.emailNotifications,
            activeColor: Colors.orange,
            onChanged: settings.updateEmailNotifications,
          ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Apparence',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          SwitchListTile(
            title: const Text('Mode sombre'),
            subtitle: const Text('Activer le thème sombre'),
            value: settings.darkMode,
            activeColor: Colors.orange,
            onChanged: settings.updateDarkMode,
          ),
          ListTile(
            title: const Text('Langue'),
            subtitle: Text(settings.language),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Choisir la langue'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<String>(
                        title: const Text('Français'),
                        value: 'Français',
                        groupValue: settings.language,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          settings.updateLanguage(value!);
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('العربية'),
                        value: 'العربية',
                        groupValue: settings.language,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          settings.updateLanguage(value!);
                          Navigator.pop(context);
                        },
                      ),
                      RadioListTile<String>(
                        title: const Text('English'),
                        value: 'English',
                        groupValue: settings.language,
                        activeColor: Colors.orange,
                        onChanged: (value) {
                          settings.updateLanguage(value!);
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const Divider(height: 32),
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'À propos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Version de l\'application'),
            subtitle: const Text('1.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('Conditions d\'utilisation'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Conditions d\'utilisation'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'En utilisant BestMlawi, vous acceptez nos conditions d\'utilisation.\n\n'
                      '1. Utilisation du service\n'
                      'Vous devez avoir au moins 18 ans pour utiliser ce service.\n\n'
                      '2. Commandes\n'
                      'Toutes les commandes sont soumises à disponibilité.\n\n'
                      '3. Paiement\n'
                      'Le paiement s\'effectue à la livraison.\n\n'
                      '4. Livraison\n'
                      'Les délais de livraison sont estimatifs.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('Politique de confidentialité'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Politique de confidentialité'),
                  content: const SingleChildScrollView(
                    child: Text(
                      'Nous respectons votre vie privée.\n\n'
                      '1. Collecte de données\n'
                      'Nous collectons uniquement les informations nécessaires pour traiter vos commandes.\n\n'
                      '2. Utilisation des données\n'
                      'Vos données sont utilisées uniquement pour améliorer votre expérience.\n\n'
                      '3. Partage des données\n'
                      'Nous ne partageons jamais vos données avec des tiers.\n\n'
                      '4. Sécurité\n'
                      'Vos données sont stockées de manière sécurisée sur Firebase.',
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Fermer'),
                    ),
                  ],
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.contact_support_outlined),
            title: const Text('Nous contacter'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.of(context).pushNamed('/profile/help'),
          ),
          const SizedBox(height: 16),
          ],
        ),
      );
      },
    );
  }
}
