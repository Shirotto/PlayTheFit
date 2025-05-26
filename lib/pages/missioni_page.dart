import 'package:flutter/material.dart';
import '../models/mission.dart';
import '../models/player_level.dart';
import '../services/mission_service.dart';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';

class MissioniPage extends StatefulWidget {
  const MissioniPage({super.key});

  @override
  State<MissioniPage> createState() => _MissioniPageState();
}

class _MissioniPageState extends State<MissioniPage>
    with SingleTickerProviderStateMixin {
  final MissionService _missionService = MissionService();
  late AnimationController _animationController;
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();

    // Le missioni vengono ora generate automaticamente solo quando si crea una nuova scheda
    // Non generiamo più missioni all'avvio della pagina per evitare sovraccarico
  }
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
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
      builder: (context) => AlertDialog(
        backgroundColor: AppDesignSystem.darkSecondary.withOpacity(0.95),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusL),
        ),
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppDesignSystem.warning, size: 30),
            SizedBox(width: AppDesignSystem.paddingS),
            Text(
              'Missione Completata!',
              style: AppDesignSystem.headingMedium.copyWith(
                shadows: [
                  Shadow(color: AppDesignSystem.primary, blurRadius: 5),
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
              style: AppDesignSystem.headingSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppDesignSystem.paddingM),
            Container(
              padding: EdgeInsets.all(AppDesignSystem.paddingM),
              decoration: BoxDecoration(
                color: AppDesignSystem.warning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
                border: Border.all(color: AppDesignSystem.warning, width: 2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.star, color: AppDesignSystem.warning, size: 25),
                  SizedBox(width: AppDesignSystem.paddingS),
                  Text(
                    '+${mission.expReward} EXP',
                    style: AppDesignSystem.headingSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          AppComponents.successButton(
            text: 'Fantastico!',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildLevelInfo(),
          Expanded(child: _buildMissionsList()),
        ],
      ),
    );
  }  Widget _buildHeader() {
    return AppComponents.pageHeader(
      title: '⚔️ MISSIONI',
      subtitle: 'Completa le missioni per guadagnare EXP',
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
            );        return AppComponents.standardCard(
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
                          color: AppDesignSystem.warning.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppDesignSystem.warning, width: 2),
                        ),
                        child: Icon(
                          Icons.star,
                          color: AppDesignSystem.warning,
                          size: 20,
                        ),
                      ),
                      SizedBox(width: AppDesignSystem.paddingM),
                      Text(
                        'Livello ${playerLevel.level}',
                        style: AppDesignSystem.headingSmall,
                      ),
                    ],
                  ),
                  Text(
                    '${playerLevel.currentExp} / ${playerLevel.currentExp + playerLevel.expToNextLevel} EXP',
                    style: AppDesignSystem.bodySmall.copyWith(color: AppDesignSystem.textSecondary),
                  ),
                ],
              ),
              SizedBox(height: AppDesignSystem.paddingM),
              LinearProgressIndicator(
                value: playerLevel.progressPercentage,
                backgroundColor: AppDesignSystem.textSecondary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(AppDesignSystem.warning),
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
      builder: (context, snapshot) {        if (snapshot.connectionState == ConnectionState.waiting) {
          return AppComponents.loadingIndicator();
        }

        final missions = snapshot.data ?? [];        if (missions.isEmpty) {
          return AppComponents.emptyState(
            icon: Icons.assignment,
            title: 'Nessuna missione disponibile',
            subtitle: 'Non ci sono missioni al momento, completa il primo allenamento per generare nuove missioni',
            action: Column(
              children: [
                SizedBox(height: AppDesignSystem.paddingXL),
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
  }  // Debug controls for testing level-up system
  Widget _buildDebugControls() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppDesignSystem.paddingL),
      padding: const EdgeInsets.all(AppDesignSystem.paddingM),
      decoration: BoxDecoration(
        color: AppDesignSystem.error.withOpacity(0.1),
        border: Border.all(color: AppDesignSystem.error.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            '🛠️ STRUMENTI DI TEST',
            style: AppDesignSystem.headingSmall.copyWith(
              color: AppDesignSystem.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppDesignSystem.paddingM),

          // Add experience button
          AppComponents.primaryButton(
            text: 'Aggiungi 100 XP',
            onPressed: () async {
              final result = await _missionService.addExperienceToUser(100);
              if (result != null && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Aggiunti 100 XP! Livello attuale: ${result.level}',
                    ),
                    backgroundColor: AppDesignSystem.success,
                  ),
                );
              }
            },
            icon: Icons.add_circle,
            fullWidth: true,
          ),

          SizedBox(height: AppDesignSystem.paddingM),

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
                    backgroundColor: AppDesignSystem.success,
                  ),
                );
              }
            },
            icon: Icon(Icons.arrow_circle_up, color: AppDesignSystem.textPrimary),
            label: Text(
              'Sali di Livello',
              style: AppDesignSystem.bodyMedium.copyWith(
                color: AppDesignSystem.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppDesignSystem.secondary,
              padding: const EdgeInsets.symmetric(
                horizontal: AppDesignSystem.paddingL,
                vertical: AppDesignSystem.paddingM,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDesignSystem.paddingM),
      child: Row(
        children: [
          Text(
            title,
            style: AppDesignSystem.headingMedium.copyWith(
              color: AppDesignSystem.primary,
            ),
          ),
          SizedBox(width: AppDesignSystem.paddingS),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppDesignSystem.paddingS,
              vertical: AppDesignSystem.paddingXS,
            ),
            decoration: BoxDecoration(
              color: AppDesignSystem.primary,
              borderRadius: BorderRadius.circular(AppDesignSystem.radiusS),
            ),
            child: Text(
              '$count',
              style: AppDesignSystem.bodySmall.copyWith(
                color: AppDesignSystem.textPrimary,
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

    // Determina colore e icona dello stato
    Color statusColor = AppDesignSystem.primary;
    IconData statusIcon = _getMissionTypeIcon(mission.type);
    
    if (isCompleted) {
      statusColor = AppDesignSystem.success;
      statusIcon = Icons.check_circle;
    } else if (isExpired) {
      statusColor = AppDesignSystem.error;
      statusIcon = Icons.access_time;
    } else if (canComplete) {
      statusColor = AppDesignSystem.warning;
      statusIcon = Icons.celebration;
    } else {
      statusColor = _getDifficultyColor(mission.difficulty);
      statusIcon = _getMissionTypeIcon(mission.type);
    }

    return AppComponents.missionCard(
      title: mission.title,
      description: mission.description,
      progress: mission.completionPercentage,
      statusColor: statusColor,
      statusIcon: statusIcon,
      reward: '${mission.expReward} EXP',
      actionButton: canComplete ? AppComponents.successButton(
        text: 'Riscuoti Ricompensa!',
        onPressed: () => _completeMission(mission),
        icon: Icons.check,
        fullWidth: true,
      ) : null,
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
}
