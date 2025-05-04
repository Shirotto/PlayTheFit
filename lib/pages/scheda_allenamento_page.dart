import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../models/esercizio.dart';
import '../Components/esercizio_card.dart';

class SchedaAllenamentoPage extends StatefulWidget {
  const SchedaAllenamentoPage({super.key});

  @override
  State<SchedaAllenamentoPage> createState() => _SchedaAllenamentoPageState();
}

class _SchedaAllenamentoPageState extends State<SchedaAllenamentoPage>
    with SingleTickerProviderStateMixin {
  List<Esercizio> esercizi = [
    Esercizio("Panca Piana", 4, 10, "60kg", "90s", true),
    Esercizio("Trazioni", 3, 8, "Corpo", "120s", false),
  ];

  late AnimationController _particleAnimationController;

  @override
  void initState() {
    super.initState();
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
  }

  void eliminaEsercizio(int index) {
    setState(() {
      esercizi.removeAt(index);
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
    );

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            backgroundColor: Colors.blue.shade900.withOpacity(0.95),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            title: Text(
              esercizio == null ? "Aggiungi Esercizio" : "Modifica Esercizio",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                shadows: [Shadow(color: Colors.blue, blurRadius: 5)],
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
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                child: const Text("Annulla"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  elevation: 8,
                  shadowColor: Colors.blue.shade400,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
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

                  Navigator.pop(context);
                },
                child: const Text("Salva"),
              ),
            ],
          ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isNumeric = false,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade300.withOpacity(0.5)),
      ),
      child: TextField(
        controller: controller,
        keyboardType: isNumeric ? TextInputType.number : TextInputType.text,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.blue.shade100),
          prefixIcon: Icon(icon, color: Colors.blue.shade300),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Elimina il backgroundColor perché useremo lo stesso gradient della HomeScreen
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          "Scheda di Allenamento",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.blue.shade700, blurRadius: 8)],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () {
              // Salva la scheda
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text("Scheda salvata!"),
                  backgroundColor: Colors.blue.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Sfondo con gradiente - ESATTAMENTE come nella HomeScreen
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.indigo.shade900, Colors.black],
              ),
            ),
          ),

          // Stelle/particelle - ESATTAMENTE come nella HomeScreen
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

          // Contenuto
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...List.generate(
                  esercizi.length,
                  (index) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
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
                const SizedBox(height: 12),
                _buildAddButton(),
              ],
            ),
          ),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              esercizio.completato
                  ? [Colors.purple.shade900, Colors.blue.shade900]
                  : [Colors.blue.shade900, Colors.indigo.shade900],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                esercizio.completato
                    ? Colors.purple.withOpacity(0.4)
                    : Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color:
              esercizio.completato
                  ? Colors.purple.withOpacity(0.5)
                  : Colors.blue.shade400.withOpacity(0.5),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    esercizio.nome,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      decoration:
                          esercizio.completato
                              ? TextDecoration.lineThrough
                              : null,
                      decorationColor: Colors.white70,
                      shadows: [
                        Shadow(color: Colors.blue.shade400, blurRadius: 5),
                      ],
                    ),
                  ),
                ),
                Checkbox(
                  value: esercizio.completato,
                  onChanged: onToggle,
                  fillColor: MaterialStateProperty.resolveWith(
                    (states) => Colors.blue.shade700,
                  ),
                  checkColor: Colors.white,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.repeat,
              "${esercizio.serie} serie x ${esercizio.ripetizioni} rip",
            ),
            _buildInfoRow(Icons.fitness_center, "Peso: ${esercizio.peso}"),
            _buildInfoRow(Icons.timer, "Recupero: ${esercizio.recupero}"),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildIconButton(Icons.edit, onEdit, Colors.amber),
                const SizedBox(width: 12),
                _buildIconButton(Icons.delete, onDelete, Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue.shade300, size: 18),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Function() onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black26,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
      child: ElevatedButton.icon(
        onPressed: () => mostraDialogEsercizio(),
        icon: const Icon(Icons.add),
        label: const Text("Aggiungi esercizio"),
        style: ElevatedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
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
