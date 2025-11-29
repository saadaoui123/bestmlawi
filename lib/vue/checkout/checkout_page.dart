import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:projet_best_mlewi/navigation/app_router.dart'; // Importer AppRouter pour la redirection
import 'package:projet_best_mlewi/service/cart_service.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';
import 'package:projet_best_mlewi/model/commande.dart';

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  bool _isLoading = true; // Pour afficher un indicateur de chargement

  @override
  void initState() {
    super.initState();
    _checkAuthAndLoadUserData();
  }

  Future<void> _checkAuthAndLoadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si l'utilisateur n'est pas connecté, on le redirige vers la page de connexion
      // On utilise un post-frame callback pour s'assurer que le build est terminé
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Veuillez vous connecter pour continuer')),
          );
          AppRouter.pushNamedAndRemoveUntil('/login', (route) => false);
        }
      });
      return;
    }

    // Si l'utilisateur est connecté, on charge ses données depuis Firestore
    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        final data = userDoc.data()!;
        _nameController.text = data['lastName'] ?? ''; // 'lastName' ou 'name' selon votre BDD
        _firstNameController.text = data['firstName'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _addressController.text = data['address'] ?? '';
      }
    } catch (e) {
      print("Erreur lors du chargement des données utilisateur: $e");
      // On peut continuer même si les données ne sont pas chargées
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _firstNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    // La vérification dans initState garantit que l'utilisateur est connecté ici
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur: utilisateur non authentifié.')),
      );
      return;
    }

    final cartService = Provider.of<CartService>(context, listen: false);
    if (cartService.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Votre panier est vide !')),
      );
      return;
    }

    final String userId = user.uid; // L'ID utilisateur est maintenant non-nullable

    final List<Map<String, dynamic>> orderItems = cartService.items.map((item) => {
      'name': item.name,
      'price': item.price,
      'quantity': item.quantity,
      'image': item.image,
    }).toList();

    const double deliveryFee = 7.00;
    final double subtotal = cartService.totalPrice;
    final double total = subtotal + deliveryFee;

    final newOrder = Commande(
      userId: userId, // On assigne l'ID client qui ne peut être nul
      clientName: _nameController.text.trim(),
      clientFirstName: _firstNameController.text.trim(),
      clientPhone: _phoneController.text.trim(),
      clientAddress: _addressController.text.trim(),
      items: orderItems,
      totalPrice: total,
      orderDate: DateTime.now(),
      status: 'pending',
    );

    try {
      final orderService = Provider.of<OrderService>(context, listen: false);
      final notificationService = Provider.of<NotificationService>(context, listen: false);

      await orderService.createOrder(newOrder, notificationService);

      cartService.clearCart();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Votre commande a été passée avec succès!')),
        );

        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      print('Error placing order: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du passage de la commande: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Affiche un indicateur de chargement pendant la vérification de l'authentification
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Passer à la caisse')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Passer à la caisse'),
        // On garde le bouton de retour pour que l'utilisateur puisse retourner au panier
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Informations de Livraison',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Nom',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'Prénom',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre prénom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      decoration: const InputDecoration(
                        labelText: 'Téléphone',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre numéro de téléphone';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Adresse',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre adresse de livraison';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _placeOrder,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.amber[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Valider la commande', style: TextStyle(fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
