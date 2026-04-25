import 'package:flutter/material.dart';
import 'widgets/learning_card.dart';
import '../vegetables/data/vegetables_data.dart';
import 'package:kids_app/core/services/tts_service.dart';

class VegetablesScreen extends StatelessWidget {
  const VegetablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Vegetables / አትክልቶች"),
        backgroundColor: Colors.green.shade100,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade50, Colors.white],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
            ),
            itemCount: vegetables.length,
            itemBuilder: (context, index) {
              final veg = vegetables[index];
              return LearningCard(
                title: veg.english,
                amharicTitle: veg.amharic,
                image: veg.image,
                themeColor: Colors.green,
                onTap: () => TTSService().speak(veg.english),
              );
            },
          ),
        ),
      ),
    );
  }
}
