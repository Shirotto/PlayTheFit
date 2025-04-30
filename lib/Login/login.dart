import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore
import 'package:firebase_core/firebase_core.dart'; // Inizializzazione Firebase

// Componenti personalizzati
import '../Components/Heading.dart';
import '../Components/card_button.dart';
import '../Components/custom_container.dart';
import '../Components/social_media_icons.dart';

// Schermata di destinazione dopo login/registrazione
import '../HomeScreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  bool signup = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 11,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(right: 70),
                      child: Heading(signup: signup),
                    ),
                    const SizedBox(height: 20),
                    const SocialMediaIcons(),
                    const Padding(
                      padding: EdgeInsets.only(top: 30),
                      child: Text(
                        "Qui non so se ci scriviamo qualcosa",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: CustomContainer(
                          signup: signup,
                          email: emailController,
                          password: passwordController,
                          name: nameController,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    signup
                        ? CardButton(
                      txt: "Registrati",
                      onTap: () => _signUp(),
                    )
                        : CardButton(
                      txt: "Login",
                      onTap: () => _signIn(),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: toggleAuthMode,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              signup ? "Hai già un account?" : "Non hai un account?",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              signup ? "Login" : "Registrati",
                              style: const TextStyle(color: Colors.blue),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            Expanded(flex: 1, child: Container())
          ],
        ),
      ),
    );
  }

  // Cambia tra login e registrazione
  void toggleAuthMode() {
    setState(() {
      signup = !signup;
    });
  }

  // Funzione di registrazione
  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await _firestore.collection("users").doc(userCredential.user?.uid).set({
        "name": nameController.text.trim(),
        "email": emailController.text.trim(),
        "createdAt": FieldValue.serverTimestamp(),
      });

      nameController.clear();
      emailController.clear();
      passwordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Errore durante la registrazione");
    }
  }

  // Funzione di login
  Future<void> _signIn() async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      emailController.clear();
      passwordController.clear();

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Errore durante il login");
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
