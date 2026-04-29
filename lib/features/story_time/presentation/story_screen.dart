import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:confetti/confetti.dart';
import '../providers/story_provider.dart';
import 'package:kids_app/core/services/audio_players.dart';
import 'package:kids_app/core/services/tts_service.dart';
import 'widgets/word_tile.dart';
import 'widgets/sentence_bar.dart';

class StoryScreen extends ConsumerStatefulWidget {
  const StoryScreen({super.key});

  @override
  ConsumerState<StoryScreen> createState() => _StoryScreenState();
}

class _StoryScreenState extends ConsumerState<StoryScreen>
    with TickerProviderStateMixin {
  late ConfettiController _confettiController;
  final TTSService _tts = TTSService();

  bool _isCorrect = false;
  bool _isShaking = false;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnim;
  Timer? _questionTimer;

  // gradient colors per question index (cycles)
  static const List<List<Color>> _gradients = [
    [Color(0xFF6C63FF), Color(0xFFFFB74D)],
    [Color(0xFF00C9FF), Color(0xFF92FE9D)],
    [Color(0xFFFC5C7D), Color(0xFF6A3093)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = Tween<double>(begin: 0, end: 12).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
    
    _startTimer();
  }

  void _startTimer() {
    _questionTimer?.cancel();
    _questionTimer = Timer(const Duration(seconds: 60), () async {
      if (mounted) {
        final notifier = ref.read(storyProvider.notifier);
        if (!ref.read(storyProvider).isComplete) {
          notifier.autoSolve();
          AudioService.wrong();
          await Future.delayed(const Duration(seconds: 4));
          if (mounted) {
            notifier.nextQuestion();
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    _confettiController.dispose();
    _shakeController.dispose();
    super.dispose();
  }

  Future<void> _onCheck() async {
    final notifier = ref.read(storyProvider.notifier);
    final isCorrect = notifier.checkAnswer();

    if (isCorrect) {
      _questionTimer?.cancel();
      setState(() => _isCorrect = true);
      _confettiController.play();
      AudioService.correct();
      final sentence = ref.read(storyProvider).currentQuestion.sentence;
      await _tts.speak(sentence);
      await Future.delayed(const Duration(seconds: 2));
      if (!mounted) return;
      notifier.addScore(10);
      notifier.nextQuestion();
      setState(() => _isCorrect = false);
    } else {
      // shake animation
      setState(() => _isShaking = true);
      AudioService.wrong();
      await _shakeController.forward();
      _shakeController.reset();
      setState(() => _isShaking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(storyProvider, (previous, next) {
      if (previous?.currentIndex != next.currentIndex && !next.isComplete) {
        _startTimer();
      } else if (next.isComplete) {
        _questionTimer?.cancel();
      }
    });

    final state = ref.watch(storyProvider);

    if (state.isComplete) {
      return _buildFinishedScreen(state);
    }

    final question = state.currentQuestion;
    final gradColors =
        _gradients[state.currentIndex % _gradients.length];
    final progress = (state.currentIndex + 1) / state.totalQuestions;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Story Time 📖',
          style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '⭐ ${state.score}',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradColors,
          ),
        ),
        child: Stack(
          children: [
            // ── Background blur bubbles ──────────────────────────────────
            Positioned(
              top: -60,
              right: -60,
              child: _glassBubble(180),
            ),
            Positioned(
              bottom: -40,
              left: -40,
              child: _glassBubble(140),
            ),

            SafeArea(
              child: Column(
                children: [
                  // ── Progress bar ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Question ${state.currentIndex + 1} of ${state.totalQuestions}',
                          style: const TextStyle(
                              color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor:
                                Colors.white.withValues(alpha: 0.3),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Colors.white),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Sentence Bar ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedBuilder(
                      animation: _shakeAnim,
                      builder: (context, child) {
                        final offset = _isShaking ? _shakeAnim.value : 0.0;
                        return Transform.translate(
                          offset: Offset(offset, 0),
                          child: child,
                        );
                      },
                      child: SentenceBar(
                        placedWords: state.placedWords,
                        isCorrect: _isCorrect,
                        onRemove: (w) =>
                            ref.read(storyProvider.notifier).removePlaced(w),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Picture card ─────────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: GestureDetector(
                        onTap: () => _tts.speak(question.sentence),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.grey.withValues(alpha: 0.4),
                              width: 1.5,
                            ),
                          ),
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(16),
                                      child: Image.asset(
                                        question.imageAsset,
                                        fit: BoxFit.contain,
                                        errorBuilder:
                                            (_, __, ___) => const Icon(
                                          Icons.image_not_supported,
                                          size: 80,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Amharic hint
                                  Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.black
                                          .withValues(alpha: 0.15),
                                      borderRadius: const BorderRadius
                                          .vertical(
                                          bottom: Radius.circular(28)),
                                    ),
                                    child: Text(
                                      question.amharic,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Word tiles pool ─────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3)),
                      ),
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 8,
                        alignment: WrapAlignment.center,
                        children: state.availableTiles
                            .map(
                              (word) => WordTile(
                                word: word,
                                color:
                                    const Color(0xFFFFB74D),
                                onTap: () => ref
                                    .read(storyProvider.notifier)
                                    .tapTile(word),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Check button ────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: state.placedWords.isEmpty
                            ? null
                            : _onCheck,
                        icon: const Icon(Icons.check_circle,
                            color: Colors.white),
                        label: const Text(
                          'Check! ✅',
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          disabledBackgroundColor:
                              Colors.white.withValues(alpha: 0.2),
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 6,
                          shadowColor:
                              Colors.green.withValues(alpha: 0.4),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Confetti ────────────────────────────────────────────────
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                numberOfParticles: 30,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.yellow,
                  Colors.purple,
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _glassBubble(double size) {
    return Container(
      width: size,
      height: size,
      );
  }

  Widget _buildFinishedScreen(StoryState state) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('🎉', style: TextStyle(fontSize: 80)),
              const SizedBox(height: 20),
              const Text(
                'Amazing Work!',
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87),
              ),
              const SizedBox(height: 10),
              const Text(
                'You built all the sentences!',
                style: TextStyle(fontSize: 20, color: Colors.black54),
              ),
              const SizedBox(height: 30),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.black.withValues(alpha: 0.1)),
                ),
                child: Column(
                  children: [
                    const Text('⭐ Final Score',
                        style: TextStyle(
                            color: Colors.black54, fontSize: 16)),
                    const SizedBox(height: 8),
                    Text(
                      '${state.score}',
                      style: const TextStyle(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () =>
                    ref.read(storyProvider.notifier).restart(),
                icon: const Icon(Icons.refresh, color: Color(0xFF6C63FF)),
                label: const Text(
                  'Play Again! 🔄',
                  style: TextStyle(
                      fontSize: 20,
                      color: Color(0xFF6C63FF),
                      fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  elevation: 8,
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Go Home 🏠',
                    style:
                        TextStyle(color: Colors.black54, fontSize: 18)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
