import 'package:flutter/material.dart';

class CardButton extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const CardButton({super.key, required this.txt, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(50),
      child: Card(
        key: UniqueKey(),
        shadowColor: Colors.blue,
        elevation: 5,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50)
        ),
        child: Container(
          height: 50,
          width: 236,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              txt,
              style: Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ),
      ),
    );
  }
}
