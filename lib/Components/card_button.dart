import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final String txt;
  final VoidCallback onTap;

  const CardButton({super.key, required this.txt, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shadowColor: Colors.blue, // Colore dell'ombra
        elevation: 5, // Elevazione della card
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50), // Bordi arrotondati
        ),
        child: Container(
          height: 50,
          width: 236,
          decoration: BoxDecoration(
            color: Colors.white, // Colore di sfondo del container
            borderRadius: BorderRadius.circular(50), // Bordi arrotondati
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Text(
                    txt,
                    style:
                        Theme.of(context).textTheme.labelLarge ??
                        const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                    textAlign: TextAlign.center,
                    overflow:
                        TextOverflow.ellipsis, // Gestisce il testo troppo lungo
                    maxLines: 1, // Limita il testo a una riga
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
