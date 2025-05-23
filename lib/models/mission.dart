import 'package:cloud_firestore/cloud_firestore.dart';

enum MissionType {
  strength, // Forza (peso, ripetizioni)
  endurance, // Resistenza (serie, durata)
  consistency, // Consistenza (giorni consecutivi)
  volume, // Volume totale
  progression, // Progressione (miglioramento)
}

enum MissionStatus { active, completed, failed, expired }

enum MissionDifficulty { easy, medium, hard, extreme }

class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final MissionDifficulty difficulty;
  final MissionStatus status;
  final int expReward;
  final Map<String, dynamic> requirements; // Requisiti specifici della missione
  final Map<String, dynamic> progress; // Progresso attuale
  final DateTime createdAt;
  final DateTime? completedAt;
  final DateTime expiresAt;
  final String? specificExercise; // Esercizio specifico se necessario

  Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.status,
    required this.expReward,
    required this.requirements,
    required this.progress,
    required this.createdAt,
    this.completedAt,
    required this.expiresAt,
    this.specificExercise,
  });

  factory Mission.fromMap(Map<String, dynamic> data, String id) {
    return Mission(
      id: id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      type: MissionType.values.firstWhere(
        (e) => e.toString() == 'MissionType.${data['type']}',
        orElse: () => MissionType.strength,
      ),
      difficulty: MissionDifficulty.values.firstWhere(
        (e) => e.toString() == 'MissionDifficulty.${data['difficulty']}',
        orElse: () => MissionDifficulty.easy,
      ),
      status: MissionStatus.values.firstWhere(
        (e) => e.toString() == 'MissionStatus.${data['status']}',
        orElse: () => MissionStatus.active,
      ),
      expReward: data['expReward'] ?? 0,
      requirements: Map<String, dynamic>.from(data['requirements'] ?? {}),
      progress: Map<String, dynamic>.from(data['progress'] ?? {}),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      expiresAt:
          (data['expiresAt'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 7)),
      specificExercise: data['specificExercise'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'difficulty': difficulty.toString().split('.').last,
      'status': status.toString().split('.').last,
      'expReward': expReward,
      'requirements': requirements,
      'progress': progress,
      'createdAt': Timestamp.fromDate(createdAt),
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'specificExercise': specificExercise,
    };
  }

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    MissionType? type,
    MissionDifficulty? difficulty,
    MissionStatus? status,
    int? expReward,
    Map<String, dynamic>? requirements,
    Map<String, dynamic>? progress,
    DateTime? createdAt,
    DateTime? completedAt,
    DateTime? expiresAt,
    String? specificExercise,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      status: status ?? this.status,
      expReward: expReward ?? this.expReward,
      requirements: requirements ?? this.requirements,
      progress: progress ?? this.progress,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      expiresAt: expiresAt ?? this.expiresAt,
      specificExercise: specificExercise ?? this.specificExercise,
    );
  }

  // Calcola la percentuale di completamento
  double get completionPercentage {
    if (requirements.isEmpty) return 0.0;

    double totalCompletion = 0.0;
    int totalRequirements = 0;

    requirements.forEach((key, requiredValue) {
      if (progress.containsKey(key)) {
        double currentValue = (progress[key] ?? 0).toDouble();
        double required = requiredValue.toDouble();
        totalCompletion += (currentValue / required).clamp(0.0, 1.0);
      }
      totalRequirements++;
    });

    return totalRequirements > 0 ? totalCompletion / totalRequirements : 0.0;
  }

  // Controlla se la missione è completata
  bool get isCompleted {
    if (requirements.isEmpty) return false;

    bool allRequirementsMet = true;
    requirements.forEach((key, requiredValue) {
      if (!progress.containsKey(key)) {
        allRequirementsMet = false;
        return;
      }
      double currentValue = (progress[key] ?? 0).toDouble();
      double required = requiredValue.toDouble();
      if (currentValue < required) {
        allRequirementsMet = false;
      }
    });

    return allRequirementsMet;
  }

  // Controlla se la missione è scaduta
  bool get isExpired {
    return DateTime.now().isAfter(expiresAt) &&
        status != MissionStatus.completed;
  }
}
