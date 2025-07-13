import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ConfettiWidget extends StatelessWidget {
  const ConfettiWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Lottie.asset(
      'assets/animations/confetti.json',
      repeat: false,
      fit: BoxFit.cover,
    );
  }
} 