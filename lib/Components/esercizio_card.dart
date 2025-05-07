import 'package:flutter/material.dart';
import '../models/esercizio.dart';

class EsercizioCard extends StatelessWidget {
  final Esercizio esercizio;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final ValueChanged<bool?> onToggle;

  const EsercizioCard({
    super.key,
    required this.esercizio,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(esercizio.nome, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Serie: ${esercizio.serie}  |  Ripetizioni: ${esercizio.ripetizioni}"),
            Text("Peso: ${esercizio.peso}  |  Recupero: ${esercizio.recupero}"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Checkbox(
                  value: esercizio.completato,
                  onChanged: onToggle,
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit), onPressed: onEdit),
                    IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}