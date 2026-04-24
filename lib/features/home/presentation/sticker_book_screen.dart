import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/sticker_data.dart';
import '../providers/sticker_provider.dart';
import 'widgets/sticker_card.dart';

class StickerBookScreen extends ConsumerWidget {
  const StickerBookScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final earnedStickers = ref.watch(stickerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Sticker Book 🏆"),
        backgroundColor: Colors.amber.shade100,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.amber.shade50, Colors.white],
          ),
        ),
        child: GridView.builder(
          padding: const EdgeInsets.all(20),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
            childAspectRatio: 1,
          ),
          itemCount: stickers.length,
          itemBuilder: (context, index) {
            final sticker = stickers[index];
            final isEarned = earnedStickers.contains(sticker.id);

            return StickerCard(
              sticker: sticker,
              isEarned: isEarned,
            );
          },
        ),
      ),
    );
  }
}
