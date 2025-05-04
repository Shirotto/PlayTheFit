import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'pages/scheda_allenamento_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final User user = FirebaseAuth.instance.currentUser!;

  // Variabili per il sistema di livelli (da collegare a un database in futuro)
  final int userLevel = 5; // Esempio di livello utente
  final double expProgress = 0.7; // Valore da 0 a 1 per la barra di esperienza
  final String characterAsset =
      'assets/character.png'; // Da sostituire con il percorso reale

  // Controllers per le animazioni
  late AnimationController _characterAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _experienceBarAnimationController;
  late AnimationController _profileIconAnimationController;
  late AnimationController _settingsIconAnimationController;

  late Animation<double> _characterScaleAnimation;
  late Animation<double> _experienceBarAnimation;
  late Animation<double> _profileIconAnimation;
  late Animation<double> _settingsIconAnimation;

  // Stato per gli effetti di click
  bool _isProfilePressed = false;
  bool _isSettingsPressed = false;
  bool _isTrainingButtonPressed = false;
  bool _isStatsButtonPressed = false;
  bool _isMissionsButtonPressed = false;

  @override
  void initState() {
    super.initState();

    // Animazione del personaggio (effetto respiro)
    _characterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _characterScaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _characterAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    // Animazione particelle (molto più lenta)
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(
        seconds: 60,
      ), // Movimento molto lento (un minuto per ciclo)
    )..repeat();

    // Animazione barra esperienza
    _experienceBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _experienceBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_experienceBarAnimationController);

    // Animazione icona profilo
    _profileIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _profileIconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_profileIconAnimationController);

    // Animazione icona impostazioni
    _settingsIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat();

    _settingsIconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_settingsIconAnimationController);
  }

  @override
  void dispose() {
    _characterAnimationController.dispose();
    _particleAnimationController.dispose();
    _experienceBarAnimationController.dispose();
    _profileIconAnimationController.dispose();
    _settingsIconAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
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

          // Stelle/particelle che si muovono molto lentamente
          AnimatedBuilder(
            animation: _particleAnimationController,
            builder: (context, child) {
              return CustomPaint(
                painter: SlowStarfieldPainter(
                  animation: _particleAnimationController.value,
                ),
                size: Size.infinite,
              );
            },
          ),

          // Contenuto principale
          SafeArea(
            child: Column(
              children: [
                // Header con bottone profilo, nome utente, livello e impostazioni
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Bottone Profilo Animato
                      GestureDetector(
                        onTapDown:
                            (_) => setState(() => _isProfilePressed = true),
                        onTapUp:
                            (_) => setState(() => _isProfilePressed = false),
                        onTapCancel:
                            () => setState(() => _isProfilePressed = false),
                        onTap: () {
                          // Naviga alla pagina profilo (da implementare)
                        },
                        child: AnimatedBuilder(
                          animation: _profileIconAnimation,
                          builder: (context, child) {
                            // Rimuovo la pulsazione mantenendo solo l'effetto bagliore
                            const pulseValue =
                                1.0; // Valore fisso senza pulsazione
                            final glowOpacity =
                                0.5 +
                                0.3 *
                                    math.sin(
                                      _profileIconAnimation.value * math.pi,
                                    );

                            return Transform.scale(
                              scale: _isProfilePressed ? 1.2 : pulseValue,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color:
                                      _isProfilePressed
                                          ? Colors.lightBlue.shade400
                                              .withOpacity(0.9)
                                          : Colors.blue.shade900.withOpacity(
                                            0.7,
                                          ),
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          _isProfilePressed
                                              ? Colors.lightBlue.withOpacity(
                                                0.8,
                                              )
                                              : Colors.blue.withOpacity(
                                                glowOpacity,
                                              ),
                                      spreadRadius: _isProfilePressed ? 3 : 1,
                                      blurRadius: _isProfilePressed ? 12 : 6,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.person,
                                  color: Colors.white,
                                  size: 22,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Nome Utente
                      Text(
                        "${user.email?.split('@').first ?? 'Player'}",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 10.0,
                              color: Colors.blue,
                              offset: Offset(0, 0),
                            ),
                          ],
                        ),
                      ),

                      // Livello con Ingranaggio Impostazioni
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade800,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.blue.withOpacity(0.5),
                                  spreadRadius: 1,
                                  blurRadius: 8,
                                  offset: const Offset(0, 0),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "LV $userLevel",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Icona Impostazioni Animata
                          GestureDetector(
                            onTapDown:
                                (_) =>
                                    setState(() => _isSettingsPressed = true),
                            onTapUp:
                                (_) =>
                                    setState(() => _isSettingsPressed = false),
                            onTapCancel:
                                () =>
                                    setState(() => _isSettingsPressed = false),
                            onTap: () {
                              // Naviga alla pagina impostazioni (da implementare)
                            },
                            child: AnimatedBuilder(
                              animation: _settingsIconAnimation,
                              builder: (context, child) {
                                // Rotazione lenta dell'icona ingranaggio
                                return Transform.rotate(
                                  angle:
                                      _settingsIconAnimation.value *
                                      2 *
                                      math.pi,
                                  child: Transform.scale(
                                    scale: _isSettingsPressed ? 1.2 : 1.0,
                                    child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color:
                                            _isSettingsPressed
                                                ? Colors.lightBlue.shade400
                                                    .withOpacity(0.9)
                                                : Colors.blue.shade900
                                                    .withOpacity(0.7),
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color:
                                                _isSettingsPressed
                                                    ? Colors.lightBlue
                                                        .withOpacity(0.8)
                                                    : Colors.blue.withOpacity(
                                                      0.5,
                                                    ),
                                            spreadRadius:
                                                _isSettingsPressed ? 3 : 1,
                                            blurRadius:
                                                _isSettingsPressed ? 12 : 6,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.settings,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Area del personaggio animato
                Expanded(
                  flex: 3,
                  child: Center(
                    child: ScaleTransition(
                      scale: _characterScaleAnimation,
                      child: Hero(
                        tag: 'character',
                        child: Container(
                          height: 250,
                          width: 250,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                spreadRadius: 10,
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          child: Image.asset(
                            characterAsset,
                            errorBuilder: (context, error, stackTrace) {
                              // Fallback se l'immagine non esiste
                              return Container(
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.blue,
                                ),
                                child: const Icon(
                                  Icons.fitness_center,
                                  size: 120,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Pulsanti azione con effetto illuminazione LED al click
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Pulsante Allenamento
                        GestureDetector(
                          onTapDown:
                              (_) => setState(
                                () => _isTrainingButtonPressed = true,
                              ),
                          onTapUp:
                              (_) => setState(
                                () => _isTrainingButtonPressed = false,
                              ),
                          onTapCancel:
                              () => setState(
                                () => _isTrainingButtonPressed = false,
                              ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const SchedaAllenamentoPage(),
                              ),
                            );
                          },
                          child: _buildLedButton(
                            "ALLENAMENTO",
                            "Inizia la tua avventura",
                            Icons.fitness_center,
                            _isTrainingButtonPressed,
                          ),
                        ),

                        Row(
                          children: [
                            // Pulsante Statistiche
                            Expanded(
                              child: GestureDetector(
                                onTapDown:
                                    (_) => setState(
                                      () => _isStatsButtonPressed = true,
                                    ),
                                onTapUp:
                                    (_) => setState(
                                      () => _isStatsButtonPressed = false,
                                    ),
                                onTapCancel:
                                    () => setState(
                                      () => _isStatsButtonPressed = false,
                                    ),
                                onTap: () {
                                  // Navigazione alle statistiche
                                },
                                child: _buildLedButton(
                                  "STATISTICHE",
                                  "I tuoi progressi",
                                  Icons.bar_chart,
                                  _isStatsButtonPressed,
                                  isSmall: true,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Pulsante Missioni
                            Expanded(
                              child: GestureDetector(
                                onTapDown:
                                    (_) => setState(
                                      () => _isMissionsButtonPressed = true,
                                    ),
                                onTapUp:
                                    (_) => setState(
                                      () => _isMissionsButtonPressed = false,
                                    ),
                                onTapCancel:
                                    () => setState(
                                      () => _isMissionsButtonPressed = false,
                                    ),
                                onTap: () {
                                  // Navigazione alle missioni
                                },
                                child: _buildLedButton(
                                  "MISSIONI",
                                  "Sfide giornaliere",
                                  Icons.emoji_events,
                                  _isMissionsButtonPressed,
                                  isSmall: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Barra esperienza animata
                Padding(
                  padding: const EdgeInsets.fromLTRB(30, 10, 30, 15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "LIVELLO $userLevel",
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${(expProgress * 100).toInt()}%",
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Stack(
                        children: [
                          // Sfondo della barra
                          Container(
                            height: 15,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          // Progresso della barra
                          LayoutBuilder(
                            builder: (context, constraints) {
                              return AnimatedBuilder(
                                animation: _experienceBarAnimation,
                                builder: (context, child) {
                                  return Container(
                                    height: 15,
                                    width: constraints.maxWidth * expProgress,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.blue,
                                          Colors.purple,
                                          Colors.blue,
                                        ],
                                        stops: [0.0, 0.5, 1.0],
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        transform: GradientRotation(
                                          _experienceBarAnimation.value *
                                              2 *
                                              math.pi,
                                        ),
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(
                                            0.5 +
                                                _experienceBarAnimation.value *
                                                    0.2,
                                          ),
                                          spreadRadius: 1,
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Pulsante con effetto LED
  Widget _buildLedButton(
    String title,
    String subtitle,
    IconData icon,
    bool isPressed, {
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isSmall ? 15 : 20,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              isPressed
                  ? [
                    Colors.blue.shade500,
                    Colors.purple.shade500,
                  ] // Più luminoso quando premuto
                  : [
                    Colors.blue.shade800,
                    Colors.purple.shade900,
                  ], // Più scuro quando non premuto
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                isPressed
                    ? Colors.blue.withOpacity(0.8) // Bagliore LED intenso
                    : Colors.blue.withOpacity(0.2), // Leggero bagliore a riposo
            spreadRadius: isPressed ? 3 : 0,
            blurRadius: isPressed ? 15 : 5,
            offset: const Offset(0, 0),
          ),
        ],
        border: Border.all(
          color:
              isPressed
                  ? Colors
                      .lightBlueAccent // Bordo luminoso al click
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: isPressed ? Colors.white : Colors.white.withOpacity(0.8),
            size: isSmall ? 24 : 28,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color:
                        isPressed
                            ? Colors.white
                            : Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: isSmall ? 14 : 18,
                  ),
                ),
                if (!isSmall)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color:
                          isPressed
                              ? Colors.white.withOpacity(0.9)
                              : Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: isPressed ? Colors.white : Colors.white70,
            size: isSmall ? 16 : 18,
          ),
        ],
      ),
    );
  }
}

class SlowStarfieldPainter extends CustomPainter {
  final double animation;

  SlowStarfieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    // Disegno delle nebulose spaziali
    _drawNebulosities(canvas, size);

    // Disegno delle stelle fisse con effetto brillante
    _drawTwinklingStars(canvas, size);
  }

  void _drawNebulosities(Canvas canvas, Size size) {
    final seed = 12345; // Un seme costante per assicurare posizioni coerenti
    final random = math.Random(seed);

    // Creiamo 3-4 nebulose che si muovono lentamente
    for (int i = 0; i < 4; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Movimento molto lento
      final offsetX = math.sin(animation * 0.01 + i) * 20;
      final offsetY = math.cos(animation * 0.008 + i * 0.5) * 15;

      final x = (baseX + offsetX) % size.width;
      final y = (baseY + offsetY) % size.height;

      // Dimensione della nebulosa
      final radius = 100.0 + random.nextDouble() * 150;

      // Colore della nebulosa con opacità molto bassa
      final colors = [
        Colors.blue.withOpacity(0.03),
        Colors.purple.withOpacity(0.04),
        Colors.indigo.withOpacity(0.03),
        Colors.cyan.withOpacity(0.02),
      ];

      final color = colors[i % colors.length];

      // Disegna la nebulosa come un gradiente radiale sfocato
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

  void _drawTwinklingStars(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final seed = 54321; // Seme costante per le stelle
    final random = math.Random(seed);

    // Disegna le stelle fisse con effetto brillante
    for (int i = 0; i < 150; i++) {
      // Posizione fissa per ogni stella
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      // Dimensione variabile della stella
      final baseStarSize = 0.5 + random.nextDouble() * 1.5;

      // Effetto brillante indipendente per ogni stella
      final phase = random.nextDouble() * math.pi * 2; // Fase casuale
      final twinkleSpeed =
          0.2 + random.nextDouble() * 0.3; // Velocità brillantezza variabile
      final twinkle =
          0.4 + 0.6 * (0.5 + 0.5 * math.sin(animation * twinkleSpeed + phase));

      // Dimensione che varia leggermente con l'effetto brillante
      final starSize = baseStarSize * (0.8 + 0.2 * twinkle);

      // Colore della stella
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

      // Disegna una stella con effetto brillante
      canvas.drawCircle(Offset(x, y), starSize, paint..color = starColor);

      // Per alcune stelle, aggiunge un bagliore
      if (colorSeed < 20) {
        canvas.drawCircle(
          Offset(x, y),
          starSize * 2,
          paint..color = starColor.withOpacity(0.1 * twinkle),
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant SlowStarfieldPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
