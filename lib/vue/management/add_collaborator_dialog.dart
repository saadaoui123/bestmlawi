import 'package:flutter/material.dart';
// Importez les packages nécessaires pour Auth et Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  // Ajout du contrôleur pour le mot de passe
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose(); // Ne pas oublier de le disposer
    super.dispose();
  }

  // --- VERSION SANS CLOUD FUNCTIONS ---
  Future<void> _createCollaborator() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      // Étape 1 : Créer un compte utilisateur dans Firebase Auth
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final User? newUser = userCredential.user;

      if (newUser != null) {
        // Étape 2 : Envoyer l'email de vérification au nouveau collaborateur
        await newUser.sendEmailVerification();

        // Étape 3 : Créer le document utilisateur dans Firestore avec le rôle 'collaborateur'
        await FirebaseFirestore.instance.collection('users').doc(newUser.uid).set({
          'uid': newUser.uid,
          'email': _emailController.text.trim(),
          'firstName': _firstNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'role': 'collaborateur', // Rôle par défaut
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Collaborateur créé. Un email de confirmation a été envoyé.')),
          );
          Navigator.of(context).pop(); // Fermer le dialogue
        }
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String errorMessage = "Une erreur est survenue.";
        if (e.code == 'weak-password') {
          errorMessage = 'Le mot de passe fourni est trop faible.';
        } else if (e.code == 'email-already-in-use') {
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ajouter un collaborateur'),
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
              const SizedBox(height: 8),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Nom'),
                validator: (value) => value!.isEmpty ? 'Le nom est requis' : null,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty || !value!.contains('@') ? 'Entrez un email valide' : null,
              ),
              const SizedBox(height: 8),
              // Champ pour le mot de passe initial
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Mot de passe temporaire'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.length < 6) {
                    return 'Le mot de passe doit faire au moins 6 caractères';
                  }
                  return null;
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
            ? const CircularProgressIndicator()
            : ElevatedButton(
          onPressed: _createCollaborator,
          child: const Text('Créer'),
        ),
      ],
    );
  }
}
