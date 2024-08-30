import 'package:flutter/material.dart';

class LabelCustom extends StatelessWidget {
  final String text;
  const LabelCustom({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
    );
  }
}
