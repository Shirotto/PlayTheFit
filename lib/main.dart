import 'package:flutter/material.dart';
import 'package:playthefit/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  // Inizializzazione dei binding di Flutter
  WidgetsFlutterBinding.ensureInitialized();

  // Inizializzazione di Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1), // Blu profondo
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          secondary: const Color(0xFF42A5F5), // Blu chiaro per accenti
        ),
        fontFamily: 'Poppins',
        useMaterial3: true,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: Login(),
    );
  }
}
