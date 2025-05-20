import 'package:flutter/material.dart';
import 'package:playthefit/pages/settings_page.dart'; // Import con il nome del package

/*
Questa classe mi serve per visualizzare la pagina delle impostazioni
sul browser durante lo sviluppo.
*/
void main() {
  runApp(const PreviewSettingsApp());
}

class PreviewSettingsApp extends StatelessWidget {
  const PreviewSettingsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SettingsPage(), // Mostra direttamente SettingsPage
    );
  }
}