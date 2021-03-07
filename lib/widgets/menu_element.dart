import 'package:flutter/material.dart';

class MenuElement extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  MenuElement({this.text, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2.0,
      color: onPressed == null ? Colors.grey[200] : null,
      child: TextButton(
        onPressed: onPressed,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 25.0),
          child: Text(
            text ?? '',
            style: TextStyle(
              fontSize: 18.0,
              color: onPressed == null ? Colors.grey : null,
            ),
          ),
        ),
      ),
    );
  }
}
