import 'package:flutter/material.dart';

class TitleCustom extends StatelessWidget {
  final String text;
  const TitleCustom({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
    );
  }
}
