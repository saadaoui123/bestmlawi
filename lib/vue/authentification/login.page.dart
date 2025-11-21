import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../model/user.dart';

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
    return Column(
      children: [
        AppBar(
          title: const Text("Connexion Client"),
          automaticallyImplyLeading: false, // Hide back button as it's part of the main shell
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (value) => value!.isEmpty ? "Entrez un email" : null,
                  ),
                  TextFormField(
                    controller: _passwordController,
                    decoration: const InputDecoration(labelText: "Mot de passe"),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? "Entrez le mot de passe" : null,
                  ),
                  const SizedBox(height: 20),
                  _loading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: _login,
                          child: const Text("Se connecter"),
                        ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    try {
      // 1️⃣ Connexion Auth
      final fb_auth.UserCredential cred =
          await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final String uid = cred.user!.uid;

      // 2️⃣ Récupérer utilisateur Firestore
      DocumentSnapshot doc =
          await _db.collection(User.collection).doc(uid).get();

      if (!doc.exists) {
        throw Exception("Aucun utilisateur trouvé dans Firestore");
      }

      final data = doc.data() as Map<String, dynamic>;

      // 3️⃣ Vérifier rôle
      if (data["role"] != "client") {
        // Déconnexion immédiate si ce n’est pas un client
        await _auth.signOut();
        throw Exception("Ce compte n'est pas autorisé (pas un client)");
      }

      setState(() => _loading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Connexion réussie !")),
      );

      // 4️⃣ Redirection vers page client
      Navigator.pushReplacementNamed(context, "/client/home");
    } on fb_auth.FirebaseAuthException catch (e) {
      setState(() => _loading = false);

      String msg = "Erreur de connexion";
      if (e.code == "user-not-found") msg = "Email incorrect";
      if (e.code == "wrong-password") msg = "Mot de passe incorrect";

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(msg)));
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }
}
