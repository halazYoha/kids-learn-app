import 'package:flutter/material.dart';
import 'package:kids_app/features/numbers/numbers_data.dart';
import 'package:kids_app/features/presentation/widgets/learning_card.dart';
import '../../../core/services/tts_service.dart';
import '../../../core/models/learning_item.dart';

class NumbersScreen extends StatelessWidget {
  const NumbersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tts = TTSService();

    final List<LearningItem> basic = numbers.sublist(0, 10);
    final List<LearningItem> teens = numbers.sublist(10, 19);
    final List<LearningItem> twenties = numbers.sublist(19, 29);
    final List<LearningItem> tens = numbers.sublist(29);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Numbers 🔢"),
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
        child: CustomScrollView(
          slivers: [
            _buildSliverSection("Basic Numbers (1–10)", basic, tts),
            _buildSliverSection("Teens (11–19)", teens, tts),
            _buildSliverSection("Twenties (20–29)", twenties, tts),
            _buildSliverSection("Tens & Hundreds", tens, tts),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverSection(String title, List<LearningItem> items, TTSService tts) {
    return SliverPadding(
      padding: const EdgeInsets.all(20),
      sliver: SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15),
              child: Text(
                title,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
              ),
            ),
          ),
          SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final item = items[index];
                return LearningCard(
                  title: item.english,
                  amharicTitle: item.amharic,
                  image: item.image,
                  themeColor: Colors.green,
                  onTap: () => tts.speak(item.english),
                );
              },
              childCount: items.length,
            ),
          ),
        ],
      ),
    );
  }
}
