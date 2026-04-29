import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/story_data.dart';

class StoryState {
  final List<StoryQuestion> questions;
  final int currentIndex;
  final List<String> placedWords; // words the child has tapped so far
  final List<String> availableTiles; // tiles still available to tap
  final int score;
  final bool isComplete; // all questions done

  const StoryState({
    required this.questions,
    this.currentIndex = 0,
    this.placedWords = const [],
    this.availableTiles = const [],
    this.score = 0,
    this.isComplete = false,
  });

  StoryQuestion get currentQuestion => questions[currentIndex];
  int get totalQuestions => questions.length;
  bool get isLastQuestion => currentIndex >= questions.length - 1;

  StoryState copyWith({
    List<StoryQuestion>? questions,
    int? currentIndex,
    List<String>? placedWords,
    List<String>? availableTiles,
    int? score,
    bool? isComplete,
  }) {
    return StoryState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      placedWords: placedWords ?? this.placedWords,
      availableTiles: availableTiles ?? this.availableTiles,
      score: score ?? this.score,
      isComplete: isComplete ?? this.isComplete,
    );
  }
}

class StoryNotifier extends StateNotifier<StoryState> {
  StoryNotifier()
      : super(StoryState(
          questions: List.from(storyQuestions)..shuffle(),
          placedWords: [],
          availableTiles: [],
        )) {
    _loadCurrentTiles();
  }

  void _loadCurrentTiles() {
    final tiles = List<String>.from(state.currentQuestion.allTiles);
    state = state.copyWith(
      placedWords: [],
      availableTiles: tiles,
    );
  }

  /// Child taps a tile from the available pool → moves it into the sentence bar
  void tapTile(String word) {
    final newAvail = List<String>.from(state.availableTiles);
    final idx = newAvail.indexOf(word);
    if (idx < 0) return;
    newAvail.removeAt(idx);

    final newPlaced = List<String>.from(state.placedWords)..add(word);
    state = state.copyWith(
      placedWords: newPlaced,
      availableTiles: newAvail,
    );
  }

  /// Child taps a placed word → returns it to available pool
  void removePlaced(String word) {
    final newPlaced = List<String>.from(state.placedWords);
    final idx = newPlaced.lastIndexOf(word);
    if (idx < 0) return;
    newPlaced.removeAt(idx);

    final newAvail = List<String>.from(state.availableTiles)..add(word);
    state = state.copyWith(
      placedWords: newPlaced,
      availableTiles: newAvail,
    );
  }

  /// Returns true if the current placed words match the correct sentence
  bool checkAnswer() {
    final correct = state.currentQuestion.correctWords;
    if (state.placedWords.length != correct.length) return false;
    for (int i = 0; i < correct.length; i++) {
      if (state.placedWords[i].trim().toLowerCase() != correct[i].trim().toLowerCase()) {
        return false;
      }
    }
    return true;
  }

  /// Advance to the next question (call after celebration)
  void nextQuestion() {
    if (state.isLastQuestion) {
      state = state.copyWith(isComplete: true);
    } else {
      state = state.copyWith(
        currentIndex: state.currentIndex + 1,
      );
      _loadCurrentTiles();
    }
  }

  /// Automatically solve the current question for timeouts
  void autoSolve() {
    state = state.copyWith(
      placedWords: List.from(state.currentQuestion.correctWords),
      availableTiles: [],
    );
  }

  /// Add points (call on correct answer)
  void addScore(int points) {
    state = state.copyWith(score: state.score + points);
  }

  /// Reset everything
  void restart() {
    state = StoryState(
      questions: List.from(storyQuestions)..shuffle(),
      placedWords: [],
      availableTiles: [],
      score: 0,
      isComplete: false,
    );
    _loadCurrentTiles();
  }
}

final storyProvider = StateNotifierProvider<StoryNotifier, StoryState>(
  (ref) => StoryNotifier(),
);
