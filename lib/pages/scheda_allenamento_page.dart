import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/esercizio.dart';
import '../services/mission_service.dart';
import '../theme/app_design_system.dart';
import '../widgets/app_components.dart';
import '../widgets/app_background.dart';
import 'home_screen.dart'; // Assicurati di importare la HomeScreen

class SchedaAllenamentoPage extends StatefulWidget {
  final String schedaId;
  const SchedaAllenamentoPage({super.key, required this.schedaId});

  @override
  State<SchedaAllenamentoPage> createState() => _SchedaAllenamentoPageState();
}

class _SchedaAllenamentoPageState extends State<SchedaAllenamentoPage>
    with SingleTickerProviderStateMixin {
  List<Esercizio> esercizi = [];

  late AnimationController _particleAnimationController;
  final MissionService _missionService = MissionService();

  @override
  void initState() {
    super.initState();
    caricaScheda();
    caricaScheda();
    // Impostazione identica a HomeScreen: un minuto per ciclo
    _particleAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
  }

  @override
  void dispose() {
    _particleAnimationController.dispose();
    super.dispose();
  }

  void toggleCompletato(int index) {
    setState(() {
      esercizi[index].completato = !esercizi[index].completato;
    });
    salvaEserciziSuFirestore();
  }

  void eliminaEsercizio(int index) {
    setState(() {
      esercizi.removeAt(index);
    });
    salvaEserciziSuFirestore();
  }

  Future<void> caricaScheda() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final snapshot =
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('schede')
            .doc(widget.schedaId)
            .collection('esercizi')
            .get();

    final eserciziCaricati =
        snapshot.docs.map((doc) {
          final data = doc.data();
          return Esercizio(
            data['nome'],
            data['serie'],
            data['ripetizioni'],
            data['peso'],
            data['recupero'],
            data['completato'] ?? false,
          );
        }).toList();

    setState(() {
      esercizi = eserciziCaricati;
    });
  }

  void mostraDialogEsercizio({Esercizio? esercizio, int? index}) {
    final nomeController = TextEditingController(text: esercizio?.nome ?? "");
    final serieController = TextEditingController(
      text: esercizio?.serie.toString() ?? "3",
    );
    final ripetizioniController = TextEditingController(
      text: esercizio?.ripetizioni.toString() ?? "10",
    );
    final pesoController = TextEditingController(text: esercizio?.peso ?? "");
    final recuperoController = TextEditingController(
      text: esercizio?.recupero ?? "",
    );    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppDesignSystem.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDesignSystem.radiusL),
        ),
        title: Text(
          esercizio == null ? "Aggiungi Esercizio" : "Modifica Esercizio",
          style: AppDesignSystem.headingSmall.copyWith(
            color: AppDesignSystem.textPrimary,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(nomeController, "Nome", Icons.fitness_center),
              _buildTextField(
                serieController,
                "Serie",
                Icons.repeat,
                isNumeric: true,
              ),
              _buildTextField(
                ripetizioniController,
                "Ripetizioni",
                Icons.format_list_numbered,
                isNumeric: true,
              ),
              _buildTextField(pesoController, "Peso", Icons.fitness_center),
              _buildTextField(recuperoController, "Recupero", Icons.timer),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppDesignSystem.textSecondary,
            ),
            child: const Text("Annulla"),
          ),
          AppComponents.successButton(
            text: "Salva",
            onPressed: () {
              final nuovo = Esercizio(
                nomeController.text.isEmpty
                    ? "Nuovo esercizio"
                    : nomeController.text,
                int.tryParse(serieController.text) ?? 3,
                int.tryParse(ripetizioniController.text) ?? 10,
                pesoController.text,
                recuperoController.text,
                false,
              );

              setState(() {
                if (esercizio == null) {
                  esercizi.add(nuovo);
                } else if (index != null) {
                  esercizi[index] = nuovo;
                }
              });
              salvaEserciziSuFirestore();
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: AppDesignSystem.paddingXS),
      decoration: BoxDecoration(
        color: AppDesignSystem.surfaceOverlay,
        borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
        border: Border.all(color: AppDesignSystem.primary.withOpacity(0.3)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: AppDesignSystem.bodyMedium.copyWith(
          color: AppDesignSystem.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: AppDesignSystem.bodyMedium.copyWith(
            color: AppDesignSystem.textSecondary,
          ),
          prefixIcon: Icon(icon, color: AppDesignSystem.primary),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppDesignSystem.paddingM,
            vertical: AppDesignSystem.paddingM,
          ),
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppDesignSystem.textPrimary),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
              (route) => false,
            );
          },
        ),
        title: Text(
          "Scheda di Allenamento",
          style: AppDesignSystem.headingMedium.copyWith(
            color: AppDesignSystem.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.save, color: AppDesignSystem.textPrimary),
            onPressed: () async {
              final completedEsercizi =
                  esercizi.where((e) => e.completato).length;

              await salvaEserciziSuFirestore();

              String message = "Scheda salvata!";
              if (completedEsercizi > 0) {
                message += " Progresso missioni aggiornato.";
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    message,
                    style: AppDesignSystem.bodyMedium.copyWith(
                      color: AppDesignSystem.textPrimary,
                    ),
                  ),
                  backgroundColor: AppDesignSystem.success,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDesignSystem.radiusM),
                  ),
                  action:
                      completedEsercizi > 0
                          ? SnackBarAction(
                            label: 'Vedi Missioni',
                            textColor: AppDesignSystem.textPrimary,
                            onPressed: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          const HomeScreen(initialTab: 3),
                                ),
                                (route) => false,
                              );
                            },
                          )
                          : null,
                ),
              );
            },
          ),
        ],
      ),      body: ListView(
        padding: const EdgeInsets.all(AppDesignSystem.paddingM),
        children: [
          if (esercizi.isEmpty)
            AppComponents.emptyState(
              icon: Icons.fitness_center,
              title: 'Nessun esercizio',
              subtitle: 'Aggiungi il tuo primo esercizio per iniziare!',
              iconColor: AppDesignSystem.primary,
              action: AppComponents.primaryButton(
                text: 'Aggiungi Esercizio',
                icon: Icons.add,
                onPressed: () => mostraDialogEsercizio(),
              ),
            )
          else ...[
            ...List.generate(
              esercizi.length,
              (index) => Padding(
                padding: const EdgeInsets.only(bottom: AppDesignSystem.paddingM),
                child: _buildEsercizioCard(
                  esercizi[index],
                  onEdit:
                      () => mostraDialogEsercizio(
                        esercizio: esercizi[index],
                        index: index,
                      ),
                  onDelete: () => eliminaEsercizio(index),
                  onToggle: (_) => toggleCompletato(index),
                ),
              ),
            ),
            const SizedBox(height: AppDesignSystem.paddingM),
            _buildAddButton(),
          ],
        ],
      ),
    );
  }
  Widget _buildEsercizioCard(
    Esercizio esercizio, {
    required Function() onEdit,
    required Function() onDelete,
    required Function(bool?) onToggle,
  }) {
    return AppComponents.standardCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  esercizio.nome,
                  style: AppDesignSystem.headingSmall.copyWith(
                    color: AppDesignSystem.textPrimary,
                    decoration: esercizio.completato ? TextDecoration.lineThrough : null,
                    decorationColor: AppDesignSystem.textSecondary,
                  ),
                ),
              ),
              Checkbox(
                value: esercizio.completato,
                onChanged: onToggle,
                fillColor: MaterialStateProperty.resolveWith(
                  (states) => esercizio.completato ? AppDesignSystem.success : AppDesignSystem.primary,
                ),
                checkColor: AppDesignSystem.cardBackground,
              ),
            ],
          ),
          SizedBox(height: AppDesignSystem.paddingM),
          _buildInfoRow(
            Icons.repeat,
            "${esercizio.serie} serie x ${esercizio.ripetizioni} rip",
          ),
          _buildInfoRow(Icons.fitness_center, "Peso: ${esercizio.peso}"),
          _buildInfoRow(Icons.timer, "Recupero: ${esercizio.recupero}"),
          SizedBox(height: AppDesignSystem.paddingM),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              AppComponents.iconButton(
                icon: Icons.edit,
                onPressed: onEdit,
                iconColor: AppDesignSystem.warning,
              ),
              SizedBox(width: AppDesignSystem.paddingM),
              AppComponents.iconButton(
                icon: Icons.delete,
                onPressed: onDelete,
                iconColor: AppDesignSystem.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppDesignSystem.paddingXS),
      child: Row(
        children: [
          Icon(icon, color: AppDesignSystem.primary, size: 18),
          SizedBox(width: AppDesignSystem.paddingXS),
          Text(
            text,
            style: AppDesignSystem.bodyMedium.copyWith(
              color: AppDesignSystem.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return AppComponents.primaryButton(
      text: "Aggiungi esercizio",
      icon: Icons.add,
      onPressed: () => mostraDialogEsercizio(),
    );
  }
  Future<void> salvaEserciziSuFirestore() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    final schedaRef = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('schede')
        .doc(widget.schedaId);
    
    final eserciziRef = schedaRef.collection('esercizi');

    // Controlla se è la prima volta che viene salvata questa scheda
    final existingSnapshot = await eserciziRef.get();
    final isNewWorkout = existingSnapshot.docs.isEmpty;

    // Cancella tutti gli esercizi esistenti
    for (var doc in existingSnapshot.docs) {
      await doc.reference.delete();
    }

    // Aggiungi gli esercizi attuali
    for (var esercizio in esercizi) {
      await eserciziRef.add({
        'nome': esercizio.nome,
        'serie': esercizio.serie,
        'ripetizioni': esercizio.ripetizioni,
        'peso': esercizio.peso,
        'recupero': esercizio.recupero,
        'completato': esercizio.completato,
      });
    }

    // Se è una nuova scheda, aggiorna i metadati
    if (isNewWorkout) {
      await schedaRef.set({
        'data_creazione': FieldValue.serverTimestamp(),
        'data_ultima_modifica': FieldValue.serverTimestamp(),
        'is_new': false, // Marca come non più nuova dopo il primo salvataggio
      }, SetOptions(merge: true));
      
      // Genera missioni solo per la nuova scheda
      await _missionService.generateMissionsOnWorkoutCreation();
    } else {
      // Aggiorna solo la data di modifica per schede esistenti
      await schedaRef.update({
        'data_ultima_modifica': FieldValue.serverTimestamp(),
      });
    }

    // Aggiorna il progresso delle missioni basato su tutti gli esercizi completati
    final completedExercises =
        esercizi
            .where((e) => e.completato)
            .map(
              (e) => {
                'nome': e.nome,
                'serie': e.serie,
                'ripetizioni': e.ripetizioni,
                'peso': e.peso,
              },
            )
            .toList();
    if (completedExercises.isNotEmpty) {
      // Ottieni il livello attuale prima di aggiornare il progresso
      final playerLevelBefore = await _missionService.getUserLevel();

      // Aggiorna il progresso delle missioni
      await _missionService.updateMissionProgressFromWorkout(
        completedExercises,
      );

      // Completa automaticamente le missioni che sono state completate
      final missionsSnapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.uid)
              .collection('missions')
              .where('status', isEqualTo: 'active')
              .get();

      int completedMissions = 0;

      for (var missionDoc in missionsSnapshot.docs) {
        final mission =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(FirebaseAuth.instance.currentUser!.uid)
                .collection('missions')
                .doc(missionDoc.id)
                .get();

        if (mission.exists) {
          final data = mission.data()!;
          final requirements = data['requirements'] as Map<String, dynamic>;
          final progress = data['progress'] as Map<String, dynamic>;

          bool isCompleted = true;
          for (var key in requirements.keys) {
            if (!progress.containsKey(key) ||
                (progress[key] ?? 0) < (requirements[key] ?? 0)) {
              isCompleted = false;
              break;
            }
          }

          if (isCompleted) {
            await _missionService.completeMission(missionDoc.id);
            completedMissions++;
          }        }
      }

      // Ottieni il livello aggiornato dopo aver completato eventuali missioni
      final playerLevelAfter = await _missionService.getUserLevel();
      
      // Genera nuove missioni solo se ci sono esercizi completati (allenamento effettivo)
      // Non se è solo una scheda nuova creata
      if (completedExercises.isNotEmpty) {
        await _missionService.generateMissionsOnWorkoutComplete();
      }

      // Mostra SnackBar con aggiornamento sul progresso
      String message = "Allenamento salvato!";
      if (completedMissions > 0) {
        message +=
            " ${completedMissions > 1 ? '$completedMissions missioni completate!' : '1 missione completata!'}";
      } else if (completedExercises.isNotEmpty) {
        message += " Progresso missioni aggiornato.";
      }

      // Aggiungi informazioni sul livello se è cambiato
      if (playerLevelAfter.level > playerLevelBefore.level) {
        message += " Sei salito al livello ${playerLevelAfter.level}!";
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.green.shade800,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'MISSIONI',
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(initialTab: 3),
                ),
              );
            },
            textColor: Colors.white,
          ),
        ),
      );
    }
  }
}

// Esattamente lo stesso SlowStarfieldPainter della HomeScreen
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
