import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

// Import componenti
import '../Components/Heading.dart';
import '../Components/card_button.dart';
import '../Components/custom_container.dart';
import '../Components/social_media_icons.dart';
import '../HomeScreen.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> with SingleTickerProviderStateMixin {
  bool signup = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // Sfondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade900, Colors.black],
              ),
            ),
          ),

          // Effetto stellare
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: SlowStarfieldPainter(
                  animation: _animationController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Contenuto principale
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 20),
                Image.asset(
                  'assets/images/logo.png',
                  height: 80,
                  errorBuilder: (context, error, stackTrace) {
                    // Mostra un'icona placeholder se il logo non viene caricato
                    return Icon(
                      Icons.rocket_launch, // Esempio di icona
                      size: 80,
                      color: Colors.white.withOpacity(0.7),
                    );
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade900.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(
                        color: Colors.blue.shade400.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.shade800.withOpacity(0.4),
                          blurRadius: 15,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.only(right: 70),
                          child: Text(
                            signup ? "Registrati" : "Accedi",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.blue.shade400,
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          signup
                              ? "Crea un nuovo account"
                              : "Bentornato nel tuo spazio fitness",
                          style: TextStyle(
                            color: Colors.blue.shade100,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 30),
                        _buildSocialLoginButtons(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Row(
                            children: [
                              Expanded(
                                child: Divider(
                                  color: Colors.blue.shade200.withOpacity(0.5),
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  "oppure",
                                  style: TextStyle(color: Colors.blue.shade100),
                                ),
                              ),
                              Expanded(
                                child: Divider(
                                  color: Colors.blue.shade200.withOpacity(0.5),
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children: [
                                if (signup)
                                  _buildTextField(
                                    nameController,
                                    "Nome",
                                    Icons.person,
                                  ),
                                _buildTextField(
                                  emailController,
                                  "Email",
                                  Icons.email,
                                ),
                                _buildTextField(
                                  passwordController,
                                  "Password",
                                  Icons.lock,
                                  isPassword: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildActionButton(),
                        const SizedBox(height: 15),
                        GestureDetector(
                          onTap: toggleAuthMode,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  signup
                                      ? "Hai già un account?"
                                      : "Non hai un account?",
                                  style: TextStyle(color: Colors.blue.shade100),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  signup ? "Accedi" : "Registrati",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    shadows: [
                                      Shadow(
                                        color: Colors.blue.shade400,
                                        blurRadius: 5,
                                      ),
                                    ],
                                  ),
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
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Colors.blue.shade300.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue.shade300),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
          hintText: label,
          hintStyle: TextStyle(color: Colors.blue.shade100.withOpacity(0.7)),
        ),
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(Icons.g_mobiledata, Colors.red),
        const SizedBox(width: 20),
        _buildSocialButton(Icons.facebook, Colors.blue),
        const SizedBox(width: 20),
        _buildSocialButton(Icons.apple, Colors.white),
      ],
    );
  }

  Widget _buildSocialButton(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.5), width: 1.5),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  Widget _buildActionButton() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade700.withOpacity(0.5),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: signup ? _signUp : _signIn,
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: Text(
          signup ? "Registrati" : "Accedi",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void toggleAuthMode() {
    setState(() {
      signup = !signup;
    });
  }

  Future<void> _signUp() async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
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
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade900,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class SlowStarfieldPainter extends CustomPainter {
  final double animation;

  SlowStarfieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    _drawNebulosities(canvas, size);
    _drawTwinklingStars(canvas, size);
  }

  // Disegna le nebulose animandone la posizione
  void _drawNebulosities(Canvas canvas, Size size) {
    final seed = 12345; // Seme fisso per la generazione casuale
    final random = math.Random(seed);

    for (int i = 0; i < 4; i++) {
      // Posizione base della nebulosa
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Offset animato per simulare il movimento
      final offsetX = math.sin(animation * 0.01 + i) * 20;
      final offsetY = math.cos(animation * 0.008 + i * 0.5) * 15;

      final x = (baseX + offsetX) % size.width;
      final y = (baseY + offsetY) % size.height;

      final radius = 100.0 + random.nextDouble() * 150; // Raggio casuale

      // Colori per le nebulose
      final colors = [
        Colors.blue.withOpacity(0.03),
        Colors.purple.withOpacity(0.04),
        Colors.indigo.withOpacity(0.03),
        Colors.cyan.withOpacity(0.02),
      ];

      final color = colors[i % colors.length];

      // Gradiente radiale per l'effetto nebulosa
      final gradient = RadialGradient(
        center: Alignment.center,
        radius: 1.0,
        colors: [color, color.withOpacity(0.0)],
        stops: const [0.2, 1.0],
      );

      final rect = Rect.fromCircle(center: Offset(x, y), radius: radius);
      final paint = Paint()..shader = gradient.createShader(rect);

      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  // Disegna le stelle con effetto scintillante
  void _drawTwinklingStars(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final seed = 54321; // Seme fisso per la generazione casuale
    final random = math.Random(seed);

    for (int i = 0; i < 150; i++) {
      // Posizione fissa per ogni stella
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Dimensione base della stella
      final baseStarSize = 0.5 + random.nextDouble() * 1.5;

      // Calcola l'effetto scintillante
      final phase =
          random.nextDouble() * math.pi * 2; // Fase casuale per ogni stella
      final twinkleSpeed =
          0.2 + random.nextDouble() * 0.3; // Velocità di scintillio variabile
      final twinkle =
          0.4 + 0.6 * (0.5 + 0.5 * math.sin(animation * twinkleSpeed + phase));

      // Dimensione finale della stella (base * scintillio)
      final starSize = baseStarSize * (0.8 + 0.2 * twinkle);

      // Determina il colore della stella
      Color starColor;
      final colorSeed = random.nextInt(100);
      if (colorSeed < 5) {
        starColor = Colors.lightBlueAccent.withOpacity(0.6 * twinkle);
      } else if (colorSeed < 10) {
        starColor = Colors.purpleAccent.withOpacity(0.5 * twinkle);
      } else if (colorSeed < 15) {
        starColor = Colors.amberAccent.withOpacity(0.5 * twinkle);
      } else if (colorSeed < 17) {
        starColor = Colors.redAccent.withOpacity(0.4 * twinkle);
      } else {
        starColor = Colors.white.withOpacity(0.3 * twinkle);
      }

      // Disegna la stella
      canvas.drawCircle(Offset(x, y), starSize, paint..color = starColor);

      // Aggiunge un effetto di bagliore ad alcune stelle
      if (colorSeed < 20) {
        canvas.drawCircle(
          Offset(x, y),
          starSize * 2, // Raggio del bagliore più grande
          paint
            ..color = starColor.withOpacity(
              0.1 * twinkle,
            ), // Bagliore più tenue
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SlowStarfieldPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
