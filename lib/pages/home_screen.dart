import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;
import 'scheda_allenamento_page.dart';
import 'profile_page.dart';
import 'statistiche_page.dart';
import 'missioni_page.dart';
import 'amici_page.dart';
import 'notifications_page.dart';
import 'chat_list_page.dart';
import '../widgets/notification_badge.dart';
import '../widgets/level_up_celebration.dart';
import '../services/mission_service.dart';
import '../models/player_level.dart';

class HomeScreen extends StatefulWidget {
  final int initialTab;
  const HomeScreen({super.key, this.initialTab = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final User user = FirebaseAuth.instance.currentUser!;
  final MissionService _missionService = MissionService();

  final String characterAsset = 'assets/character.png';

  late int _selectedIndex;
  String? schedaId;

  // Stato per il level up
  bool _showLevelUpCelebration = false;
  int _newLevel = 0;
  List<String> _levelRewards = [];

  late AnimationController _characterAnimationController;
  late AnimationController _particleAnimationController;
  late AnimationController _experienceBarAnimationController;
  late AnimationController _profileIconAnimationController;

  late Animation<double> _characterScaleAnimation;
  late Animation<double> _experienceBarAnimation;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialTab;
    _caricaSchedaId();

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

    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    _experienceBarAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _experienceBarAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_experienceBarAnimationController);

    _profileIconAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  Future<void> _caricaSchedaId() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final snap =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('schede')
            .orderBy('data_creazione')
            .limit(1)
            .get();

    if (snap.docs.isNotEmpty) {
      setState(() {
        schedaId = snap.docs.first.id;
      });
    }
  }

  @override
  void dispose() {
    _characterAnimationController.dispose();
    _particleAnimationController.dispose();
    _experienceBarAnimationController.dispose();
    _profileIconAnimationController.dispose();
    super.dispose();
  }

  void _onNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget allenamentoTab() {
      if (schedaId == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return SchedaAllenamentoPage(schedaId: schedaId!);
    }

    final List<Widget> pageOptions = <Widget>[
      _buildMainContent(),
      const StatistichePage(),
      allenamentoTab(),
      const MissioniPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      backgroundColor: Colors.black87,
      bottomNavigationBar: _buildNavigationBar(),
      body: Stack(
        children: [
          _buildBackground(),
          _buildStarfieldAnimation(),
          IndexedStack(index: _selectedIndex, children: pageOptions),

          // Monitoraggio livello per celebration
          StreamBuilder<PlayerLevel>(
            stream: _missionService.getUserLevelStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data != null) {
                // Primo caricamento dello state
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  _checkForLevelUp(snapshot.data!);
                });
              }

              return const SizedBox.shrink();
            },
          ),

