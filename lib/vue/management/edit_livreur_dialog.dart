import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/model/livreur.dart';
import 'package:projet_best_mlewi/model/user.dart';
import 'package:projet_best_mlewi/service/user.service.dart';
import 'package:projet_best_mlewi/service/livreur_service.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditLivreurDialog extends StatefulWidget {
  final Livreur? livreur;

  const EditLivreurDialog({super.key, this.livreur});

  @override
  State<EditLivreurDialog> createState() => _EditLivreurDialogState();
}

class _EditLivreurDialogState extends State<EditLivreurDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _prenomController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _phoneController;
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    // Split name if editing existing livreur (rough approximation)
    String nom = '';
    String prenom = '';
    if (widget.livreur != null) {
      final parts = widget.livreur!.name.split(' ');
      if (parts.isNotEmpty) nom = parts[0];
      if (parts.length > 1) prenom = parts.sublist(1).join(' ');
    }

    _nomController = TextEditingController(text: nom);
    _prenomController = TextEditingController(text: prenom);
    _emailController = TextEditingController(text: ''); // Email not in Livreur model
    _passwordController = TextEditingController(text: '');
    _phoneController = TextEditingController(text: widget.livreur?.phone ?? '');
    _isAvailable = widget.livreur?.isAvailable ?? true;
  }

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context, listen: false);
    final livreurService = Provider.of<LivreurService>(context, listen: false);

    return AlertDialog(
      title: Text(widget.livreur == null ? 'Ajouter un livreur' : 'Modifier le livreur'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nomController,
                      decoration: const InputDecoration(labelText: 'Nom'),
                      validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _prenomController,
                      decoration: const InputDecoration(labelText: 'Prénom'),
                      validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                    ),
                  ),
                ],
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (widget.livreur != null && (value == null || value.isEmpty)) return null; // Optional on edit if not changing
                  if (value == null || value.isEmpty) return 'Requis';
                  if (!value.contains('@')) return 'Email invalide';
                  return null;
                },
              ),
              if (widget.livreur == null) // Only show password for new users
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Mot de passe'),
                  obscureText: true,
                  validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
                ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Téléphone'),
                keyboardType: TextInputType.phone,
                validator: (value) => value == null || value.isEmpty ? 'Requis' : null,
              ),
              if (widget.livreur != null)
                SwitchListTile(
                  title: const Text('Disponible'),
                  value: _isAvailable,
                  onChanged: (value) {
                    setState(() {
                      _isAvailable = value;
                    });
                  },
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              try {
                String id;
                
                if (widget.livreur == null) {
                  // Create new Auth account
                  final authService = Provider.of<AuthService>(context, listen: false);
                  final uid = await authService.createAccount(
                    _emailController.text,
                    _passwordController.text,
                  );
                  
                  if (uid == null) throw Exception("Failed to create auth account");
                  id = uid;
                } else {
                  // Use existing ID
                  id = widget.livreur!.id;
                }

                // Create/Update User
                final user = User(
                  id: id,
                  nom: _nomController.text,
                  prenom: _prenomController.text,
                  email: _emailController.text,
                  password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
                  tel: int.tryParse(_phoneController.text) ?? 0,
                  role: 'livreur',
                );

                if (widget.livreur == null) {
                  // Create new User doc
                  await userService.createUserWithUid(user, id);
                } else {
                  // Update existing User doc
                  await userService.updateUser(user);
                }

                // Create/Update Livreur
                final livreur = Livreur(
                  id: id,
                  name: '${_nomController.text} ${_prenomController.text}',
                  phone: _phoneController.text,
                  isAvailable: _isAvailable,
                  activeOrders: widget.livreur?.activeOrders ?? 0,
                  currentLocation: widget.livreur?.currentLocation,
                  photoUrl: widget.livreur?.photoUrl,
                );

                if (widget.livreur == null) {
                  await livreurService.createLivreurWithId(livreur, id);
                } else {
                  await livreurService.updateLivreur(livreur);
                }

                if (context.mounted) {
                  Navigator.pop(context, livreur);
                }
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e')),
                );
              }
            }
          },
          child: const Text('Enregistrer'),
        ),
      ],
    );
  }
}
