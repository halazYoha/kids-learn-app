import 'dart:async';
import 'package:kids_app/core/services/audio_players.dart';
import 'package:kids_app/core/services/local_storage.dart';
import 'package:kids_app/core/services/quiz_genrator.dart';
import 'package:kids_app/features/home/data/matching_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class QuizState {
  final List<MatchingSet> sets;
  final int setIndex;
  final int score;
  final int highScore;
  final int coins;
  final bool finished;
  final int timeRemaining;
  final bool isTimerActive;

  QuizState({
    required this.sets,
    this.setIndex = 0,
    this.score = 0,
    this.highScore = 0,
    this.coins = 0,
    this.finished = false,
    this.timeRemaining = 30,
    this.isTimerActive = true,
  });

  MatchingSet get currentSet => sets[setIndex];

  QuizState copyWith({
    int? setIndex,
    int? score,
    int? highScore,
    int? coins,
    bool? finished,
    int? timeRemaining,
    bool? isTimerActive,
  }) {
    return QuizState(
      sets: sets,
      setIndex: setIndex ?? this.setIndex,
      score: score ?? this.score,
      highScore: highScore ?? this.highScore,
      coins: coins ?? this.coins,
      finished: finished ?? this.finished,
      timeRemaining: timeRemaining ?? this.timeRemaining,
      isTimerActive: isTimerActive ?? this.isTimerActive,
    );
  }
}

class QuizNotifier extends StateNotifier<QuizState> {
  Timer? _timer;
  
  QuizNotifier() : super(QuizState(sets: QuizGenerator.generateMatchingSets())) {
    loadData();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void loadData() async {
    final high = await RewardStorage.getHighScore();
    final coins = await RewardStorage.getCoins();
    state = state.copyWith(highScore: high, coins: coins);
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.timeRemaining > 0 && state.isTimerActive) {
        state = state.copyWith(timeRemaining: state.timeRemaining - 1);
        if (state.timeRemaining == 0) {
          _timeUp();
        }
      } else {
        timer.cancel();
      }
    });
  }

  void _timeUp() {
    _timer?.cancel();
    AudioService.wrong();
    nextSet();
  }

  void nextSet() async {
    int nextIndex = state.setIndex + 1;
    
    if (nextIndex >= state.sets.length) {
      _timer?.cancel();
      AudioService.celebration();
      state = state.copyWith(
        finished: true,
        isTimerActive: false,
      );
      return;
    }
    
    state = state.copyWith(
      setIndex: nextIndex,
      timeRemaining: 30,
      isTimerActive: true,
    );
    _startTimer();
  }

  void addScore(int points) async {
    int newScore = state.score + points;
    int newCoins = state.coins + (points ~/ 2);
    
    int high = state.highScore;
    if (newScore > high) {
      high = newScore;
      await RewardStorage.saveHighScore(high);
    }
    
    state = state.copyWith(
      score: newScore,
      coins: newCoins,
      highScore: high,
    );
  }

  void restartQuiz() {
    _timer?.cancel();
    state = QuizState(
      sets: QuizGenerator.generateMatchingSets(),
      highScore: state.highScore,
      coins: state.coins,
    );
    _startTimer();
  }
}

final quizProvider = StateNotifierProvider<QuizNotifier, QuizState>((ref) {
  return QuizNotifier();
});