          // Level Up Celebration overlay
          if (_showLevelUpCelebration)
            LevelUpCelebration(
              level: _newLevel,
              rewards: _levelRewards,
              onDismissed: () {
                setState(() {
                  _showLevelUpCelebration = false;
                });
              },
            ),
        ],
      ),
    );
  }

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
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart),
              label: 'Statistiche',
            ),
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
              // Pulsante Chat
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListPage(),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade800,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              // Pulsante Notifiche con badge
              NotificationBadge(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationsPage(),
                    ),
                  ).then((_) {
                    setState(() {});
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: Colors.amber.shade800,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.amber.withOpacity(0.4),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.notifications_active,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              // Pulsante Amici
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AmiciPage()),
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
              ), // Livello utente
              StreamBuilder<PlayerLevel>(
                stream: _missionService.getUserLevelStream(),
                builder: (context, snapshot) {
                  final playerLevel =
                      snapshot.data ??
                      PlayerLevel(
                        level: 1,
                        currentExp: 0,
                        expToNextLevel: 100,
                        totalExp: 0,
                      );

                  return Container(
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
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          "LV ${playerLevel.level}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceBar() {
    return StreamBuilder<PlayerLevel>(
      stream: _missionService.getUserLevelStream(),
      builder: (context, snapshot) {
        final playerLevel =
            snapshot.data ??
            PlayerLevel(
              level: 1,
              currentExp: 0,
              expToNextLevel: 100,
              totalExp: 0,
            );

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 20),
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return AnimatedBuilder(
                    animation: _experienceBarAnimation,
                    builder: (context, child) {
                      return Container(
                        height: 6,
                        width:
                            constraints.maxWidth *
                            playerLevel.progressPercentage,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.blue, Colors.purple, Colors.blue],
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
      },
    );
  }

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

  Widget _buildDailyChallenge() {
    return StreamBuilder<PlayerLevel>(
      stream: _missionService.getUserLevelStream(),
      builder: (context, snapshot) {
        final playerLevel =
            snapshot.data ??
            PlayerLevel(
              level: 1,
              currentExp: 0,
              expToNextLevel: 100,
              totalExp: 0,
            );

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
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        "Sfide Attive",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedIndex = 3; // Vai alla pagina missioni
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          "VEDI TUTTE",
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Completa missioni per accumulare ${playerLevel.expToNextLevel} XP e salire al livello ${playerLevel.level + 1}",
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        value: playerLevel.progressPercentage,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade800,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                      ),
                      // Animazione brillante sopra la barra di progresso
                      AnimatedBuilder(
                        animation: _experienceBarAnimation,
                        builder: (context, child) {
                          return Positioned(
                            left: 0,
                            right: 0,
                            top: 0,
                            bottom: 0,
                            child: AnimatedOpacity(
                              opacity:
                                  0.3 + (_experienceBarAnimation.value * 0.3),
                              duration: const Duration(milliseconds: 500),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.transparent,
                                      Colors.white.withOpacity(0.2),
                                      Colors.transparent,
                                    ],
                                    stops: const [0.0, 0.5, 1.0],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    transform: GradientRotation(
                                      _experienceBarAnimation.value *
                                          2 *
                                          math.pi,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "${playerLevel.currentExp}/${playerLevel.currentExp + playerLevel.expToNextLevel} XP",
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Controlla se c'è stato un level up e mostra la celebrazione
  void _checkForLevelUp(PlayerLevel currentLevel) async {
    // Ottieni l'ultimo livello memorizzato dalle SharedPreferences o da Firestore
    final userDoc =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

    final lastLevelUpDate = userDoc.data()?['lastLevelUpDate'] as Timestamp?;
    final lastShownLevel = userDoc.data()?['lastShownLevel'] as int? ?? 0;

    // Se il livello corrente è maggiore dell'ultimo livello mostrato e non è il primo accesso
    if (currentLevel.level > lastShownLevel && lastShownLevel > 0) {
      // Se c'è stata una data di level up recente (ultimi 60 secondi), mostra la celebrazione
      final now = DateTime.now();

      if (lastLevelUpDate != null) {
        final levelUpTime = lastLevelUpDate.toDate();
        final difference = now.difference(levelUpTime);

        // Se il level up è avvenuto negli ultimi 60 secondi, mostra la celebrazione
        if (difference.inSeconds < 60) {
          // Ottieni le ricompense
          final rewardsMap = LevelRewards.getLevelRewards(currentLevel.level);
          final rewards = rewardsMap[currentLevel.level] ?? [];

          setState(() {
            _showLevelUpCelebration = true;
            _newLevel = currentLevel.level;
            _levelRewards = rewards;
          });

          // Aggiorna l'ultimo livello mostrato
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .update({'lastShownLevel': currentLevel.level});
        }
      }
    } else if (lastShownLevel == 0) {
      // Se è il primo accesso, imposta l'ultimo livello mostrato
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'lastShownLevel': currentLevel.level},
      );
    }
  }
}

class StarfieldPainter extends CustomPainter {
  final double animation;

  StarfieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    _drawNebulosities(canvas, size);
    _drawTwinklingStars(canvas, size);
  }

  void _drawNebulosities(Canvas canvas, Size size) {
    final seed = 12345;
    final random = math.Random(seed);

    for (int i = 0; i < 4; i++) {
      final baseX = random.nextDouble() * size.width;
      final baseY = random.nextDouble() * size.height;

      final offsetX = math.sin(animation * 0.01 + i) * 20;
      final offsetY = math.cos(animation * 0.008 + i * 0.5) * 15;

      final x = (baseX + offsetX) % size.width;
      final y = (baseY + offsetY) % size.height;

      final radius = 100.0 + random.nextDouble() * 150;
      final colors = [
        Colors.blue.withOpacity(0.03),
        Colors.purple.withOpacity(0.04),
        Colors.indigo.withOpacity(0.03),
        Colors.cyan.withOpacity(0.02),
      ];
      final color = colors[i % colors.length];

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
    final seed = 54321;
    final random = math.Random(seed);

    for (int i = 0; i < 150; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final baseStarSize = 0.5 + random.nextDouble() * 1.5;
      final phase = random.nextDouble() * math.pi * 2;
      final twinkleSpeed = 0.2 + random.nextDouble() * 0.3;
      final twinkle =
          0.4 + 0.6 * (0.5 + 0.5 * math.sin(animation * twinkleSpeed + phase));
      final starSize = baseStarSize * (0.8 + 0.2 * twinkle);

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

      canvas.drawCircle(Offset(x, y), starSize, paint..color = starColor);

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
