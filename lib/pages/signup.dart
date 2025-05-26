import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_screen.dart';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> creaSchedaPerNuovoUtente(User user) async {
    final schedaRef = _firestore
        .collection('users')
        .doc(user.uid)
        .collection('schede')
        .doc();

    await schedaRef.set({
      'nome': 'Scheda Allenamento',
      'data_creazione': FieldValue.serverTimestamp(),
    });
  }
  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
        ),
        backgroundColor: AppDesignSystem.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
        ),
      ),
    );
  }

  Future<void> _signUp() async {
    if (passwordController.text != confirmPasswordController.text) {
      showError('Le password non coincidono');
      return;
    }
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

      await creaSchedaPerNuovoUtente(userCredential.user!);

      nameController.clear();
      emailController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      // Porta l'utente alla HomeScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const HomeScreen(initialTab: 0),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showError(e.message ?? "Errore durante la registrazione");
    }
  }
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceOverlay,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
        border: Border.all(
          color: AppDesignSystem.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: AppDesignSystem.bodyMedium.copyWith(
          color: AppDesignSystem.textPrimary,
        ),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: AppDesignSystem.primary),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.paddingL,
            vertical: AppDesignSystem.paddingM,
          ),
          hintText: label,
          hintStyle: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.textTertiary,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        title: Text(
          'Registrazione',
          style: AppDesignSystem.headingMedium.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: AppDesignSystem.textPrimary,
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppDesignSystem.paddingL),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDesignSystem.paddingL),
                
                // Header section
                Text(
                  'Crea il tuo account',
                  style: AppDesignSystem.headingLarge.copyWith(
                    color: AppDesignSystem.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDesignSystem.paddingS),
                Text(
                  'Inizia il tuo viaggio fitness con PlayTheFit',
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppDesignSystem.paddingXL),
                
                // Form fields
                _buildTextField(
                  nameController,
                  'Nome',
                  Icons.person,
                ),
                const SizedBox(height: AppDesignSystem.paddingM),
                _buildTextField(
                  emailController,
                  'Email',
                  Icons.email,
                ),
                const SizedBox(height: AppDesignSystem.paddingM),
                _buildTextField(
                  passwordController,
                  'Password',
                  Icons.lock,
                  isPassword: true,
                ),
                const SizedBox(height: AppDesignSystem.paddingM),
                _buildTextField(
                  confirmPasswordController,
                  'Conferma Password',
                  Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: AppDesignSystem.paddingXL),
                
                // Action button
                AppComponents.primaryButton(
                  text: 'Crea Account',
                  onPressed: _signUp,
                  fullWidth: true,
                  icon: Icons.person_add,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
