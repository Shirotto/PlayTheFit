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
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

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
  }  @override
  Widget build(BuildContext context) {
    Widget allenamentoTab() {
      if (schedaId == null) {
        return AppComponents.loadingIndicator();
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

    return AppScaffold(
      bottomNavigationBar: _buildNavigationBar(),
      body: Stack(
        children: [
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
        color: AppDesignSystem.darkPrimary,
        boxShadow: [
          BoxShadow(
            color: AppDesignSystem.primary.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: -3,
          ),
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDesignSystem.radiusL),
          topRight: Radius.circular(AppDesignSystem.radiusL),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDesignSystem.radiusL),
          topRight: Radius.circular(AppDesignSystem.radiusL),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onNavItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppDesignSystem.darkPrimary,
          selectedItemColor: AppDesignSystem.primary,
          unselectedItemColor: AppDesignSystem.textTertiary,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: AppDesignSystem.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: AppDesignSystem.primary,
          ),
          unselectedLabelStyle: AppDesignSystem.bodySmall.copyWith(
            color: AppDesignSystem.textTertiary,
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
            BottomNavigationBarItem(
              icon: Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppDesignSystem.primaryButtonGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppDesignSystem.primary.withOpacity(0.4),
                      spreadRadius: 1,
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.fitness_center,
                  color: AppDesignSystem.textPrimary,
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
    );}

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
  }  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(AppDesignSystem.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              user.email?.split('@').first ?? 'Player',
              style: AppDesignSystem.headingLarge.copyWith(
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: AppDesignSystem.primary,
                    offset: const Offset(0, 0),
                  ),
                ],
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          Row(
            children: [              // Pulsante Chat
              AppComponents.iconButton(
                icon: Icons.chat_bubble_outline,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ChatListPage(),
                    ),
                  );
                },
                iconColor: AppDesignSystem.accent,
                tooltip: 'Chat',
              ),
              const SizedBox(width: AppDesignSystem.paddingS),              // Pulsante Notifiche con badge
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
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppDesignSystem.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppDesignSystem.primary.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.notifications_active,
                    color: AppDesignSystem.warning,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: AppDesignSystem.paddingS),
                // Pulsante Amici
              AppComponents.iconButton(
                icon: Icons.people_alt_rounded,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AmiciPage()),
                  );
                },
                iconColor: AppDesignSystem.secondary,
                tooltip: 'Amici',
              ),
              const SizedBox(width: AppDesignSystem.paddingS),
              
              // Livello utente
              StreamBuilder<PlayerLevel>(
                stream: _missionService.getUserLevelStream(),
                builder: (context, snapshot) {
                  final playerLevel = snapshot.data ??
                      PlayerLevel(
                        level: 1,
                        currentExp: 0,
                        expToNextLevel: 100,
                        totalExp: 0,
                      );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDesignSystem.paddingM,
                      vertical: AppDesignSystem.paddingS,
                    ),
                    decoration: BoxDecoration(
                      gradient: AppDesignSystem.primaryButtonGradient,
                      borderRadius: BorderRadius.circular(AppDesignSystem.radiusL),
                      boxShadow: AppDesignSystem.shadowM,
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: AppDesignSystem.warning,
                          size: 20,
                        ),
                        const SizedBox(width: AppDesignSystem.paddingXS),                        Text(
                          "LV ${playerLevel.level}",
                          style: AppDesignSystem.bodyMedium.copyWith(
                            color: AppDesignSystem.textPrimary,
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
          padding: const EdgeInsets.fromLTRB(
            AppDesignSystem.paddingL, 
            AppDesignSystem.paddingXS, 
            AppDesignSystem.paddingL, 
            AppDesignSystem.paddingL
          ),
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppDesignSystem.cardBackgroundSecondary,
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
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
                            colors: [AppDesignSystem.primary, AppDesignSystem.secondary, AppDesignSystem.primary],
                            stops: const [0.0, 0.5, 1.0],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            transform: GradientRotation(
                              _experienceBarAnimation.value * 2 * math.pi,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
                          boxShadow: [
                            BoxShadow(
                              color: AppDesignSystem.primary.withOpacity(
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
                    color: AppDesignSystem.primary.withOpacity(0.3),
                    spreadRadius: 10,
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Image.asset(
                characterAsset,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppDesignSystem.primary,
                    ),
                    child: Icon(
                      Icons.fitness_center,
                      size: 150,
                      color: AppDesignSystem.textPrimary,
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
          padding: const EdgeInsets.symmetric(
            horizontal: AppDesignSystem.paddingL, 
            vertical: AppDesignSystem.paddingL
          ),
          child: AppComponents.standardCard(
            hasPrimaryAccent: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppDesignSystem.paddingS),
                      decoration: BoxDecoration(
                        color: AppDesignSystem.warning.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
                      ),
                      child: Icon(
                        Icons.emoji_events,
                        color: AppDesignSystem.warning,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppDesignSystem.paddingM),
                    Expanded(
                      child: Text(
                        "Sfide Attive",
                        style: AppDesignSystem.headingMedium.copyWith(
                          color: AppDesignSystem.textPrimary,
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
                          horizontal: AppDesignSystem.paddingS,
                          vertical: AppDesignSystem.paddingXS,
                        ),
                        decoration: BoxDecoration(
                          color: AppDesignSystem.success.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
                        ),
                        child: Text(
                          "VEDI TUTTE",
                          style: AppDesignSystem.bodySmall.copyWith(
                            color: AppDesignSystem.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDesignSystem.paddingM),
                Text(
                  "Completa missioni per accumulare ${playerLevel.expToNextLevel} XP e salire al livello ${playerLevel.level + 1}",
                  style: AppDesignSystem.bodyMedium.copyWith(
                    color: AppDesignSystem.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDesignSystem.paddingM),
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
                  child: Stack(
                    children: [
                      LinearProgressIndicator(
                        value: playerLevel.progressPercentage,
                        minHeight: 10,
                        backgroundColor: AppDesignSystem.cardBackgroundSecondary,
                        valueColor: AlwaysStoppedAnimation<Color>(AppDesignSystem.warning),
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
                                      AppDesignSystem.textPrimary.withOpacity(0.2),
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
                const SizedBox(height: AppDesignSystem.paddingS),
                Text(
                  "${playerLevel.currentExp}/${playerLevel.currentExp + playerLevel.expToNextLevel} XP",
                  style: AppDesignSystem.bodySmall.copyWith(
                    color: AppDesignSystem.textTertiary,
                  ),
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
      );    }
  }
}
