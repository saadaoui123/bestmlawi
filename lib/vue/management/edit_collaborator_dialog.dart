// lib/vue/management/edit_collaborator_dialog.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/model/top_mlawi.dart'; // Importer le modèle
import 'package:projet_best_mlewi/service/top_mlawi_service.dart'; // Importer le service

class EditCollaboratorDialog extends StatefulWidget {
  final DocumentSnapshot collaborator;

  const EditCollaboratorDialog({super.key, required this.collaborator});

  @override
  State<EditCollaboratorDialog> createState() => _EditCollaboratorDialogState();
}

class _EditCollaboratorDialogState extends State<EditCollaboratorDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _emailController;

  String? _selectedTopMlewiId;

  // Utiliser le modèle TopMlawi au lieu de DocumentSnapshot
  List<TopMlawi> _topMlewiList = [];

  bool _isLoading = false;
  bool _isTopMlewiLoading = true;

  // Instance du service
  final TopMlawiService _topMlawiService = TopMlawiService();

  @override
  void initState() {
    super.initState();
    final data = widget.collaborator.data() as Map<String, dynamic>;
    _firstNameController = TextEditingController(text: data['firstName'] ?? '');
    _lastNameController = TextEditingController(text: data['lastName'] ?? '');
    _emailController = TextEditingController(text: data['email'] ?? '');

    // Assurez-vous que ce champ existe dans vos données utilisateur
    _selectedTopMlewiId = data['topmlewi_id'];

    _fetchTopMlewiList();
  }

  // MODIFIÉ : Utilise maintenant le service pour charger les données
  Future<void> _fetchTopMlewiList() async {
    try {
      // On utilise le Stream du service, mais on ne prend que la première valeur avec .first
      // pour simuler un Future, car le dialogue n'a pas besoin de se mettre à jour en temps réel.
      final list = await _topMlawiService.getAllTopMlawi().first;
      setState(() {
        _topMlewiList = list;
        _isTopMlewiLoading = false;
      });
    } catch (e) {
      setState(() {
        _isTopMlewiLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur de chargement des topmlewi: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _updateCollaborator() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isLoading = true);

    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.collaborator.id).update({
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'email': _emailController.text.trim(),
        'topmlewi_id': _selectedTopMlewiId,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Informations mises à jour.')),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: $e')),
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
      title: const Text('Modifier le collaborateur'),
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
              const SizedBox(height: 12),

              _isTopMlewiLoading
                  ? const Center(child: Padding(
                padding: EdgeInsets.all(8.0),
                child: CircularProgressIndicator(),
              ))
                  : DropdownButtonFormField<String>(
                value: _selectedTopMlewiId,
                decoration: const InputDecoration(
                  labelText: 'Top Mlewi',
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Sélectionner un top mlewi'),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedTopMlewiId = newValue;
                  });
                },
                // MODIFIÉ : On itère sur une liste de TopMlawi
                items: _topMlewiList.map<DropdownMenuItem<String>>((TopMlawi topMlawi) {
                  return DropdownMenuItem<String>(
                    value: topMlawi.id, // La valeur est l'ID du modèle
                    child: Text(topMlawi.name), // L'affichage est le nom du modèle
                  );
                }).toList(),
                validator: (value) => value == null ? 'Veuillez sélectionner un top mlewi' : null,
              ),

              const SizedBox(height: 16),
              const Text(
                "Note : La modification de l'email ici ne change pas l'email de connexion de l'utilisateur.",
                style: TextStyle(fontSize: 12, color: Colors.grey),
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
          onPressed: _updateCollaborator,
          child: const Text('Mettre à jour'),
        ),
      ],
    );
  }
}
