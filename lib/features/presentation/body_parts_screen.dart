import 'package:flutter/material.dart';
import 'package:kids_app/features/body_parts/human_body_parts.dart';
import 'package:kids_app/features/presentation/widgets/learning_card.dart';
import '../../../core/services/tts_service.dart';

class BodyPartsScreen extends StatelessWidget {
  const BodyPartsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = TTSService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Body Parts 👤"),
        backgroundColor: Colors.blue.shade100,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade50, Colors.white],
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
          itemCount: bodyParts.length,
          itemBuilder: (context, index) {
            final part = bodyParts[index];
            return LearningCard(
              title: part.english,
              amharicTitle: part.amharic,
              image: part.image,
              themeColor: Colors.blue,
              onTap: () => tts.speak(part.english),
            );
          },
        ),
      ),
    );
  }
}
