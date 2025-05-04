import 'package:flutter/material.dart';
import '../models/esercizio.dart';
import '../Components/esercizio_card.dart';

class SchedaAllenamentoPage extends StatefulWidget {
  const SchedaAllenamentoPage({super.key});

  @override
  State<SchedaAllenamentoPage> createState() => _SchedaAllenamentoPageState();
}

class _SchedaAllenamentoPageState extends State<SchedaAllenamentoPage> {
  List<Esercizio> esercizi = [
    Esercizio("Panca Piana", 4, 10, "60kg", "90s", true),
    Esercizio("Trazioni", 3, 8, "Corpo", "120s", false),
  ];

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
    final serieController = TextEditingController(text: esercizio?.serie.toString() ?? "3");
    final ripetizioniController = TextEditingController(text: esercizio?.ripetizioni.toString() ?? "10");
    final pesoController = TextEditingController(text: esercizio?.peso ?? "");
    final recuperoController = TextEditingController(text: esercizio?.recupero ?? "");

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(esercizio == null ? "Aggiungi Esercizio" : "Modifica Esercizio"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nomeController, decoration: const InputDecoration(labelText: "Nome")),
              TextField(controller: serieController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Serie")),
              TextField(controller: ripetizioniController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: "Ripetizioni")),
              TextField(controller: pesoController, decoration: const InputDecoration(labelText: "Peso")),
              TextField(controller: recuperoController, decoration: const InputDecoration(labelText: "Recupero")),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annulla")),
          ElevatedButton(
            onPressed: () {
              final nuovo = Esercizio(
                nomeController.text,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scheda di Allenamento - Lunedì")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ...List.generate(
            esercizi.length,
                (index) => EsercizioCard(
              esercizio: esercizi[index],
              onEdit: () => mostraDialogEsercizio(esercizio: esercizi[index], index: index),
              onDelete: () => eliminaEsercizio(index),
              onToggle: (_) => toggleCompletato(index),
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: () => mostraDialogEsercizio(),
            icon: const Icon(Icons.add),
            label: const Text("Aggiungi esercizio"),
          ),
        ],
      ),
    );
  }
}