import 'package:flutter/material.dart';
import 'package:kids_app/features/alphabet/data/alphabet_data.dart';
import 'package:kids_app/features/presentation/widgets/learning_card.dart';
import '../../../core/services/tts_service.dart';

class AlphabetScreen extends StatelessWidget {
  const AlphabetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = TTSService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("ABC Learning 🅰️"),
        backgroundColor: Colors.purple.shade100,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.purple.shade50, Colors.white],
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
          itemCount: alphabet.length,
          itemBuilder: (context, index) {
            final item = alphabet[index];
            return LearningCard(
              title: item.english,
              amharicTitle: item.amharic,
              image: item.image,
              themeColor: Colors.purple,
              onTap: () => tts.speak(item.english),
            );
          },
        ),
      ),
    );
  }
}
