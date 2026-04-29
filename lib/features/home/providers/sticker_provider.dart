import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/services/local_storage.dart';
import '../data/sticker_data.dart';

final stickerProvider = StateNotifierProvider<StickerNotifier, List<String>>((ref) {
  return StickerNotifier();
});

class StickerNotifier extends StateNotifier<List<String>> {
  StickerNotifier() : super([]) {
    _loadStickers();
  }

  Future<void> _loadStickers() async {
    state = await RewardStorage.getEarnedStickers();
  }

  Future<Sticker?> unlockRandomSticker() async {
    // Filter out already earned stickers
    final unearned = stickers.where((s) => !state.contains(s.id)).toList();

    if (unearned.isEmpty) return null;

    final random = Random();
    final newSticker = unearned[random.nextInt(unearned.length)];

    final List<String> newState = [...state, newSticker.id];
    state = newState;
    await RewardStorage.saveEarnedStickers(newState);
    
    return newSticker;
  }
}
