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
        _message = '✅ Compte gérant créé avec succès!\\n\\n'
            'Email: gerant@bestmlawi.com\\n'
            'Mot de passe: Gerant123!\\n'
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

      setState(() {
        _loading = false;
        _message = '✅ Données de test créées!\\n\\n'
            '- 2 points TopMlawi créés';
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _message = '❌ Erreur: ${e.toString()}';
      });
    }
  }

  Future<void> _createDeliveryDriverAccounts() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;

      // Create first delivery driver account
      final driver1Credential = await auth.createUserWithEmailAndPassword(
        email: 'livreur1@bestmlawi.com',
        password: 'Livreur123!',
      );

      await firestore.collection('users').doc(driver1Credential.user!.uid).set({
        'email': 'livreur1@bestmlawi.com',
        'role': 'livreur',
        'name': 'Ahmed Ben Ali',
        'phone': '+216 20 123 456',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final driver1Id = driver1Credential.user!.uid;

      // Create second delivery driver account
      final driver2Credential = await auth.createUserWithEmailAndPassword(
        email: 'livreur2@bestmlawi.com',
        password: 'Livreur123!',
      );

      await firestore.collection('users').doc(driver2Credential.user!.uid).set({
        'email': 'livreur2@bestmlawi.com',
        'role': 'livreur',
        'name': 'Mohamed Trabelsi',
        'phone': '+216 22 234 567',
        'createdAt': FieldValue.serverTimestamp(),
      });

      final driver2Id = driver2Credential.user!.uid;

      // Also create corresponding entries in livreurs collection
      await firestore.collection('livreurs').doc(driver1Id).set({
        'name': 'Ahmed Ben Ali',
        'phone': '+216 20 123 456',
        'isAvailable': true,
        'currentLocation': const GeoPoint(36.8065, 10.1815),
        'activeOrders': 0,
      });

      await firestore.collection('livreurs').doc(driver2Id).set({
        'name': 'Mohamed Trabelsi',
        'phone': '+216 22 234 567',
        'isAvailable': true,
        'currentLocation': const GeoPoint(36.8780, 10.3250),
        'activeOrders': 0,
      });

      setState(() {
        _loading = false;
        _message = '✅ Comptes livreurs créés avec succès!\\n\\n'
            'Livreur 1:\\n'
            'Email: livreur1@bestmlawi.com\\n'
            'Mot de passe: Livreur123!\\n'
            'UID: $driver1Id\\n\\n'
            'Livreur 2:\\n'
            'Email: livreur2@bestmlawi.com\\n'
            'Mot de passe: Livreur123!\\n'
            'UID: $driver2Id';
      });

      // Sign out
      await auth.signOut();
      
      print('Utilisateur ajouté avec succès avec UID: $driver1Id');
      print('Utilisateur ajouté avec succès avec UID: $driver2Id');
    } catch (e) {
      setState(() {
        _loading = false;
        _message = '❌ Erreur: ${e.toString()}';
      });
    }
  }

  Future<void> _fixSpecificAccount() async {
    setState(() {
      _loading = true;
      _message = '';
    });

    try {
      final firestore = FirebaseFirestore.instance;
      final auth = FirebaseAuth.instance;

      // 1. Sign in as the user to get their UID
      try {
        final userCredential = await auth.signInWithEmailAndPassword(
          email: 'amine22@gmail.com',
          password: 'amine123', // Assuming this is the password based on screenshot
        );
        
        final uid = userCredential.user!.uid;
        print('DEBUG: Fixing account for UID: $uid');

        // 2. Create/Update the user document
        await firestore.collection('users').doc(uid).set({
          'email': 'amine22@gmail.com',
          'role': 'livreur',
          'name': 'Amine',
          'prenom': 'Barka',
          'phone': '5555555',
          'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        // 3. Ensure entry in livreurs collection
        await firestore.collection('livreurs').doc(uid).set({
          'name': 'Amine Barka',
          'phone': '5555555',
          'isAvailable': true,
          'currentLocation': const GeoPoint(36.8065, 10.1815),
          'activeOrders': 0,
        }, SetOptions(merge: true));

        setState(() {
          _loading = false;
          _message = '✅ Compte amine22@gmail.com réparé!\nUID: $uid';
        });

        await auth.signOut();

      } catch (e) {
        // If sign in fails, try to create it
        print('DEBUG: Sign in failed, trying to create: $e');
        
        final userCredential = await auth.createUserWithEmailAndPassword(
          email: 'amine22@gmail.com',
          password: 'amine123',
        );
        
        final uid = userCredential.user!.uid;
        
        await firestore.collection('users').doc(uid).set({
          'email': 'amine22@gmail.com',
          'role': 'livreur',
          'name': 'Amine',
          'prenom': 'Barka',
          'phone': '5555555',
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        await firestore.collection('livreurs').doc(uid).set({
          'name': 'Amine Barka',
          'phone': '5555555',
          'isAvailable': true,
          'currentLocation': const GeoPoint(36.8065, 10.1815),
          'activeOrders': 0,
        });

        setState(() {
          _loading = false;
          _message = '✅ Compte amine22@gmail.com créé et configuré!\nUID: $uid';
        });
        
        await auth.signOut();
      }

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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _createDeliveryDriverAccounts,
                        icon: const Icon(Icons.motorcycle),
                        label: const Text('Créer Comptes Livreurs'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.all(16),
                          backgroundColor: Colors.blue,
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
                    '3. Créez les comptes livreurs\n'
                    '4. Test de connexion:\n'
                    '   Gérant: gerant@bestmlawi.com / Gerant123!\n'
                    '   Livreur: livreur1@bestmlawi.com / Livreur123!',
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
