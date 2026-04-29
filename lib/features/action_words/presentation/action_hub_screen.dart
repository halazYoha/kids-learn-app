import 'package:flutter/material.dart';
import 'package:kids_app/core/theme/app_theme.dart';
import 'package:kids_app/core/theme/text_style.dart';
import 'package:kids_app/features/action_words/data/action_data.dart';
import 'package:kids_app/features/action_words/presentation/action_video_screen.dart';
import 'package:kids_app/core/services/audio_players.dart';

class ActionHubScreen extends StatelessWidget {
  const ActionHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          "Action Words 🏃",
          style: AppTextStyles.title.copyWith(color: Colors.black87, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Let's move and play!",
                style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.85,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: actionVideos.length,
                  itemBuilder: (context, index) {
                    return _ActionCard(action: actionVideos[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionCard extends StatefulWidget {
  final ActionVideo action;

  const _ActionCard({required this.action});

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: () {
        AudioService.buttonClick();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActionVideoScreen(action: widget.action),
          ),
        );
      },
      child: AnimatedScale(
        scale: _isHovered ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: widget.action.themeColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.black12,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  widget.action.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                widget.action.word,
                textAlign: TextAlign.center,
                style: AppTextStyles.subtitle.copyWith(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                widget.action.amharic,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
