import 'package:flutter/material.dart';
import 'package:kids_app/features/fruits/data/fruits_data.dart';
import 'package:kids_app/features/presentation/widgets/learning_card.dart';
import '../../../core/services/tts_service.dart';

class FruitsScreen extends StatelessWidget {
  const FruitsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = TTSService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Fruits 🍎"),
        backgroundColor: Colors.green.shade100,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemCount: fruits.length,
          itemBuilder: (context, index) {
            final fruit = fruits[index];
            return LearningCard(
              title: fruit.english,
              amharicTitle: fruit.amharic,
              image: fruit.image,
              themeColor: Colors.green,
              onTap: () => tts.speak(fruit.english),
            );
          },
        ),
      ),
    );
  }
}
