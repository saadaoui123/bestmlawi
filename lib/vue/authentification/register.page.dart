import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/user.dart' as MyUser;
import '../../service/user.service.dart'; // contient createUser()

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController telController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool loading = false;

  Future<void> registerClient() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      setState(() => loading = true);

      // 1️⃣ Création compte Auth Firebase
      UserCredential cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
          );

      final String uid = cred.user!.uid; // id user firebase

      // 2️⃣ Création user Firestore adapté à ton modèle
      MyUser.User user = MyUser.User(
        id: null, // tu stockes l'ID Firestore auto ou uid si tu veux
        nom: nomController.text.trim(),
        prenom: prenomController.text.trim(),
        tel: int.tryParse(telController.text.trim()),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        role: "client", // DEFAULT
      );
      final UserService userService = UserService();

      await userService.createUser(user);

      // 3️⃣ Succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Compte créé avec succès !")),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Erreur : $e")));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppBar(
          title: const Text("Créer un compte Client"),
          automaticallyImplyLeading:
              false, // Hide back button as it's part of the main shell
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: ListView(
                children: [
                  TextFormField(
                    controller: nomController,
                    decoration: const InputDecoration(labelText: "Nom"),
                    validator: (v) => v!.isEmpty ? "Nom obligatoire" : null,
                  ),
                  TextFormField(
                    controller: prenomController,
                    decoration: const InputDecoration(labelText: "Prénom"),
                    validator: (v) => v!.isEmpty ? "Prénom obligatoire" : null,
                  ),
                  TextFormField(
                    controller: telController,
                    decoration: const InputDecoration(labelText: "Téléphone"),
                    keyboardType: TextInputType.number,
                    validator: (v) =>
                        v!.isEmpty ? "Téléphone obligatoire" : null,
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: "Email"),
                    validator: (v) =>
                        v!.contains("@") ? null : "Email invalide",
                  ),
                  TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(
                      labelText: "Mot de passe",
                    ),
                    obscureText: true,
                    validator: (v) => v!.length < 6 ? "Min 6 caractères" : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loading ? null : registerClient,
                    child: loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Créer un compte"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
