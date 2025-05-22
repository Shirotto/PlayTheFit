import 'package:flutter/material.dart';
import 'pages/signup.dart'; 
/*questa classe mi serve per visualizzare
la pagina sul browser*/
void main() {
  runApp(const PreviewSignupApp());
}

class PreviewSignupApp extends StatelessWidget {
  const PreviewSignupApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignupPage(), // <-- Mostra direttamente SignupPage
    );
  }
}
