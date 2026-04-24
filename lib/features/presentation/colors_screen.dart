import 'package:flutter/material.dart';
import 'package:kids_app/features/colors/colors_data.dart';
import 'package:kids_app/features/presentation/widgets/learning_card.dart';
import '../../../core/services/tts_service.dart';

class ColorsScreen extends StatelessWidget {
  const ColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = TTSService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Colors 🎨"),
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
          itemCount: colors.length,
          itemBuilder: (context, index) {
            final colorItem = colors[index];
            return LearningCard(
              title: colorItem.english,
              amharicTitle: colorItem.amharic,
              image: colorItem.image,
              themeColor: Colors.blue,
              onTap: () => tts.speak(colorItem.english),
            );
          },
        ),
      ),
    );
  }
}
