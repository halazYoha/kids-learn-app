import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../../../core/services/quiz_genrator.dart';
import '../../../core/models/learning_item.dart';
import '../../../core/services/audio_players.dart';
import 'package:kids_app/features/home/data/sticker_data.dart';
import 'package:kids_app/features/home/providers/sticker_provider.dart';
import 'widgets/memory_card.dart';

class MemoryCardModel {
  final int id;
  final LearningItem item;
  final bool isImage;
  bool isFlipped;
  bool isMatched;

  MemoryCardModel({
    required this.id,
    required this.item,
    required this.isImage,
    this.isFlipped = false,
    this.isMatched = false,
  });
}

class MemoryGameScreen extends ConsumerStatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  ConsumerState<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends ConsumerState<MemoryGameScreen> {
  late List<MemoryCardModel> _cards;
  int? _firstFlippedIndex;
  bool _canFlip = true;
  late ConfettiController _confettiController;
  bool _isFinished = false;
  Timer? _gameTimer;
  int _secondsLeft = 60;
  final int _maxSeconds = 60;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    _setupGame();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _gameTimer?.cancel();
    super.dispose();
  }

  void _setupGame() {
    final allItems = QuizGenerator.getAllItems();
    allItems.shuffle();
    final selectedItems = allItems.take(6).toList();

    List<MemoryCardModel> cards = [];
    for (int i = 0; i < selectedItems.length; i++) {
      // One image card
      cards.add(MemoryCardModel(id: i, item: selectedItems[i], isImage: true));
      // One word card
      cards.add(MemoryCardModel(id: i, item: selectedItems[i], isImage: false));
    }

    cards.shuffle();
    setState(() {
      _cards = cards;
      _firstFlippedIndex = null;
      _canFlip = true;
      _isFinished = false;
      _secondsLeft = _maxSeconds;
    });
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() {
          _secondsLeft--;
        });
      } else {
        _onTimeUp();
      }
    });
  }

  void _onTimeUp() {
    _gameTimer?.cancel();
    setState(() {
      _isFinished = true;
    });
    AudioService.wrong();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Text("⏰ Time's Up! ⏰", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.red)),
            const SizedBox(height: 10),
            const Text("Don't worry! Try again and find them faster next time!", textAlign: TextAlign.center, style: TextStyle(fontSize: 18)),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _setupGame();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              child: const Text("Try Again! 🔄", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _onCardTap(int index) {
    if (!_canFlip || _cards[index].isFlipped || _cards[index].isMatched) return;

    setState(() {
      _cards[index].isFlipped = true;
    });

    if (_firstFlippedIndex == null) {
      _firstFlippedIndex = index;
    } else {
      _checkForMatch(index);
    }
  }

  void _checkForMatch(int secondIndex) {
    final firstIndex = _firstFlippedIndex!;
    final firstCard = _cards[firstIndex];
    final secondCard = _cards[secondIndex];

    if (firstCard.id == secondCard.id) {
      // Match!
      setState(() {
        firstCard.isMatched = true;
        secondCard.isMatched = true;
        _firstFlippedIndex = null;
      });
      AudioService.correct();
      
      if (_cards.every((c) => c.isMatched)) {
        _onVictory();
      }
    } else {
      // No match
      _canFlip = false;
      Timer(const Duration(milliseconds: 1000), () {
        if (mounted) {
          setState(() {
            firstCard.isFlipped = false;
            secondCard.isFlipped = false;
            _firstFlippedIndex = null;
            _canFlip = true;
          });
        }
      });
    }
  }

  void _onVictory() async {
    _gameTimer?.cancel();
    setState(() {
      _isFinished = true;
    });
    _confettiController.play();
    AudioService.celebration();

    final sticker = await ref.read(stickerProvider.notifier).unlockRandomSticker();
    
    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            const Text("🎉 Winner! 🎉", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 10),
            const Text("You matched all cards!", style: TextStyle(fontSize: 18)),
            if (sticker != null) ...[
              const SizedBox(height: 20),
              const Text("New Reward:", style: TextStyle(fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(color: Colors.blue.shade50, shape: BoxShape.circle),
                child: Text(sticker.emoji, style: const TextStyle(fontSize: 60)),
              ),
              const SizedBox(height: 5),
              Text(sticker.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
            ]
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _setupGame();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
              child: const Text("Play Again! 🔄", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Memory Match"),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.blue.shade50, Colors.white],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Timer Progress Bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: _secondsLeft / _maxSeconds,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade300,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _secondsLeft > 30 
                          ? Colors.green 
                          : (_secondsLeft > 10 ? Colors.orange : Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.timer, color: _secondsLeft > 10 ? Colors.blueGrey : Colors.red),
                      const SizedBox(width: 5),
                      Text(
                        "Time: $_secondsLeft s",
                        style: TextStyle(
                          fontSize: 20, 
                          fontWeight: FontWeight.bold,
                          color: _secondsLeft > 10 ? Colors.blueGrey : Colors.red,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text("Find the matching pairs!", style: TextStyle(fontSize: 18, color: Colors.blueGrey)),
                  const SizedBox(height: 15),
                  Expanded(
                    child: GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.85,
                      ),
                      itemCount: _cards.length,
                      itemBuilder: (context, index) {
                        final card = _cards[index];
                        return MemoryCard(
                          isFlipped: card.isFlipped,
                          isMatched: card.isMatched,
                          themeColor: Colors.blue,
                          onTap: () => _onCardTap(index),
                          front: card.isImage
                              ? _buildImage(card.item.image)
                              : Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    card.item.english,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [Colors.red, Colors.blue, Colors.green, Colors.yellow, Colors.orange, Colors.purple],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage(String imagePath) {
    if (imagePath.startsWith('text:')) {
      return Center(
        child: Text(
          imagePath.replaceFirst('text:', ''),
          style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.blue),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Image.asset(
        imagePath,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
      ),
    );
  }
}
