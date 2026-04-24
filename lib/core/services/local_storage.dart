import 'package:shared_preferences/shared_preferences.dart';

class RewardStorage {
  static const _highScoreKey = "high_score";
  static const _coinKey = "coins";
  static const _stickersKey = "earned_stickers";

  static Future<int> getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_highScoreKey) ?? 0;
  }

  static Future<void> saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_highScoreKey, score);
  }

  static Future<int> getCoins() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_coinKey) ?? 0;
  }

  static Future<void> addCoins(int value) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getInt(_coinKey) ?? 0;
    await prefs.setInt(_coinKey, current + value);
  }

  static Future<List<String>> getEarnedStickers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_stickersKey) ?? [];
  }

  static Future<void> saveEarnedStickers(List<String> stickers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_stickersKey, stickers);
  }
}
