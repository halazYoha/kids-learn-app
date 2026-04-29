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
import 'package:kids_app/features/presentation/vehicles_screen.dart';
import 'package:kids_app/features/presentation/vegetables_screen.dart';
import 'package:kids_app/features/presentation/tracing_screen.dart';
import 'package:kids_app/features/story_time/presentation/story_screen.dart';
import 'package:kids_app/features/splash/presentation/splash_screen.dart';
import 'package:kids_app/features/profile/presentation/profile_setup_screen.dart';
import 'package:kids_app/features/profile/providers/profile_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/home/presentation/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
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
        "/vehicles": (context) => const VehiclesScreen(),
        "/vegetables": (context) => const VegetablesScreen(),
        "/tracing": (context) => const TracingScreen(),
        "/story_time": (context) => const StoryScreen(),
        "/profile_setup": (context) => const ProfileSetupScreen(),
      },
    );
  }
}
