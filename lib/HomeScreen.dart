import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math' as math;
import 'pages/scheda_allenamento_page.dart';

/// Widget principale della schermata Home dell'applicazione.
/// Mostra il personaggio dell'utente, il suo livello, sfide giornaliere
/// e fornisce accesso alle funzionalità principali dell'app.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final User user = FirebaseAuth.instance.currentUser!;

  // Configurazione del sistema di progressione
  final int userLevel = 5;
  final double expProgress = 0.7;
  final String characterAsset = 'assets/character.png';
  
  // Stato della navigazione
  int _selectedIndex = 0;

  // Controllers per le animazioni
  late AnimationController _characterAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _experienceBarAnimationController;
  late AnimationController _profileIconAnimationController;

  late Animation<double> _characterScaleAnimation;
  late Animation<double> _experienceBarAnimation;
  late Animation<double> _profileIconAnimation;

  @override
  void initState() {
    super.initState();

    // Inizializza animazione "respiro" del personaggio
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

    // Inizializza animazione dello sfondo stellato
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Inizializza animazione per la barra esperienza
    _experienceBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _experienceBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_experienceBarAnimationController);

    // Inizializza animazione per l'icona profilo
    _profileIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _profileIconAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_profileIconAnimationController);
  }

  @override
  void dispose() {
    // Rilascia tutte le risorse delle animazioni
    _characterAnimationController.dispose();
    _particleAnimationController.dispose();
    _experienceBarAnimationController.dispose();
    _profileIconAnimationController.dispose();
    super.dispose();
  }
  
  /// Gestisce la navigazione quando viene selezionato un elemento della barra inferiore
  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Gestione della navigazione in base all'elemento selezionato
    switch(index) {
      case 0: // Home (già visualizzata)
        break;
      case 1: // Statistiche
        // TODO: Implementare navigazione alle statistiche
        break;
      case 2: // Allenamento
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const SchedaAllenamentoPage(),
          ),
        );
        break;
      case 3: // Missioni
        // TODO: Implementare navigazione alle missioni
        break;
      case 4: // Profilo
        // TODO: Implementare navigazione al profilo
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      bottomNavigationBar: _buildNavigationBar(),
      body: Stack(
        children: [
          _buildBackground(),
          _buildStarfieldAnimation(),
          _buildMainContent(),
        ],
      ),
    );
  }

  /// Costruisce la barra di navigazione inferiore con pulsante centrale evidenziato
  Widget _buildNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.black,
          selectedItemColor: Colors.blue,
          unselectedItemColor: Colors.grey,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
          ),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Statistiche',
            ),
            // Pulsante centrale più grande e prominente
            BottomNavigationBarItem(
              icon: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue.shade700, Colors.blue.shade900],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.fitness_center,
                  color: Colors.white,
                  size: 26,
                ),
              ),
              label: 'Allenamento',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.emoji_events_outlined),
              label: 'Missioni',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profilo',
            ),
          ],
        ),
      ),
    );
  }

  /// Crea lo sfondo con gradiente
  Widget _buildBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.indigo.shade900, Colors.black],
        ),
      ),
    );
  }

  /// Crea l'animazione del campo stellare di sfondo
  Widget _buildStarfieldAnimation() {
    return AnimatedBuilder(
      animation: _particleAnimationController,
      builder: (context, child) {
        return CustomPaint(
          painter: StarfieldPainter(
            animation: _particleAnimationController.value,
          ),
          size: Size.infinite,
        );
      },
    );
  }

  /// Costruisce il contenuto principale della home
  Widget _buildMainContent() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          _buildExperienceBar(),
          _buildCharacterSection(),
          _buildDailyChallenge(),
        ],
      ),
    );
  }

  /// Costruisce l'header con nome utente, pulsante amici e livello
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Nome utente
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

          Row(
            children: [
              // Pulsante per accedere alla funzionalità amici
              GestureDetector(
                onTap: () {
                  // Placeholder per la funzionalità amici
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Funzionalità amici in arrivo!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade800,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.people_alt_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              
              // Badge di livello
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
            ],
          ),
        ],
      ),
    );
  }

  /// Costruisce la barra dell'esperienza animata
  Widget _buildExperienceBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
      child: Stack(
        children: [
          // Sfondo della barra
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          // Indicatore di progresso animato
          LayoutBuilder(
            builder: (context, constraints) {
              return AnimatedBuilder(
                animation: _experienceBarAnimation,
                builder: (context, child) {
                  return Container(
                    height: 6,
                    width: constraints.maxWidth * expProgress,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue,
                          Colors.purple,
                          Colors.blue,
                        ],
                        stops: const [0.0, 0.5, 1.0],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        transform: GradientRotation(
                          _experienceBarAnimation.value * 2 * math.pi,
                        ),
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(
                            0.5 + _experienceBarAnimation.value * 0.2,
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
    );
  }

  /// Costruisce la sezione del personaggio animato
  Widget _buildCharacterSection() {
    return Expanded(
      child: Center(
        child: ScaleTransition(
          scale: _characterScaleAnimation,
          child: Hero(
            tag: 'character',
            child: Container(
              height: 300,
              width: 300,
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
                  return Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      size: 150,
                      color: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Costruisce la card della sfida giornaliera con indicatore di progresso
  Widget _buildDailyChallenge() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900.withOpacity(0.7),
              Colors.purple.shade900.withOpacity(0.7),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.notifications,
                    color: Colors.amber,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    "Sfida giornaliera",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    "NUOVO",
                    style: TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              "Completa 3000 passi oggi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: 0.4,
                minHeight: 10,
                backgroundColor: Colors.grey.shade800,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.amber,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "1200/3000 passi",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 13,
              ),
              textAlign: TextAlign.end,
            ),
          ],
        ),
      ),
    );
  }
}

/// Painter personalizzato per l'effetto di sfondo stellato con movimento lento
class StarfieldPainter extends CustomPainter {
  final double animation;

  StarfieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    _drawNebulosities(canvas, size);
    _drawTwinklingStars(canvas, size);
  }

  /// Disegna nebulose colorate con movimento lento
  void _drawNebulosities(Canvas canvas, Size size) {
    final seed = 12345; // Seed costante per posizioni coerenti
    final random = math.Random(seed);

    // Crea 4 nebulose con movimento lento
    for (int i = 0; i < 4; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      // Movimento lento
      final offsetX = math.sin(animation * 0.01 + i) * 20;
      final offsetY = math.cos(animation * 0.008 + i * 0.5) * 15;

      final x = (baseX + offsetX) % size.width;
      final y = (baseY + offsetY) % size.height;

      // Dimensione e colore
      final radius = 100.0 + random.nextDouble() * 150;
      final colors = [
        Colors.blue.withOpacity(0.03),
        Colors.purple.withOpacity(0.04),
        Colors.indigo.withOpacity(0.03),
        Colors.cyan.withOpacity(0.02),
      ];
      final color = colors[i % colors.length];

      // Applica gradiente radiale per effetto nebulosa
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

  /// Disegna stelle con effetto scintillante
  void _drawTwinklingStars(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final seed = 54321; // Seed costante per le stelle
    final random = math.Random(seed);

    // Crea 150 stelle con effetto scintillante indipendente
    for (int i = 0; i < 150; i++) {
      // Posizione fissa per ogni stella
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final baseStarSize = 0.5 + random.nextDouble() * 1.5;
      final phase = random.nextDouble() * math.pi * 2;
      final twinkleSpeed = 0.2 + random.nextDouble() * 0.3;
      final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(animation * twinkleSpeed + phase));
      final starSize = baseStarSize * (0.8 + 0.2 * twinkle);

      // Varia colori delle stelle per effetto realistico
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

      // Disegna stella con effetto luminoso
      canvas.drawCircle(Offset(x, y), starSize, paint..color = starColor);

      // Aggiunge bagliore extra ad alcune stelle
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
  bool shouldRepaint(covariant StarfieldPainter oldDelegate) =>
      oldDelegate.animation != animation;
}
