import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/mission.dart';
import '../models/player_level.dart';
import '../services/mission_service.dart';

class MissioniPage extends StatefulWidget {
  const MissioniPage({super.key});

  @override
  State<MissioniPage> createState() => _MissioniPageState();
}

class _MissioniPageState extends State<MissioniPage>
    with SingleTickerProviderStateMixin {
  final MissionService _missionService = MissionService();
  late AnimationController _animationController;
  bool _isGeneratingMissions = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Genera missioni all'avvio se necessario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _missionService.checkAndGenerateNewMissions();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _generateNewMissions() async {
    setState(() {
      _isGeneratingMissions = true;
    });

    try {
      final newMissions = await _missionService.generateAIMissions();
      await _missionService.saveGeneratedMissions(newMissions);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${newMissions.length} nuove missioni generate!'),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore nella generazione delle missioni: $e'),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingMissions = false;
        });
      }
    }
  }

  Future<void> _completeMission(Mission mission) async {
    if (!mission.isCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Missione non ancora completata!'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final success = await _missionService.completeMission(mission.id);

    if (success && mounted) {
      // Mostra dialog di ricompensa
      _showRewardDialog(mission);
    }
  }

  void _showRewardDialog(Mission mission) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.blue.shade900.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Row(
              children: [
                const Icon(Icons.celebration, color: Colors.amber, size: 30),
                const SizedBox(width: 10),
                Text(
                  'Missione Completata!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(color: Colors.blue.shade400, blurRadius: 5),
                    ],
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  mission.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.amber, width: 2),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 25),
                      const SizedBox(width: 8),
                      Text(
                        '+${mission.expReward} EXP',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Fantastico!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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

          // Animazione stelle
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return CustomPaint(
                painter: StarfieldPainter(
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
                _buildHeader(),
                _buildLevelInfo(),
                Expanded(child: _buildMissionsList()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '⚔️ MISSIONI',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.blue.shade400, blurRadius: 10),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Completa le missioni per guadagnare EXP',
                  style: TextStyle(fontSize: 14, color: Colors.blue.shade100),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _isGeneratingMissions ? null : _generateNewMissions,
            icon:
                _isGeneratingMissions
                    ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Icon(Icons.auto_awesome, color: Colors.white),
            label: Text(
              _isGeneratingMissions ? 'Generando...' : 'Nuove Missioni',
              style: const TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelInfo() {
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

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade800, Colors.purple.shade800],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.amber, width: 2),
                        ),
                        child: const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Livello ${playerLevel.level}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${playerLevel.currentExp} / ${playerLevel.currentExp + playerLevel.expToNextLevel} EXP',
                    style: TextStyle(color: Colors.blue.shade100, fontSize: 14),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: playerLevel.progressPercentage,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                minHeight: 8,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMissionsList() {
    return StreamBuilder<List<Mission>>(
      stream: _missionService.getUserMissions(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final missions = snapshot.data ?? [];

        if (missions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.assignment,
                  size: 80,
                  color: Colors.blue.shade300.withOpacity(0.7),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nessuna missione disponibile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Genera nuove missioni usando il pulsante in alto',
                  style: TextStyle(color: Colors.grey[300]),
                  textAlign: TextAlign.center,
                ),

                // Debug controls section
                const SizedBox(height: 40),
                _buildDebugControls(),
              ],
            ),
          );
        }

        // Separa le missioni per stato
        final activeMissions =
            missions
                .where((m) => m.status == MissionStatus.active && !m.isExpired)
                .toList();
        final completedMissions =
            missions.where((m) => m.status == MissionStatus.completed).toList();
        final expiredMissions =
            missions
                .where(
                  (m) => m.isExpired && m.status != MissionStatus.completed,
                )
                .toList();

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (activeMissions.isNotEmpty) ...[
              _buildSectionHeader('🎯 Missioni Attive', activeMissions.length),
              ...activeMissions.map((mission) => _buildMissionCard(mission)),
              const SizedBox(height: 20),
            ],
            if (completedMissions.isNotEmpty) ...[
              _buildSectionHeader('✅ Completate', completedMissions.length),
              ...completedMissions.map((mission) => _buildMissionCard(mission)),
              const SizedBox(height: 20),
            ],
            if (expiredMissions.isNotEmpty) ...[
              _buildSectionHeader('⏰ Scadute', expiredMissions.length),
              ...expiredMissions.map((mission) => _buildMissionCard(mission)),
            ],

            // Debug controls always visible at the bottom
            _buildDebugControls(),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  // Debug controls for testing level-up system
  Widget _buildDebugControls() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 20),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            '🛠️ STRUMENTI DI TEST',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),

          // Add experience button
          ElevatedButton.icon(
            onPressed: () async {
              final result = await _missionService.addExperienceToUser(100);
              if (result != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aggiunti 100 XP! Livello attuale: ${result.level}',
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add_circle, color: Colors.white),
            label: const Text(
              'Aggiungi 100 XP',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),

          const SizedBox(height: 10),

          // Level up button
          ElevatedButton.icon(
            onPressed: () async {
              final currentLevel = await _missionService.getUserLevel();
              final neededExp = currentLevel.expToNextLevel;
              final result = await _missionService.addExperienceToUser(
                neededExp,
              );
              if (result != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Level UP! Nuovo livello: ${result.level}'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: const Icon(Icons.arrow_circle_up, color: Colors.white),
            label: const Text(
              'Sali di Livello',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple.shade600,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.blue.shade300,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.blue.shade700,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$count',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionCard(Mission mission) {
    final isCompleted = mission.status == MissionStatus.completed;
    final isExpired = mission.isExpired;
    final canComplete = mission.isCompleted && !isCompleted && !isExpired;

    Color cardColor = Colors.blue.shade900;
    Color borderColor = Colors.blue.shade400;

    if (isCompleted) {
      cardColor = Colors.green.shade900;
      borderColor = Colors.green.shade400;
    } else if (isExpired) {
      cardColor = Colors.red.shade900;
      borderColor = Colors.red.shade400;
    } else if (canComplete) {
      cardColor = Colors.amber.shade900;
      borderColor = Colors.amber.shade400;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [cardColor, cardColor.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: borderColor.withOpacity(0.5), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: borderColor.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: _getDifficultyColor(
                      mission.difficulty,
                    ).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _getDifficultyColor(mission.difficulty),
                    ),
                  ),
                  child: Icon(
                    _getMissionTypeIcon(mission.type),
                    color: _getDifficultyColor(mission.difficulty),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        mission.title,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration:
                              isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      Text(
                        _getDifficultyText(mission.difficulty),
                        style: TextStyle(
                          color: _getDifficultyColor(mission.difficulty),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle, color: Colors.green, size: 24)
                else if (isExpired)
                  const Icon(Icons.access_time, color: Colors.red, size: 24)
                else if (canComplete)
                  const Icon(Icons.celebration, color: Colors.amber, size: 24),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              mission.description,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Barra di progresso
            if (!isCompleted && !isExpired) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Progresso: ${(mission.completionPercentage * 100).toInt()}%',
                    style: TextStyle(color: Colors.blue.shade100, fontSize: 12),
                  ),
                  Text(
                    '${mission.expReward} EXP',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: mission.completionPercentage,
                backgroundColor: Colors.white.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  canComplete ? Colors.amber : Colors.blue.shade400,
                ),
                minHeight: 6,
              ),
            ],

            // Dettagli progresso
            if (mission.requirements.isNotEmpty) ...[
              const SizedBox(height: 12),
              ...mission.requirements.entries.map((entry) {
                final current = mission.progress[entry.key] ?? 0;
                final required = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _getRequirementText(entry.key),
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '$current / $required',
                        style: TextStyle(
                          color:
                              current >= required
                                  ? Colors.green
                                  : Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],

            // Pulsante completamento
            if (canComplete) ...[
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _completeMission(mission),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text(
                    'Riscuoti Ricompensa!',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],

            // Data di scadenza
            if (!isCompleted) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: isExpired ? Colors.red : Colors.white60,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isExpired
                        ? 'Scaduta'
                        : 'Scade il ${_formatDate(mission.expiresAt)}',
                    style: TextStyle(
                      color: isExpired ? Colors.red : Colors.white60,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getDifficultyColor(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return Colors.green;
      case MissionDifficulty.medium:
        return Colors.orange;
      case MissionDifficulty.hard:
        return Colors.red;
      case MissionDifficulty.extreme:
        return Colors.purple;
    }
  }

  String _getDifficultyText(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.easy:
        return 'FACILE';
      case MissionDifficulty.medium:
        return 'MEDIO';
      case MissionDifficulty.hard:
        return 'DIFFICILE';
      case MissionDifficulty.extreme:
        return 'ESTREMO';
    }
  }

  IconData _getMissionTypeIcon(MissionType type) {
    switch (type) {
      case MissionType.strength:
        return Icons.fitness_center;
      case MissionType.endurance:
        return Icons.timer;
      case MissionType.consistency:
        return Icons.calendar_today;
      case MissionType.volume:
        return Icons.trending_up;
      case MissionType.progression:
        return Icons.show_chart;
    }
  }

  String _getRequirementText(String key) {
    switch (key) {
      case 'workouts':
        return 'Allenamenti';
      case 'totalReps':
        return 'Ripetizioni totali';
      case 'sets':
        return 'Serie';
      case 'totalSets':
        return 'Serie totali';
      case 'improvedExercises':
        return 'Esercizi migliorati';
      case 'duration':
        return 'Durata (min)';
      default:
        return key;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// Painter per le stelle di sfondo
class StarfieldPainter extends CustomPainter {
  final double animation;

  StarfieldPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeCap = StrokeCap.round;
    final random = math.Random(42); // Seed fisso per stelle consistenti

    for (int i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;

      final starSize = 0.5 + random.nextDouble() * 2;
      final twinkle =
          0.3 + 0.7 * (0.5 + 0.5 * math.sin(animation * 2 * math.pi + i));

      paint.color = Colors.white.withOpacity(0.4 * twinkle);
      canvas.drawCircle(Offset(x, y), starSize, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
