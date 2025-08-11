import 'package:flutter/material.dart';

class TarlError extends StatelessWidget {
  final String message;
  const TarlError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Text('Error: $message', style: const TextStyle(color: Colors.red));
  }
}
