import 'package:flutter/material.dart';
import 'category.dart';

class CategoryHub {
  final String title;
  final String amharicTitle;
  final String subtitle;
  final String icon;
  final List<Color> gradientColors;
  final List<Category> categories;

  CategoryHub({
    required this.title,
    required this.amharicTitle,
    required this.subtitle,
    required this.icon,
    required this.gradientColors,
    required this.categories,
  });
}
