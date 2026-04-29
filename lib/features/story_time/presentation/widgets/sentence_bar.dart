import 'package:flutter/material.dart';
import 'word_tile.dart';

class SentenceBar extends StatelessWidget {
  final List<String> placedWords;
  final void Function(String word) onRemove;
  final bool isCorrect;

  const SentenceBar({
    super.key,
    required this.placedWords,
    required this.onRemove,
    this.isCorrect = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 64),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isCorrect
            ? Colors.green.withValues(alpha: 0.15)
            : Colors.white.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.white.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: placedWords.isEmpty
          ? Center(
              child: Text(
                'Tap words below to build the sentence ✏️',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 6,
              children: placedWords
                  .map(
                    (w) => WordTile(
                      word: w,
                      color: isCorrect ? Colors.green : Colors.deepPurple,
                      isSmall: true,
                      onTap: () => onRemove(w),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}
