import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../profile/providers/profile_provider.dart';

class LearningCard extends ConsumerStatefulWidget {
  final String title;
  final String amharicTitle;
  final String image;
  final VoidCallback onTap;
  final MaterialColor themeColor;

  const LearningCard({
    super.key,
    required this.title,
    required this.amharicTitle,
    required this.image,
    required this.onTap,
    this.themeColor = Colors.orange,
  });

  @override
  ConsumerState<LearningCard> createState() => _LearningCardState();
}

class _LearningCardState extends ConsumerState<LearningCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 50),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.bounceIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _controller.forward().then((_) => _controller.reverse());
        widget.onTap();
      },
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: widget.themeColor.withValues(alpha: 0.3), width: 2),
            boxShadow: [
              BoxShadow(
                color: widget.themeColor.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: widget.image.startsWith('text:')
                      ? Center(
                          child: FittedBox(
                            child: Text(
                              widget.image.split(':')[1],
                              style: TextStyle(
                                fontSize: 80,
                                fontWeight: FontWeight.bold,
                                color: widget.themeColor.shade800,
                              ),
                            ),
                          ),
                        )
                      : Hero(
                          tag: widget.image,
                          child: Image.asset(
                            widget.image,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Center(
                              child: Icon(
                                Icons.image_not_supported,
                                size: 80,
                                color: widget.themeColor.shade200,
                              ),
                            ),
                          ),
                        ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: widget.themeColor.withValues(alpha: 0.05),
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(23)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: widget.themeColor.shade800,
                        ),
                      ),
                      Text(
                        widget.amharicTitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: widget.themeColor.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
