import 'package:flutter/material.dart';
// Assicurati che il percorso sia corretto per la tua struttura di cartelle
import 'package:playthefit/Login/login.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async { // 1. Rendi la funzione main 'async'

  // 2. Assicurati che i binding di Flutter siano inizializzati
  //    Questo è NECESSARIO se chiami initializeApp PRIMA di runApp
  WidgetsFlutterBinding.ensureInitialized();

  // 3. Inizializza Firebase usando le opzioni per la piattaforma corrente
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 4. Ora puoi eseguire la tua app
  runApp(const MyApp()); // Sostituisci MyApp con il nome della tua widget principale
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Login(),
    );
  }
}
