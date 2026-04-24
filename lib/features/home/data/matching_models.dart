class MatchingItem {
  final String english;
  final String amharic;
  final String image;

  MatchingItem({
    required this.english,
    required this.amharic,
    required this.image,
  });
}

class MatchingSet {
  final List<MatchingItem> items;

  MatchingSet({required this.items});
}
