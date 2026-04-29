import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kids_app/core/services/audio_players.dart';
import 'package:kids_app/features/home/providers/quiz_provider.dart';
import 'package:kids_app/features/home/data/matching_models.dart';
import 'package:kids_app/core/services/tts_service.dart';
import 'package:confetti/confetti.dart';
import 'package:kids_app/features/home/providers/sticker_provider.dart';
import 'package:kids_app/features/home/data/sticker_data.dart';
import 'package:kids_app/features/profile/providers/profile_provider.dart';

class MatchingQuizScreen extends ConsumerStatefulWidget {
  const MatchingQuizScreen({super.key});

  @override
  ConsumerState<MatchingQuizScreen> createState() => _MatchingQuizScreenState();
}

class _MatchingQuizScreenState extends ConsumerState<MatchingQuizScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  final TTSService _tts = TTSService();
  final Map<String, bool> _matchedItems = {}; // english -> isMatched
  List<MatchingItem> _shuffledWords = [];
  List<MatchingItem> _shuffledImages = [];
  Sticker? _finalSticker;
  bool _awardingInProgress = false;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 2));
    _initializeSet();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _initializeSet() {
    _matchedItems.clear();
    
    // Get current set from provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(quizProvider);
      if (state.sets.isNotEmpty) {
        setState(() {
          _shuffledWords = List.from(state.currentSet.items)..shuffle();
          _shuffledImages = List.from(state.currentSet.items)..shuffle();
        });
      }
    });
  }

  void _handleMatch(String english) {
    if (_matchedItems[english] == true) return;

    setState(() {
      _matchedItems[english] = true;
    });

    AudioService.correct();
    ref.read(quizProvider.notifier).addScore(10);

    // Check if all matched
    final currentSet = ref.read(quizProvider).currentSet;
    if (_matchedItems.length == currentSet.items.length) {
      _showSuccessDialog();
    }
  }

  void _showSuccessDialog() async {
    _confettiController.play();
    AudioService.celebration();

    // Award a random sticker for each practice set
    final Sticker? awardedSticker = await ref.read(stickerProvider.notifier).unlockRandomSticker();

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Column(
          children: [
            Text(
              "🌟 Well Done! 🌟",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.orange),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Text(
              "You matched them all!",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _nextRound();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text("Next Round! ➡️", style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _nextRound() {
    ref.read(quizProvider.notifier).nextSet();
    _initializeSet();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(quizProvider);

    ref.listen(quizProvider, (previous, next) async {
      if (next.finished && !(previous?.finished ?? false) && !_awardingInProgress) {
        _awardingInProgress = true;
        final sticker = await ref.read(stickerProvider.notifier).unlockRandomSticker();
        if (mounted) {
          setState(() {
            _finalSticker = sticker;
            _awardingInProgress = false;
          });
        }
      }
    });

    if (state.finished) {
      return _buildFinishedScreen(state);
    }

    if (state.sets.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentSet = state.currentSet;

    // Ensure _shuffledWords and _shuffledImages are in sync with current set
    if (_shuffledWords.isEmpty || _shuffledWords.length != currentSet.items.length || 
        !_shuffledWords.every((sw) => currentSet.items.any((ci) => ci.english == sw.english))) {
      _shuffledWords = List.from(currentSet.items)..shuffle();
    }
    if (_shuffledImages.isEmpty || _shuffledImages.length != currentSet.items.length || 
        !_shuffledImages.every((si) => currentSet.items.any((ci) => ci.english == si.english))) {
      _shuffledImages = List.from(currentSet.items)..shuffle();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Match & Learn! Set ${state.setIndex + 1}"),
        backgroundColor: Colors.orange.shade100,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "Score: ${state.score}",
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          Container(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Images Column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _shuffledImages.map((item) {
                        return _buildImageTarget(item);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Words Column
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _shuffledWords.map((item) {
                        return _buildDraggableWord(item);
                      }).toList(),
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
              colors: const [Colors.green, Colors.blue, Colors.pink, Colors.orange, Colors.purple],
            ),
          ),
          // Timer bar
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: LinearProgressIndicator(
              value: state.timeRemaining / 30,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(
                state.timeRemaining < 10 ? Colors.red : Colors.green,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageTarget(MatchingItem item) {
    bool isMatched = _matchedItems[item.english] ?? false;

    return DragTarget<String>(
      onWillAcceptWithDetails: (details) => !isMatched && details.data == item.english,
      onAcceptWithDetails: (details) => _handleMatch(item.english),
      builder: (context, candidateData, rejectedData) {
        bool isHovering = candidateData.isNotEmpty;
        
        return GestureDetector(
          onTap: () => _tts.speak(item.english),
          child: Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isMatched ? Colors.green.shade100 : (isHovering ? Colors.yellow.shade100 : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isMatched ? Colors.green : (isHovering ? Colors.orange : Colors.grey.shade300),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5, offset: const Offset(0, 3)),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: item.image.startsWith('text:')
                        ? FittedBox(
                            child: Text(
                              item.image.split(':')[1],
                              style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          )
                        : Image.asset(
                            item.image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 40,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                  ),
                ),
                if (isMatched)
                  const Positioned(
                    top: 5,
                    right: 5,
                    child: Icon(Icons.check_circle, color: Colors.green, size: 30),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDraggableWord(MatchingItem item) {
    bool isMatched = _matchedItems[item.english] ?? false;

    if (isMatched) {
      return const SizedBox(height: 100, child: Center(child: Icon(Icons.check, color: Colors.green, size: 40)));
    }

    return Draggable<String>(
      data: item.english,
      feedback: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.orange,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
          ),
          child: Text(
            item.english,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.3,
        child: _buildWordCard(item.english, Colors.grey),
      ),
      onDragStarted: () {
        AudioService.buttonClick();
        _tts.speak(item.english);
      },
      child: GestureDetector(
        onTap: () => _tts.speak(item.english),
        child: _buildWordCard(item.english, Colors.orange),
      ),
    );
  }

  Widget _buildWordCard(String text, Color color) {
    return Container(
      height: 100,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 5, offset: const Offset(0, 3)),
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinishedScreen(QuizState state) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, color: Colors.yellow, size: 120),
            const SizedBox(height: 20),
            const Text("Quiz Finished!", style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 10),
            const Text("Great Job!", style: TextStyle(fontSize: 24, color: Colors.white)),
            const SizedBox(height: 20),
            if (_finalSticker != null) ...[
              const Text("You earned a special sticker!", style: TextStyle(color: Colors.white, fontSize: 18)),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                child: Text(_finalSticker!.emoji, style: const TextStyle(fontSize: 60)),
              ),
              const SizedBox(height: 10),
              Text(_finalSticker!.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
            const SizedBox(height: 10),
            Text("Final Score: ${state.score}", style: const TextStyle(fontSize: 20, color: Colors.white70)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _finalSticker = null;
                });
                ref.read(quizProvider.notifier).restartQuiz();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: const Text("Play Again! 🔄", style: TextStyle(fontSize: 20, color: Colors.orange)),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Go Back Home", style: TextStyle(color: Colors.white70, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
