import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:projet_best_mlewi/service/coordinateur_service.dart';
import 'package:projet_best_mlewi/vue/auth_wrapper.dart';
import 'package:provider/provider.dart';
import 'package:projet_best_mlewi/service/cart_service.dart';
import 'package:projet_best_mlewi/service/product_service.dart';
import 'package:projet_best_mlewi/service/blog_service.dart';
import 'package:projet_best_mlewi/service/settings_service.dart';
import 'package:projet_best_mlewi/service/order_service.dart';
import 'package:projet_best_mlewi/service/top_mlawi_service.dart';
import 'package:projet_best_mlewi/service/livreur_service.dart';
import 'package:projet_best_mlewi/service/notification_service.dart';
import 'package:projet_best_mlewi/theme/app_theme.dart';
import 'package:projet_best_mlewi/navigation/route_generator.dart';
import 'package:projet_best_mlewi/service/auth_service.dart';
import 'package:projet_best_mlewi/navigation/app_router.dart';
import 'firebase_options.dart';

import 'package:projet_best_mlewi/service/user.service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartService()),
        ChangeNotifierProvider(create: (_) => ProductService()),
        ChangeNotifierProvider(create: (_) => BlogService()),
        ChangeNotifierProvider(create: (_) => SettingsService()),

        ChangeNotifierProvider(create: (_) => CoordinateurService()),
        Provider(create: (_) => OrderService()),
        ChangeNotifierProvider(create: (_) => TopMlawiService()),
        ChangeNotifierProvider(create: (_) => LivreurService()),
        ChangeNotifierProvider(create: (_) => UserService()),
        ChangeNotifierProvider(create: (_) => NotificationService()),
        Provider(create: (_) => AuthService()),
      ],
      child: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'BestMlawi',
            navigatorKey: AppRouter.navigatorKey,
            theme: settings.darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            onGenerateRoute: RouteGenerator.generateRoute,
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}
