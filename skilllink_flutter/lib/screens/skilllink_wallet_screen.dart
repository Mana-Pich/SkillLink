import 'package:flutter/material.dart';

class SkillLinkWalletScreen extends StatelessWidget {
  const SkillLinkWalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFF171A35),
        foregroundColor: Colors.white,
        title: const Text(
          'SkillLink Wallet',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: const Center(
        child: Text(
          'SkillLink Wallet',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}