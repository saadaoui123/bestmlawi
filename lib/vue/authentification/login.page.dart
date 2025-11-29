import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final fb_auth.FirebaseAuth _auth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.8),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.restaurant_menu,
                          size: 64,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Bienvenue",
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Connectez-vous pour commander",
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 32),
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: "Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) => value!.isEmpty ? "Entrez un email" : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: "Mot de passe",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          obscureText: true,
                          validator: (value) => value!.isEmpty ? "Entrez le mot de passe" : null,
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: _loading
                              ? const Center(child: CircularProgressIndicator())
                              : ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: const Text(
                              "Se connecter",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/register');
                          },
                          child: const Text("Pas encore de compte ? S'inscrire"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1. Connexion avec Firebase Auth
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final user = userCredential.user;

      if (user != null) {
        // Recharger l'utilisateur pour vérifier le statut de l'email
        await user.reload();
        if (!user.emailVerified) {
          // Si l'email n'est pas vérifié, on affiche un dialogue et on arrête
          if (mounted) {
            setState(() => _loading = false);
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text("Email non vérifié"),
                content: const Text(
                    "Veuillez consulter votre boîte mail pour confirmer votre compte. Souhaitez-vous renvoyer l'email de confirmation ?"),
                actions: [
                  TextButton(
                    child: const Text("Annuler"),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  TextButton(
                    child: const Text("Renvoyer"),
                    onPressed: () {
                      user.sendEmailVerification();
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text("E-mail de confirmation renvoyé !")));
                    },
                  ),
                ],
              ),
            );
          }
          return; // Stoppe la fonction ici
        }
      }

      // 2. Obtenir le rôle de l'utilisateur depuis Firestore
      final userDoc = await _db.collection('users').doc(user!.uid).get();

      if (mounted) {
        setState(() => _loading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Connexion réussie !")),
        );

        // 3. Vérifier le rôle et naviguer en conséquence
        if (userDoc.exists) {
          final role = userDoc.data()?['role'] ?? 'client';

          // --- DÉBUT DES MODIFICATIONS ---
          switch (role) {
            case 'manager':
            case 'gerant':
              print('Redirecting to / (manager)');
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              break;
            case 'livreur':
              print('Redirecting to /livreur_dashboard');
              Navigator.of(context).pushNamedAndRemoveUntil('/livreur_dashboard', (route) => false);
              break;
            case 'collaborateur':
            // MODIFIÉ : Redirige vers son propre dashboard
              print('Redirecting to /collaborateur_dashboard');
              Navigator.of(context).pushNamedAndRemoveUntil('/collaborateur_dashboard', (route) => false);
              break;
            case 'coordinateur':
              print('Redirecting to /coordinateur_dashboard');
              Navigator.of(context).pushNamedAndRemoveUntil('/coordinateur_dashboard', (route) => false);
              break;
            default: // client
              print('Redirecting to / (client)');
              Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          }
          // --- FIN DES MODIFICATIONS ---

        } else {
          // Si aucun document utilisateur n'est trouvé, on le traite comme un client par défaut
          print('No user document found, redirecting to /');
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        }
      }
    } on fb_auth.FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _loading = false);

        String msg = "Erreur de connexion";
        if (e.code == "user-not-found" || e.code == "wrong-password" || e.code == "invalid-credential") {
          msg = "Email ou mot de passe incorrect";
        }

        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Erreur: ${e.toString()}")));
      }
    }
  }
}
