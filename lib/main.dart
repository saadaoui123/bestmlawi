import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:projet_best_mlewi/vue/authentification/register.page.dart';
import 'firebase_options.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp (MyApp ());
}

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      home: StreamBuilder<User?>(stream:FirebaseAuth.instance.authStateChanges(),
          builder: (context,snapshot){
            return RegisterPage();
          }
      ),

    );
  }
}


