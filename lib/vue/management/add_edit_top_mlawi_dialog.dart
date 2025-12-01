// lib/vue/management/add_edit_top_mlawi_dialog.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/model/top_mlawi.dart';
import 'package:projet_best_mlewi/service/top_mlawi_service.dart';

class AddEditTopMlawiDialog extends StatefulWidget {
  final TopMlawi? topMlawi;
  const AddEditTopMlawiDialog({super.key, this.topMlawi});

  @override
  State<AddEditTopMlawiDialog> createState() => _AddEditTopMlawiDialogState();
}

class _AddEditTopMlawiDialogState extends State<AddEditTopMlawiDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _capacityController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  bool _isAvailable = true;
  bool _isLoading = false;

  bool get _isEditing => widget.topMlawi != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.topMlawi?.name ?? '');
    _addressController = TextEditingController(text: widget.topMlawi?.address ?? '');
    _capacityController = TextEditingController(text: widget.topMlawi?.maxCapacity.toString() ?? '10');
    _latitudeController = TextEditingController(text: widget.topMlawi?.location.latitude.toString() ?? '');
    _longitudeController = TextEditingController(text: widget.topMlawi?.location.longitude.toString() ?? '');
    _isAvailable = widget.topMlawi?.isAvailable ?? true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final service = Provider.of<TopMlawiService>(context, listen: false);

    try {
      final newPoint = TopMlawi(
        id: widget.topMlawi?.id ?? '', // L'ID sera ignoré à la création
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        location: GeoPoint(
          double.parse(_latitudeController.text),
          double.parse(_longitudeController.text),
        ),
        isAvailable: _isAvailable,
        maxCapacity: int.parse(_capacityController.text),
        currentCapacity: widget.topMlawi?.currentCapacity ?? 0,
      );

      if (_isEditing) {
        await service.updateTopMlawi(newPoint);
      } else {
        await service.createTopMlawi(newPoint);
      }

      if(mounted) Navigator.of(context).pop();

    } catch (e) {
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    } finally {
      if(mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isEditing ? 'Modifier le point de vente' : 'Ajouter un point de vente'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'Nom')),
              TextFormField(controller: _addressController, decoration: const InputDecoration(labelText: 'Adresse')),
              TextFormField(controller: _capacityController, decoration: const InputDecoration(labelText: 'Capacité maximale'), keyboardType: TextInputType.number),
              TextFormField(controller: _latitudeController, decoration: const InputDecoration(labelText: 'Latitude'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              TextFormField(controller: _longitudeController, decoration: const InputDecoration(labelText: 'Longitude'), keyboardType: TextInputType.numberWithOptions(decimal: true)),
              SwitchListTile(
                title: const Text('Disponible'),
                value: _isAvailable,
                onChanged: (val) => setState(() => _isAvailable = val),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Annuler')),
        _isLoading
            ? const CircularProgressIndicator()
            : ElevatedButton(onPressed: _save, child: const Text('Enregistrer')),
      ],
    );
  }
}
