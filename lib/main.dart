import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:projet_best_mlewi/vue/app_shell.dart'; // Import AppShell
import 'package:projet_best_mlewi/vue/authentification/register.page.dart';
import 'package:projet_best_mlewi/vue/authentification/login.page.dart';
import 'package:projet_best_mlewi/vue/profile/profile_page.dart'; // Import ProfilePage
import 'package:projet_best_mlewi/vue/cart/cart_page.dart'; // Import CartPage
import 'package:projet_best_mlewi/vue/product_detail/product_detail_page.dart'; // Corrected Import ProductDetailPage
import 'package:provider/provider.dart'; // Import provider
import 'package:projet_best_mlewi/service/cart_service.dart'; // Import CartService
import 'firebase_options.dart';
import 'package:projet_best_mlewi/vue/checkout/checkout_page.dart'; // Import CheckoutPage
import 'package:projet_best_mlewi/vue/orders/orders_page.dart'; // Import OrdersPage
import 'package:projet_best_mlewi/vue/orders/order_detail_page.dart'; // Import OrderDetailPage
import 'package:projet_best_mlewi/model/commande.dart'; // Import Commande

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartService(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const AppShell(), // AppShell is now the main entry point
          '/register': (context) => RegisterPage(),
          '/login': (context) => LoginPage(),
          '/profile': (context) => ProfilePage(),
          '/cart': (context) => CartPage(),
          '/product_detail': (context) {
            final product = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
            return ProductDetailPage(product: product);
          },
          '/orders': (context) => OrdersPage(),
          '/order_detail': (context) {
            final order = ModalRoute.of(context)!.settings.arguments as Commande;
            return OrderDetailPage(order: order);
          },
        },
      ),
    );
  }
}
