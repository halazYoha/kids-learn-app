import 'package:kids_app/features/animals/data/animals_data.dart';
import 'package:kids_app/features/colors/colors_data.dart';
import 'package:kids_app/features/numbers/numbers_data.dart';
import 'package:kids_app/features/body_parts/human_body_parts.dart';
import 'package:kids_app/features/shapes/data/shapes_data.dart';
import 'package:kids_app/features/fruits/data/fruits_data.dart';
import 'package:kids_app/features/alphabet/data/alphabet_data.dart';
import 'package:kids_app/features/vehicles/vehicles_data.dart';
import 'package:kids_app/features/vegetables/data/vegetables_data.dart';
import 'package:kids_app/features/home/data/matching_models.dart';

class QuizGenerator {
  static List<MatchingSet> generateMatchingSets() {
    final allItems = [
      ...animals,
      ...colors,
      ...numbers,
      ...bodyParts,
      ...shapes,
      ...fruits,
      ...alphabet,
      ...vehicles,
      ...vegetables
    ];
    allItems.shuffle();

    // Take 15 items for 5 sets of 3
    final selected = allItems.take(15).toList();
    
    List<MatchingSet> sets = [];
    for (int i = 0; i < selected.length; i += 3) {
      if (i + 3 <= selected.length) {
        final chunk = selected.sublist(i, i + 3).map((item) => MatchingItem(
          english: item.english,
          amharic: item.amharic,
          image: item.image,
        )).toList();
        sets.add(MatchingSet(items: chunk));
      }
    }

    return sets;
  }

  static List<dynamic> getAllItems() {
    return [
      ...animals,
      ...colors,
      ...numbers,
      ...bodyParts,
      ...shapes,
      ...fruits,
      ...alphabet,
      ...vehicles,
      ...vegetables
    ];
  }
}
