import 'package:flutter/material.dart';
import 'package:kids_app/core/theme/text_style.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Learn English")),
      body: Center(child: Text("Welcome 👋", style: AppTextStyles.title)),
    );
  }
}
