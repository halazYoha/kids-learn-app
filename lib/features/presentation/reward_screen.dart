import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';

class RewardScreen extends StatefulWidget {
  final int score;
  final int coins;

  const RewardScreen({super.key, required this.score, required this.coins});

  @override
  State<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends State<RewardScreen> {
  late ConfettiController controller;

  @override
  void initState() {
    super.initState();
    controller = ConfettiController(duration: const Duration(seconds: 3));
    controller.play();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  String getBadge() {
    if (widget.score >= 60) return "Gold 🥇";
    if (widget.score >= 40) return "Silver 🥈";
    return "Bronze 🥉";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow.shade50,
      body: Stack(
        alignment: Alignment.center,
        children: [
          ConfettiWidget(
            confettiController: controller,
            blastDirectionality: BlastDirectionality.explosive,
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "🎉 Great Job!",
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              Text(
                "⭐ Score: ${widget.score}",
                style: const TextStyle(fontSize: 24),
              ),

              Text(
                "🪙 Coins: ${widget.coins}",
                style: const TextStyle(fontSize: 24),
              ),

              const SizedBox(height: 10),

              Text(
                "🏅 Badge: ${getBadge()}",
                style: const TextStyle(fontSize: 28),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Play Again 🔁"),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
