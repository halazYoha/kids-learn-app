import 'package:flutter/material.dart';
import 'package:kids_app/features/animals/data/animals_data.dart';
import 'package:kids_app/features/presentation/widgets/learning_card.dart';
import '../../../core/services/tts_service.dart';

class AnimalsScreen extends StatelessWidget {
  const AnimalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = TTSService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Animals 🐶"),
        backgroundColor: Colors.orange.shade100,
        elevation: 0,
      ),
      body: Container(
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
            childAspectRatio: 0.85,
          ),
          itemCount: animals.length,
          itemBuilder: (context, index) {
            final animal = animals[index];
            return LearningCard(
              title: animal.english,
              amharicTitle: animal.amharic,
              image: animal.image,
              themeColor: Colors.orange,
              onTap: () => tts.speak(animal.english),
            );
          },
        ),
      ),
    );
  }
}
