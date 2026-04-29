import 'dart:ui';
import 'package:flutter/material.dart';
import '../model/hub_category.dart';
import '../../../../core/theme/text_style.dart';

class CategoryHubScreen extends StatefulWidget {
  final CategoryHub hub;

  const CategoryHubScreen({super.key, required this.hub});

  @override
  State<CategoryHubScreen> createState() => _CategoryHubScreenState();
}

class _CategoryHubScreenState extends State<CategoryHubScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "${widget.hub.title} ${widget.hub.icon}",
          style: AppTextStyles.title.copyWith(color: Colors.black87, fontSize: 24),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
                child: Text(
                  widget.hub.subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: widget.hub.categories.length,
                  physics: const BouncingScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 0.9,
                  ),
                  itemBuilder: (context, index) {
                    final category = widget.hub.categories[index];
                    return _SubcategoryCard(
                      category: category,
                      themeColor: widget.hub.gradientColors.last,
                    );
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

class _SubcategoryCard extends StatefulWidget {
  final dynamic category;
  final Color themeColor;

  const _SubcategoryCard({
    required this.category,
    required this.themeColor,
  });

  @override
  State<_SubcategoryCard> createState() => _SubcategoryCardState();
}

class _SubcategoryCardState extends State<_SubcategoryCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      onTap: () {
        Navigator.pushNamed(context, widget.category.route);
      },
      child: AnimatedScale(
        scale: _isHovered ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          decoration: BoxDecoration(
            color: widget.themeColor,
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
                      widget.category.icon,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.category.title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.subtitle.copyWith(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.category.amharicTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
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
