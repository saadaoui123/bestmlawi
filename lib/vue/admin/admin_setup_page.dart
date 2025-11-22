import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminSetupPage extends StatefulWidget {
  const AdminSetupPage({super.key});

  @override
  State<AdminSetupPage> createState() => _AdminSetupPageState();
}

class _AdminSetupPageState extends State<AdminSetupPage> {
  bool _loading = false;
  String _message = '';

  Future<void> _createManagerAccount() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      // 1. Create manager account in Firebase Auth
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: 'gerant@bestmlawi.com',
        password: 'Gerant123!',
      );

      // 2. Add user document with manager role
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set({
        'email': 'gerant@bestmlawi.com',
        'role': 'gerant',
        'name': 'Gérant Principal',
        'phone': '+216 XX XXX XXX',
        'createdAt': FieldValue.serverTimestamp(),
      });

      setState(() {
        _loading = false;
        _message = '✅ Compte gérant créé avec succès!\n\n'
            'Email: gerant@bestmlawi.com\n'
            'Mot de passe: Gerant123!\n'
            'UID: ${userCredential.user!.uid}';
      });

      // Sign out the manager account
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      setState(() {
        _loading = false;
        _message = '❌ Erreur: ${e.toString()}';
      });
    }
  }

  Future<void> _createTestData() async {
    setState(() {
      _loading = true;
      _message = 'Création des données de test...';
    });

    try {
      final firestore = FirebaseFirestore.instance;

      // Create TopMlawi points
      await firestore.collection('topmlawi').add({
        'name': 'TopMlawi Centre Ville',
        'location': const GeoPoint(36.8065, 10.1815),
        'address': 'Avenue Habib Bourguiba, Tunis',
        'isAvailable': true,
        'currentCapacity': 0,
        'maxCapacity': 20,
      });

      await firestore.collection('topmlawi').add({
        'name': 'TopMlawi La Marsa',
        'location': const GeoPoint(36.8780, 10.3250),
        'address': 'Zone Touristique, La Marsa',
        'isAvailable': true,
        'currentCapacity': 0,
        'maxCapacity': 15,
      });

      // Create delivery drivers
      await firestore.collection('livreurs').add({
        'name': 'Ahmed Ben Ali',
        'phone': '+216 20 123 456',
        'isAvailable': true,
        'currentLocation': const GeoPoint(36.8065, 10.1815),
        'activeOrders': 0,
      });

      await firestore.collection('livreurs').add({
        'name': 'Mohamed Trabelsi',
        'phone': '+216 22 234 567',
        'isAvailable': true,
        'currentLocation': const GeoPoint(36.8780, 10.3250),
        'activeOrders': 0,
      });

      setState(() {
        _loading = false;
        _message = '✅ Données de test créées!\n\n'
            '- 2 points TopMlawi\n'
            '- 2 livreurs disponibles';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _message = '❌ Erreur: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Admin'),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.admin_panel_settings, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuration Initiale',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Créez un compte gérant et des données de test',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 32),
                  if (_loading)
                    const CircularProgressIndicator()
                  else ...[
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createManagerAccount,
                        icon: const Icon(Icons.person_add),
                        label: const Text('Créer Compte Gérant'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createTestData,
                        icon: const Icon(Icons.data_object),
                        label: const Text('Créer Données de Test'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                  if (_message.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _message.startsWith('✅') 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _message.startsWith('✅') 
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                      child: Text(
                        _message,
                        style: TextStyle(
                          color: _message.startsWith('✅') 
                              ? Colors.green[900]
                              : Colors.red[900],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),
                  const Text(
                    'Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Créez d\'abord le compte gérant\n'
                    '2. Créez ensuite les données de test\n'
                    '3. Connectez-vous avec:\n'
                    '   Email: gerant@bestmlawi.com\n'
                    '   Mot de passe: Gerant123!',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
