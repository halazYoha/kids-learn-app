import 'package:flutter/material.dart';
import 'package:kids_app/features/vehicles/vehicles_data.dart';
import 'package:kids_app/features/presentation/widgets/learning_card.dart';
import '../../../core/services/tts_service.dart';

class VehiclesScreen extends StatelessWidget {
  const VehiclesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = TTSService();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Vehicles 🚗"),
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
          itemCount: vehicles.length,
          itemBuilder: (context, index) {
            final item = vehicles[index];
            return LearningCard(
              title: item.english,
              amharicTitle: item.amharic,
              image: item.image,
              themeColor: Colors.blue,
              onTap: () => tts.speak(item.english),
            );
          },
        ),
      ),
    );
  }
}
