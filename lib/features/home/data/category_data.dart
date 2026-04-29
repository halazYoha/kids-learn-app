import 'package:flutter/material.dart';
import '../model/category.dart';
import '../model/hub_category.dart';

final List<CategoryHub> hubs = [
  CategoryHub(
    title: "Basics",
    amharicTitle: "መሰረታዊ",
    subtitle: "A, B, C, 1, 2, 3...",
    icon: "🌟",
    gradientColors: [const Color(0xFF6C63FF), const Color(0xFF8E8CD8)],
    categories: [
      Category(title: "Alphabet", amharicTitle: "ሆሄያት", icon: "🅰️", route: "/alphabet"),
      Category(title: "Numbers", amharicTitle: "ቁጥሮች", icon: "🔢", route: "/numbers"),
      Category(title: "Colors", amharicTitle: "ቀለሞች", icon: "🎨", route: "/colors"),
      Category(title: "Shapes", amharicTitle: "ቅርጾች", icon: "📐", route: "/shapes"),
    ],
  ),
  CategoryHub(
    title: "Explore",
    amharicTitle: "አካባቢያችን",
    subtitle: "Animals, Fruits, Vehicles...",
    icon: "🌍",
    gradientColors: [const Color(0xFF00C9FF), const Color(0xFF92FE9D)],
    categories: [
      Category(title: "Animals", amharicTitle: "እንስሳት", icon: "🐶", route: "/animals"),
      Category(title: "Fruits", amharicTitle: "ፍራፍሬዎች", icon: "🍎", route: "/fruits"),
      Category(title: "Vegetables", amharicTitle: "አትክልቶች", icon: "🥦", route: "/vegetables"),
      Category(title: "Vehicles", amharicTitle: "ተሽከርካሪዎች", icon: "🚗", route: "/vehicles"),
      Category(title: "Body Parts", amharicTitle: "የሰውነት ክፍሎች", icon: "👤", route: "/body_parts"),
      Category(title: "Action Words", amharicTitle: "የድርጊት ቃላት", icon: "🏃", route: "/actions"),
    ],
  ),
  CategoryHub(
    title: "Play & Learn",
    amharicTitle: "ጨዋታዎች እና እንቅስቃሴዎች",
    subtitle: "Quiz, Story, Drawing...",
    icon: "🎮",
    gradientColors: [const Color(0xFFFFB74D), const Color(0xFFFF8A65)],
    categories: [
      Category(title: "Story Time", amharicTitle: "የታሪክ ጊዜ", icon: "📖", route: "/story_time"),
      Category(title: "Memory Match", amharicTitle: "የማስታወስ ጨዋታ", icon: "🧠", route: "/memory_game"),
      Category(title: "Quiz", amharicTitle: "ጥያቄ", icon: " 🎮", route: "/quiz"),
      Category(title: "Trace & Draw", amharicTitle: "መጻፍና መሳል", icon: "✍️", route: "/tracing"),
      Category(title: "Sticker Book", amharicTitle: "የሚለጠፉ ምስሎች", icon: "🏆", route: "/stickers"),
    ],
  ),
];
