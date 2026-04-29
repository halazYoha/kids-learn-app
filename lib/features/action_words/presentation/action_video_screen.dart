import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:kids_app/core/theme/app_theme.dart';
import 'package:kids_app/core/theme/text_style.dart';
import 'package:kids_app/core/services/tts_service.dart';
import 'package:kids_app/core/services/audio_players.dart';
import 'package:kids_app/features/action_words/data/action_data.dart';

class ActionVideoScreen extends StatefulWidget {
  final ActionVideo action;

  const ActionVideoScreen({super.key, required this.action});

  @override
  State<ActionVideoScreen> createState() => _ActionVideoScreenState();
}

class _ActionVideoScreenState extends State<ActionVideoScreen>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  final TTSService _tts = TTSService();

  late AnimationController _labelAnim;
  late Animation<double> _labelFade;
  bool _isSpeaking = false;
  bool _videoReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    _labelAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _labelFade = CurvedAnimation(parent: _labelAnim, curve: Curves.easeIn);

    _initVideo();

    // Auto-speak the word a moment after opening
    Future.delayed(const Duration(milliseconds: 600), _speakWord);
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.asset(widget.action.videoAsset);
    try {
      await _videoController.initialize();
      if (!mounted) return;
      _videoController.setLooping(true);
      _videoController.play();
      setState(() => _videoReady = true);
      _labelAnim.forward();
    } catch (e) {
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void dispose() {
    _videoController.dispose();
    _labelAnim.dispose();
    super.dispose();
  }

  Future<void> _speakWord() async {
    if (!mounted) return;
    setState(() => _isSpeaking = true);
    await _tts.speak(widget.action.word);
    if (mounted) setState(() => _isSpeaking = false);
  }

  void _togglePlayPause() {
    AudioService.buttonClick();
    setState(() {
      _videoController.value.isPlaying
          ? _videoController.pause()
          : _videoController.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    final action = widget.action;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          action.word,
          style: AppTextStyles.title.copyWith(color: Colors.white, fontSize: 26),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // ── Video player ──────────────────────────────────────────────
          Expanded(
            flex: 6,
            child: GestureDetector(
              onTap: _videoReady ? _togglePlayPause : null,
              child: Container(
                width: double.infinity,
                color: Colors.black,
                child: _hasError
                    ? _buildErrorFallback(action)
                    : !_videoReady
                        ? Center(
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation(action.themeColor),
                            ),
                          )
                        : Stack(
                            alignment: Alignment.center,
                            children: [
                              AspectRatio(
                                aspectRatio: _videoController.value.aspectRatio,
                                child: VideoPlayer(_videoController),
                              ),
                              // Play/Pause overlay
                              ValueListenableBuilder<VideoPlayerValue>(
                                valueListenable: _videoController,
                                builder: (_, value, __) {
                                  if (value.isPlaying) return const SizedBox.shrink();
                                  return Container(
                                    width: 72,
                                    height: 72,
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
              ),
            ),
          ),

          // ── Progress bar ─────────────────────────────────────────────
          if (_videoReady)
            ValueListenableBuilder<VideoPlayerValue>(
              valueListenable: _videoController,
              builder: (_, value, __) {
                final duration = value.duration.inMilliseconds;
                final position = value.position.inMilliseconds;
                final progress = duration > 0 ? position / duration : 0.0;
                return LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation(action.themeColor),
                  minHeight: 4,
                );
              },
            ),

          // ── Info panel ───────────────────────────────────────────────
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: action.themeColor.withValues(alpha: 0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
              child: FadeTransition(
                opacity: _labelFade,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // English word + emoji
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(action.emoji, style: const TextStyle(fontSize: 36)),
                          const SizedBox(width: 12),
                          Text(
                            action.word,
                            style: AppTextStyles.title.copyWith(
                              fontSize: 40,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Amharic translation badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                        decoration: BoxDecoration(
                          color: action.themeColor.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: action.themeColor.withValues(alpha: 0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          action.amharic,
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: action.themeColor,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Controls row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Play / Pause button
                          if (_videoReady)
                            ValueListenableBuilder<VideoPlayerValue>(
                              valueListenable: _videoController,
                              builder: (_, value, __) {
                                return _ControlButton(
                                  icon: value.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  label: value.isPlaying ? 'Pause' : 'Play',
                                  color: action.themeColor,
                                  onTap: _togglePlayPause,
                                );
                              },
                            ),

                          // Replay button
                          if (_videoReady)
                            _ControlButton(
                              icon: Icons.replay_rounded,
                              label: 'Replay',
                              color: action.themeColor,
                              onTap: () {
                                AudioService.buttonClick();
                                _videoController.seekTo(Duration.zero);
                                _videoController.play();
                              },
                            ),

                          // Say it button
                          _ControlButton(
                            icon: _isSpeaking
                                ? Icons.volume_up_rounded
                                : Icons.record_voice_over_rounded,
                            label: _isSpeaking ? 'Speaking…' : 'Say it!',
                            color: action.themeColor,
                            onTap: _isSpeaking ? null : _speakWord,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorFallback(ActionVideo action) {
    return Container(
      color: action.themeColor.withValues(alpha: 0.15),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(action.emoji, style: const TextStyle(fontSize: 100)),
            const SizedBox(height: 12),
            const Text(
              'Video unavailable',
              style: TextStyle(color: Colors.white54, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Opacity(
        opacity: onTap == null ? 0.4 : 1.0,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 30),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
