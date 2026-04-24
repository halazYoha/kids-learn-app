import 'dart:math';
import 'package:flutter/material.dart';

class MemoryCard extends StatelessWidget {
  final bool isFlipped;
  final bool isMatched;
  final Widget front;
  final VoidCallback onTap;
  final MaterialColor themeColor;

  const MemoryCard({
    super.key,
    required this.isFlipped,
    required this.isMatched,
    required this.front,
    required this.onTap,
    required this.themeColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (isFlipped || isMatched) ? null : onTap,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: isFlipped || isMatched ? 180 : 0),
        duration: const Duration(milliseconds: 400),
        builder: (context, angle, child) {
          final isBack = angle < 90;
          // Calculate scale to create a "pop" effect during the flip
          final double scale = 1 + (sin(angle * pi / 180).abs() * 0.1);
          
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // perspective
              ..rotateY(angle * pi / 180)
              ..scale(scale),
            alignment: Alignment.center,
            child: isBack
                ? _buildBack()
                : Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.identity()..rotateY(pi),
                    child: _buildFront(),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildBack() {
    return Container(
      decoration: BoxDecoration(
        color: themeColor.shade400,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "❓",
          style: TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  Widget _buildFront() {
    return Container(
      decoration: BoxDecoration(
        color: isMatched ? Colors.green.shade100 : Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isMatched ? Colors.green : themeColor.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(child: front),
    );
  }
}
