import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();

  static Future<void> _safePlay(String path) async {
    try {
      await _player.stop();
      await _player.play(AssetSource(path));
    } catch (e) {
      debugPrint("Audio Playback Error: $e");
    }
  }

  static Future<void> correct() async => _safePlay('sounds/correct.mp3');
  static Future<void> wrong() async => _safePlay('sounds/wrong.mp3');
  static Future<void> buttonClick() async => _safePlay('sounds/i.mp3');
  static Future<void> celebration() async => _safePlay('sounds/correct.mp3');
  static Future<void> timerWarning() async => _safePlay('sounds/wrong.mp3');
  static Future<void> hint() async => _safePlay('sounds/i.mp3');
  static Future<void> streakBonus() async => _safePlay('sounds/correct.mp3');
  static Future<void> levelUp() async => _safePlay('sounds/correct.mp3');
}
