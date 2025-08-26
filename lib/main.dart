import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'cadastro_e_login/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await AwesomeNotifications().initialize(
    'resource://mipmap/ic_launcher', // ícone válido
    [
      NotificationChannel(
        channelKey: 'basic_channel',
        channelName: 'Notificações Básicas',
        channelDescription: 'Canal de notificação para testes básicos',
        defaultColor: Colors.redAccent,
        ledColor: Colors.white,
        importance: NotificationImportance.High,
        vibrationPattern: Int64List.fromList([500, 1000, 500, 1000]),
        playSound: true,
      )
    ],
    debug: true,
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

