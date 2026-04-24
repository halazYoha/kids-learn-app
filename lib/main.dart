import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kids_app/features/presentation/animal_screen.dart';
import 'package:kids_app/features/presentation/colors_screen.dart';
import 'package:kids_app/features/presentation/numbers_screen.dart';
import 'package:kids_app/features/presentation/matching_quiz_screen.dart';
import 'package:kids_app/features/presentation/body_parts_screen.dart';
import 'package:kids_app/features/presentation/shapes_screen.dart';
import 'package:kids_app/features/presentation/fruits_screen.dart';
import 'package:kids_app/features/presentation/alphabet_screen.dart';
import 'package:kids_app/features/presentation/memory_game_screen.dart';
import 'package:kids_app/features/home/presentation/sticker_book_screen.dart';
import 'package:kids_app/features/splash/presentation/splash_screen.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kids English App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      initialRoute: "/",

      routes: {
        "/": (context) => const SplashScreen(),
        "/home": (context) => const HomeScreen(),
        "/animals": (context) => const AnimalsScreen(),
        "/numbers": (context) => const NumbersScreen(),
        "/colors": (context) => const ColorsScreen(),
        "/body_parts": (context) => const BodyPartsScreen(),
        "/shapes": (context) => const ShapesScreen(),
        "/fruits": (context) => const FruitsScreen(),
        "/alphabet": (context) => const AlphabetScreen(),
        "/memory_game": (context) => const MemoryGameScreen(),
        "/stickers": (context) => const StickerBookScreen(),
        "/quiz": (context) => const MatchingQuizScreen(),
      },
    );
  }
}
