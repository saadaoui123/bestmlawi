// lib/vue/management/add_collaborator_dialog.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/model/top_mlawi.dart';
import 'package:projet_best_mlewi/service/top_mlawi_service.dart';
import 'package:provider/provider.dart';

// AJOUTS NÉCESSAIRES
import 'package:projet_best_mlewi/service/auth_service.dart';
import 'package:projet_best_mlewi/service/user.service.dart';
import 'package:firebase_core/firebase_core.dart';

class AddCollaboratorDialog extends StatefulWidget {
  const AddCollaboratorDialog({super.key});

  @override
  State<AddCollaboratorDialog> createState() => _AddCollaboratorDialogState();
}

class _AddCollaboratorDialogState extends State<AddCollaboratorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();

  String? _selectedTopMlawiId;
  bool _isLoading = false;
  bool _hasTopMlawiPoints = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _createCollaborator() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final userService = Provider.of<UserService>(context, listen: false);
    final email = _emailController.text.trim();

    const String secondaryAppName = 'userCreationApp';
    FirebaseApp? secondaryApp;

    try {
      secondaryApp = await Firebase.initializeApp(
        name: secondaryAppName,
        options: Firebase.app().options,
      );

      final String randomPassword = FirebaseFirestore.instance.collection('temp').doc().id;

      final UserCredential userCredential = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: email,
        password: randomPassword,
      );

      final User? newUser = userCredential.user;

      if (newUser != null) {
        // Délai pour assurer la synchronisation avec le backend Firebase
        await Future.delayed(const Duration(seconds: 1));

        // --- DÉBUT DE LA CORRECTION ---
        // On appelle la nouvelle méthode qui utilise .set() pour CRÉER le document.
        await userService.createOrUpdateUserData(newUser.uid, {
          // --- FIN DE LA CORRECTION ---
          'uid': newUser.uid,
          'email': email,
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'role': 'collaborateur',
          'createdAt': FieldValue.serverTimestamp(),
          'topMlawiId': _selectedTopMlawiId,
          'isAvailable': false,
          'activeOrders': 0,
        });

        await authService.sendPasswordResetEmail(email);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Collaborateur invité. Un email a été envoyé.")),
          );
          Navigator.of(context).pop();
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = "Une erreur est survenue.";
        if (e.code == 'email-already-in-use') {
          errorMessage = 'Un compte existe déjà pour cet email.';
        } else if (e.code == 'invalid-email') {
          errorMessage = "L'adresse email n'est pas valide.";
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $errorMessage')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Une erreur inattendue est survenue: $e')),
        );
      }
    } finally {
      if (secondaryApp != null) {
        await secondaryApp.delete();
      }
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final topMlawiService = Provider.of<TopMlawiService>(context, listen: false);

    return AlertDialog(
      title: const Text('Inviter un collaborateur'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'Prénom'),
                validator: (value) => value!.isEmpty ? 'Le prénom est requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Le nom est requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value.contains('@') ? 'Entrez un email valide' : null,
              ),
              const SizedBox(height: 20),
              StreamBuilder<List<TopMlawi>>(
                stream: topMlawiService.getAllTopMlawi(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    ));
                  }
                  final hasData = snapshot.hasData && snapshot.data!.isNotEmpty;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _hasTopMlawiPoints != hasData) {
                      setState(() {
                        _hasTopMlawiPoints = hasData;
                      });
                    }
                  });
                  if (!hasData) {
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        "Aucun point de vente n'a été créé. Veuillez en ajouter un avant de créer un collaborateur.",
                        style: TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  final topMlawiPoints = snapshot.data!;
                  return DropdownButtonFormField<String>(
                    value: _selectedTopMlawiId,
                    hint: const Text('Sélectionner un point de vente'),
                    decoration: const InputDecoration(
                      labelText: 'Point de Vente',
                      border: OutlineInputBorder(),
                    ),
                    items: topMlawiPoints.map((point) {
                      return DropdownMenuItem<String>(
                        value: point.id,
                        child: Text(point.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedTopMlawiId = value;
                      });
                    },
                    validator: (value) => value == null ? 'Veuillez sélectionner un point de vente' : null,
                  );
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        _isLoading
            ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
            : ElevatedButton(
          onPressed: _hasTopMlawiPoints ? _createCollaborator : null,
          child: const Text('Inviter'),
        ),
      ],
    );
  }
}
