import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/mission.dart';
import '../models/player_level.dart';
import '../services/notification_service.dart';
import 'dart:math' as math;

class MissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService = NotificationService();

  User? get currentUser => _auth.currentUser;

  // Stream per ottenere le missioni dell'utente
  Stream<List<Mission>> getUserMissions() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('missions')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => Mission.fromMap(doc.data(), doc.id))
                  .toList(),
        );
  }

  // Ottiene le statistiche dell'utente dalle schede allenamento
  Future<Map<String, dynamic>> getUserWorkoutStats() async {
    if (currentUser == null) return {};

    try {
      // Ottieni tutte le schede dell'utente
      final schedeSnapshot =
          await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('schede')
              .get();
      Map<String, int> exerciseCount = {};
      Map<String, double> totalWeight = {};
      Map<String, dynamic> totalSets = {};
      Map<String, dynamic> totalReps = {};
      int completedExercises = 0;
      int totalExercises = 0;
      Set<String> workoutDays = {};

      for (var schedaDoc in schedeSnapshot.docs) {
        // Ottieni tutti gli esercizi di questa scheda
        final eserciziSnapshot =
            await schedaDoc.reference.collection('esercizi').get();

        for (var esercizioDoc in eserciziSnapshot.docs) {
          final data = esercizioDoc.data();
          final nome = data['nome'] ?? 'Sconosciuto';
          final serie = data['serie'] ?? 0;
          final ripetizioni = data['ripetizioni'] ?? 0;
          final peso = data['peso'] ?? '0';
          final completato = data['completato'] ?? false;

          totalExercises++;
          if (completato) completedExercises++;

          // Conta gli esercizi per tipo
          exerciseCount[nome] = (exerciseCount[nome] ?? 0) + 1;

          // Somma serie e ripetizioni
          totalSets[nome] = (totalSets[nome] ?? 0) + serie;
          totalReps[nome] = (totalReps[nome] ?? 0) + (serie * ripetizioni);

          // Calcola peso totale (se numerico)
          try {
            double pesoValue = double.parse(
              peso.toString().replaceAll(RegExp(r'[^0-9.]'), ''),
            );
            totalWeight[nome] =
                (totalWeight[nome] ?? 0) + (pesoValue * serie * ripetizioni);
          } catch (e) {
            // Ignora se il peso non è numerico
          }
        }

        // Aggiungi il giorno di allenamento (usando la data di creazione)
        final createdAt = schedaDoc.data()['data_creazione'] as Timestamp?;
        if (createdAt != null) {
          final date = createdAt.toDate();
          workoutDays.add('${date.year}-${date.month}-${date.day}');
        }
      }

      return {
        'exerciseCount': exerciseCount,
        'totalWeight': totalWeight,
        'totalSets': totalSets,
        'totalReps': totalReps,
        'completedExercises': completedExercises,
        'totalExercises': totalExercises,
        'workoutDays': workoutDays.length,
        'favoriteExercise':
            exerciseCount.entries
                .fold<MapEntry<String, int>?>(
                  null,
                  (prev, current) =>
                      prev == null || current.value > prev.value
                          ? current
                          : prev,
                )
                ?.key,
      };
    } catch (e) {
      print('Errore nel calcolare le statistiche: $e');
      return {};
    }
  }

  // Genera missioni basate sull'AI (simulata) usando le statistiche dell'utente
  Future<List<Mission>> generateAIMissions() async {
    if (currentUser == null) return [];

    final stats = await getUserWorkoutStats();
    final random = math.Random();
    final now = DateTime.now();

    List<Mission> newMissions = [];

    // 1. Missione di Consistenza
    newMissions.add(
      Mission(
        id: '',
        title: '🔥 Settimana di Fuoco',
        description: 'Completa almeno 4 allenamenti questa settimana',
        type: MissionType.consistency,
        difficulty: MissionDifficulty.medium,
        status: MissionStatus.active,
        expReward: 150,
        requirements: {'workouts': 4},
        progress: {'workouts': 0},
        createdAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      ),
    );

    // 2. Missione di Volume basata sulle statistiche
    final totalReps = stats['totalReps'] as Map<String, int>? ?? {};
    final avgReps =
        totalReps.values.isEmpty
            ? 50
            : totalReps.values.reduce((a, b) => a + b) ~/ totalReps.length;

    newMissions.add(
      Mission(
        id: '',
        title: '💪 Volume Challenge',
        description:
            'Raggiungi ${avgReps * 2} ripetizioni totali in una sessione',
        type: MissionType.volume,
        difficulty: MissionDifficulty.medium,
        status: MissionStatus.active,
        expReward: 100,
        requirements: {'totalReps': avgReps * 2},
        progress: {'totalReps': 0},
        createdAt: now,
        expiresAt: now.add(const Duration(days: 5)),
      ),
    );

    // 3. Missione per esercizio specifico
    final favoriteExercise = stats['favoriteExercise'] as String?;
    if (favoriteExercise != null) {
      newMissions.add(
        Mission(
          id: '',
          title: '🎯 Maestria in $favoriteExercise',
          description:
              'Completa 5 serie di $favoriteExercise con tecnica perfetta',
          type: MissionType.strength,
          difficulty: MissionDifficulty.easy,
          status: MissionStatus.active,
          expReward: 75,
          requirements: {'sets': 5},
          progress: {'sets': 0},
          createdAt: now,
          expiresAt: now.add(const Duration(days: 3)),
          specificExercise: favoriteExercise,
        ),
      );
    }

    // 4. Missione di Progressione
    newMissions.add(
      Mission(
        id: '',
        title: '📈 Superamento dei Limiti',
        description:
            'Aumenta il peso o le ripetizioni in almeno 3 esercizi diversi',
        type: MissionType.progression,
        difficulty: MissionDifficulty.hard,
        status: MissionStatus.active,
        expReward: 200,
        requirements: {'improvedExercises': 3},
        progress: {'improvedExercises': 0},
        createdAt: now,
        expiresAt: now.add(const Duration(days: 10)),
      ),
    );

    // 5. Missione random per varietà
    final randomMissions = [
      Mission(
        id: '',
        title: '⚡ Power Hour',
        description: 'Completa un allenamento in meno di 45 minuti',
        type: MissionType.endurance,
        difficulty: MissionDifficulty.medium,
        status: MissionStatus.active,
        expReward: 120,
        requirements: {'duration': 45},
        progress: {'duration': 0},
        createdAt: now,
        expiresAt: now.add(const Duration(days: 4)),
      ),
      Mission(
        id: '',
        title: '🏃 Endurance Master',
        description: 'Completa 15 serie totali in una sessione',
        type: MissionType.endurance,
        difficulty: MissionDifficulty.hard,
        status: MissionStatus.active,
        expReward: 180,
        requirements: {'totalSets': 15},
        progress: {'totalSets': 0},
        createdAt: now,
        expiresAt: now.add(const Duration(days: 6)),
      ),
    ];

    newMissions.add(randomMissions[random.nextInt(randomMissions.length)]);

    return newMissions;
  }

  // Salva le missioni generate nel database
  Future<void> saveGeneratedMissions(List<Mission> missions) async {
    if (currentUser == null) return;

    final batch = _firestore.batch();
    final userMissionsRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('missions');

    for (final mission in missions) {
      final docRef = userMissionsRef.doc();
      batch.set(docRef, mission.toMap());
    }

    await batch.commit();
  }

  // Aggiorna il progresso di una missione
  Future<void> updateMissionProgress(
    String missionId,
    Map<String, dynamic> newProgress,
  ) async {
    if (currentUser == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('missions')
          .doc(missionId)
          .update({'progress': newProgress});
    } catch (e) {
      print('Errore nell\'aggiornare il progresso della missione: $e');
    }
  }

  // Completa una missione e assegna esperienza
  Future<bool> completeMission(String missionId) async {
    if (currentUser == null) return false;

    try {
      final missionDoc =
          await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('missions')
              .doc(missionId)
              .get();

      if (!missionDoc.exists) return false;

      final mission = Mission.fromMap(missionDoc.data()!, missionDoc.id);

      // Verifica se la missione può essere completata
      if (!mission.isCompleted || mission.status == MissionStatus.completed) {
        return false;
      }

      // Aggiorna lo stato della missione
      await missionDoc.reference.update({
        'status': MissionStatus.completed.toString().split('.').last,
        'completedAt': FieldValue.serverTimestamp(),
      });

      // Aggiungi esperienza all'utente
      await addExperienceToUser(mission.expReward);

      return true;
    } catch (e) {
      print('Errore nel completare la missione: $e');
      return false;
    }
  }

  // Aggiunge esperienza all'utente
  Future<PlayerLevel?> addExperienceToUser(int expGained) async {
    if (currentUser == null) return null;

    try {
      final userRef = _firestore.collection('users').doc(currentUser!.uid);
      final userDoc = await userRef.get();

      final currentData = userDoc.data() ?? {};
      final currentLevel = PlayerLevel.fromMap(currentData);
      final newLevel = currentLevel.addExp(expGained);

      // Controlla se c'è stato un level up
      final hasLeveledUp = newLevel.level > currentLevel.level;

      await userRef.update(newLevel.toMap());

      // Se c'è stato un level up, mostra una notifica e ricompense
      if (hasLeveledUp) {
        await _handleLevelUp(currentLevel.level, newLevel.level);
      }

      return newLevel;
    } catch (e) {
      print('Errore nell\'aggiungere esperienza: $e');
      return null;
    }
  }

  // Gestisce l'evento di level up
  Future<void> _handleLevelUp(int oldLevel, int newLevel) async {
    try {
      // Ottieni le ricompense sbloccate
      final rewardsMap = LevelRewards.getLevelRewards(newLevel);
      final rewards = rewardsMap[newLevel] ?? [];

      // Mostra la notifica usando l'istanza della classe
      await _notificationService.showLevelUpNotification(
        newLevel: newLevel,
        rewards: rewards,
      );

      // Salva le ricompense di livello nel profilo dell'utente
      if (rewards.isNotEmpty) {
        await _firestore.collection('users').doc(currentUser!.uid).update({
          'rewards': FieldValue.arrayUnion(rewards),
          'lastLevelUpDate': FieldValue.serverTimestamp(),
        });
      }

      print('Level Up! Da $oldLevel a $newLevel con ricompense: $rewards');
    } catch (e) {
      print('Errore nella gestione del level up: $e');
    }
  }

  // Ottiene il livello attuale dell'utente
  Future<PlayerLevel> getUserLevel() async {
    if (currentUser == null)
      return PlayerLevel(
        level: 1,
        currentExp: 0,
        expToNextLevel: 100,
        totalExp: 0,
      );

    try {
      final userDoc =
          await _firestore.collection('users').doc(currentUser!.uid).get();

      if (userDoc.exists) {
        return PlayerLevel.fromMap(userDoc.data()!);
      }
    } catch (e) {
      print('Errore nel caricare il livello utente: $e');
    }

    return PlayerLevel(
      level: 1,
      currentExp: 0,
      expToNextLevel: 100,
      totalExp: 0,
    );
  }

  // Stream per il livello utente
  Stream<PlayerLevel> getUserLevelStream() {
    if (currentUser == null) {
      return Stream.value(
        PlayerLevel(level: 1, currentExp: 0, expToNextLevel: 100, totalExp: 0),
      );
    }

    return _firestore.collection('users').doc(currentUser!.uid).snapshots().map(
      (snapshot) {
        if (snapshot.exists) {
          return PlayerLevel.fromMap(snapshot.data()!);
        }
        return PlayerLevel(
          level: 1,
          currentExp: 0,
          expToNextLevel: 100,
          totalExp: 0,
        );
      },
    );
  }

  // Genera nuove missioni se necessario (chiamato automaticamente)
  Future<void> checkAndGenerateNewMissions() async {
    if (currentUser == null) return;

    try {
      // Controlla quante missioni attive ha l'utente
      final activeMissions =
          await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('missions')
              .where('status', isEqualTo: 'active')
              .get();

      // Se ha meno di 3 missioni attive, genera nuove missioni
      if (activeMissions.docs.length < 3) {
        final newMissions = await generateAIMissions();
        // Prendi solo il numero necessario per arrivare a 5 missioni totali
        final missionsToAdd =
            newMissions.take(5 - activeMissions.docs.length).toList();
        if (missionsToAdd.isNotEmpty) {
          await saveGeneratedMissions(missionsToAdd);
        }
      }
    } catch (e) {
      print('Errore nel generare nuove missioni: $e');
    }
  }

  // Aggiorna automaticamente il progresso delle missioni basato su un allenamento completato
  Future<void> updateMissionProgressFromWorkout(
    List<Map<String, dynamic>> completedExercises,
  ) async {
    if (currentUser == null || completedExercises.isEmpty) return;

    try {
      // Ottieni tutte le missioni attive
      final activeMissionsSnapshot =
          await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('missions')
              .where('status', isEqualTo: 'active')
              .get();

      for (final missionDoc in activeMissionsSnapshot.docs) {
        final mission = Mission.fromMap(missionDoc.data(), missionDoc.id);
        Map<String, dynamic> updatedProgress = Map.from(mission.progress);
        bool progressChanged = false;

        // Aggiorna il progresso basato sul tipo di missione
        switch (mission.type) {
          case MissionType.volume:
            int totalReps = completedExercises.fold(
              0,
              (sum, exercise) =>
                  sum +
                          ((exercise['serie'] ?? 0) *
                              (exercise['ripetizioni'] ?? 0))
                      as int,
            );
            if (updatedProgress.containsKey('totalReps')) {
              updatedProgress['totalReps'] =
                  (updatedProgress['totalReps'] ?? 0) + totalReps;
              progressChanged = true;
            }
            break;

          case MissionType.consistency:
            if (updatedProgress.containsKey('workouts')) {
              updatedProgress['workouts'] =
                  (updatedProgress['workouts'] ?? 0) + 1;
              progressChanged = true;
            }
            break;

          case MissionType.strength:
            if (mission.specificExercise != null) {
              final specificExercises =
                  completedExercises
                      .where((ex) => ex['nome'] == mission.specificExercise)
                      .toList();

              if (specificExercises.isNotEmpty &&
                  updatedProgress.containsKey('sets')) {
                int completedSets = specificExercises.fold(
                  0,
                  (sum, ex) => sum + (ex['serie'] ?? 0) as int,
                );
                updatedProgress['sets'] =
                    (updatedProgress['sets'] ?? 0) + completedSets;
                progressChanged = true;
              }
            }
            break;

          case MissionType.endurance:
            if (updatedProgress.containsKey('totalSets')) {
              int totalSets = completedExercises.fold(
                0,
                (sum, exercise) => sum + (exercise['serie'] ?? 0) as int,
              );
              updatedProgress['totalSets'] =
                  (updatedProgress['totalSets'] ?? 0) + totalSets;
              progressChanged = true;
            }
            break;

          case MissionType.progression:
            // Questo richiede logica più complessa per tracciare i miglioramenti
            // Per ora semplifichiamo
            break;
        }

        // Salva il progresso aggiornato se è cambiato
        if (progressChanged) {
          await updateMissionProgress(mission.id, updatedProgress);
        }
      }
    } catch (e) {
      print('Errore nell\'aggiornare il progresso delle missioni: $e');
    }
  }
}
