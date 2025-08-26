import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'cadastro_e_login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  var debugDisableImplicitAnimations = true;

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class DefaultFirebaseOptions {
  static var currentPlatform;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Saúde+',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginPage(),
    );
  }
}

