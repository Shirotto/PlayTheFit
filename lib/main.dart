import 'package:flutter/material.dart';
// Assicurati che il percorso sia corretto per la tua struttura di cartelle
import 'package:playthefit/pages/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

void main() async {
  // 1. Rendi la funzione main 'async'

  // 2. Assicurati che i binding di Flutter siano inizializzati
  //    Questo è NECESSARIO se chiami initializeApp PRIMA di runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inizializza Firebase usando le opzioni per la piattaforma corrente
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 4. Ora puoi eseguire la tua app
  runApp(
    const MyApp(),
  ); // Sostituisci MyApp con il nome della tua widget principale
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF0D47A1), // Deep blue
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          secondary: const Color(0xFF42A5F5), // Lighter blue for accents
        ),
        fontFamily: 'Poppins', // You'll need to add this font
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
