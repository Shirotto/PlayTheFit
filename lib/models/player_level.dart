// filepath: c:\Users\anton\Desktop\PlayTheFit\lib\models\player_level.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math' as math;

class PlayerLevel {
  final int level;
  final int currentExp;
  final int expToNextLevel;
  final int totalExp;

  PlayerLevel({
    required this.level,
    required this.currentExp,
    required this.expToNextLevel,
    required this.totalExp,
  });

  factory PlayerLevel.fromMap(Map<String, dynamic> data) {
    final level = data['level'] ?? 1;
    final totalExp = data['totalExp'] ?? 0;
    final expToNextLevel = calculateExpForLevel(level + 1);
    final expForCurrentLevel = calculateExpForLevel(level);
    final currentExp = totalExp - expForCurrentLevel;

    return PlayerLevel(
      level: level,
      currentExp: currentExp,
      expToNextLevel: (expToNextLevel - totalExp).toInt(),
      totalExp: totalExp,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'totalExp': totalExp,
      'lastUpdated': FieldValue.serverTimestamp(),
    };
  }

  // Formula per calcolare l'esperienza necessaria per un dato livello
  // Usa una progressione esponenziale: exp = 100 * level^1.5
  static int calculateExpForLevel(int level) {
    if (level <= 1) return 0;
    return (100 * math.pow(level, 1.5)).round();
  }

  // Calcola il livello basato sull'esperienza totale
  static int calculateLevelFromExp(int totalExp) {
    int level = 1;
    while (calculateExpForLevel(level + 1) <= totalExp) {
      level++;
    }
    return level;
  }

  // Aggiunge esperienza e restituisce il nuovo PlayerLevel
  PlayerLevel addExp(int expGained) {
    final newTotalExp = totalExp + expGained;
    final newLevel = calculateLevelFromExp(newTotalExp);

    return PlayerLevel(
      level: newLevel,
      currentExp: newTotalExp - calculateExpForLevel(newLevel),
      expToNextLevel: calculateExpForLevel(newLevel + 1) - newTotalExp,
      totalExp: newTotalExp,
    );
  }

  // Restituisce la progressione come percentuale (0.0 - 1.0)
  double get progressPercentage {
    if (expToNextLevel <= 0) return 1.0;
    final expForThisLevel =
        calculateExpForLevel(level + 1) - calculateExpForLevel(level);
    return currentExp / expForThisLevel;
  }

  // Controlla se c'� stato un level up
  bool hasLeveledUp(PlayerLevel previous) {
    return level > previous.level;
  }
}

class LevelRewards {
  static Map<int, List<String>> getLevelRewards(int level) {
    final rewards = <String>[];

    // Ricompense ogni 5 livelli
    if (level % 5 == 0) {
      rewards.add(' Titolo speciale sbloccato!');
    }

    // Ricompense ogni 10 livelli
    if (level % 10 == 0) {
      rewards.add(' Nuove opzioni personalizzazione!');
      rewards.add(' Badge di prestigio!');
    }

    // Ricompense per livelli specifici
    switch (level) {
      case 5:
        rewards.add(' Primo milestone raggiunto!');
        break;
      case 10:
        rewards.add(' Atleta dedicato!');
        break;
      case 25:
        rewards.add(' Warrior del fitness!');
        break;
      case 50:
        rewards.add(' Leggenda della palestra!');
        break;
      case 100:
        rewards.add(' Maestro supremo!');
        break;
    }

    return {level: rewards};
  }
}
