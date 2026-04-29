class StoryQuestion {
  final String imageAsset; // asset path OR emoji if starts with 'emoji:'
  final String sentence; // full correct sentence
  final String amharic; // Amharic translation hint
  final List<String> extraWords; // wrong distractor words

  const StoryQuestion({
    required this.imageAsset,
    required this.sentence,
    required this.amharic,
    this.extraWords = const [],
  });

  /// Returns the words in the correct order
  List<String> get correctWords => sentence.split(' ');

  /// Returns all tiles (correct + distractors) shuffled
  List<String> get allTiles {
    final tiles = [...correctWords, ...extraWords];
    tiles.shuffle();
    return tiles;
  }
}

final List<StoryQuestion> storyQuestions = [
  // ─── Fruits ─────────────────────────────────────────────────────────────
  StoryQuestion(
    imageAsset: 'assets/images/fruits/apple.png',
    sentence: 'I eat an apple',
    amharic: 'ፖም እበላለሁ',
    extraWords: ['she', 'big'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/banana.png',
    sentence: 'The banana is yellow',
    amharic: 'ሙዝ ቢጫ ነው',
    extraWords: ['green', 'big'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/orange.png',
    sentence: 'I like orange juice',
    amharic: 'የብርቱካን ጭማቂ እወዳለሁ',
    extraWords: ['eat', 'lemon'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/mango.png',
    sentence: 'The mango is sweet',
    amharic: 'ማንጎ ጣፋጭ ነው',
    extraWords: ['sour', 'big'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/strawberry.png',
    sentence: 'I love strawberry',
    amharic: 'ስትሮቤሪ እወዳለሁ',
    extraWords: ['eat', 'big'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/watermelon.png',
    sentence: 'Watermelon is red inside',
    amharic: 'ዝናብ ፍሬ ውስጡ ቀይ ነው',
    extraWords: ['green', 'big'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/grape.png',
    sentence: 'Grapes grow on vines',
    amharic: 'ወይን በወይፈን ይበቅላል',
    extraWords: ['trees', 'fall'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/lemon.png',
    sentence: 'The lemon is sour',
    amharic: 'ሎሚ መራራ ነው',
    extraWords: ['sweet', 'big'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/pineapple.png',
    sentence: 'Pineapple is my favorite fruit',
    amharic: 'አናናስ ተወዳዳሪ ፍሬዬ ነው',
    extraWords: ['eat', 'red'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/fruits/papaya.png',
    sentence: 'Papaya is good for health',
    amharic: 'ፓፓያ ለጤና ጥሩ ነው',
    extraWords: ['bad', 'sweet'],
  ),

  // ─── Vegetables ──────────────────────────────────────────────────────────
  StoryQuestion(
    imageAsset: 'assets/images/vegetables/carrot.jpg',
    sentence: 'Rabbits love to eat carrots',
    amharic: 'ጥንቸሎች ካሮት ይወዳሉ',
    extraWords: ['drink', 'run'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vegetables/tomato.jpg',
    sentence: 'The tomato is red',
    amharic: 'ቲማቲም ቀይ ነው',
    extraWords: ['green', 'big'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vegetables/corn.jpg',
    sentence: 'Corn grows tall in the field',
    amharic: 'በቆሎ ከፍ ብሎ ይበቅላል',
    extraWords: ['short', 'water'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vegetables/potato.jpg',
    sentence: 'We cook potatoes for dinner',
    amharic: 'ድንቹ ለእራት እናበስላለን',
    extraWords: ['eat', 'lunch'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vegetables/onion.jpg',
    sentence: 'Onions make my eyes water',
    amharic: 'ሽንኩርት ዓይኖቼን ያስለቅሳል',
    extraWords: ['nose', 'laugh'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vegetables/cabbage.jpg',
    sentence: 'Cabbage is a green vegetable',
    amharic: 'ጎምቴ አረንጓዴ አትክልት ነው',
    extraWords: ['red', 'fruit'],
  ),

  // ─── Vehicles ────────────────────────────────────────────────────────────
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/car.jpg',
    sentence: 'The car is very fast',
    amharic: 'መኪናው በጣም ፈጣን ነው',
    extraWords: ['slow', 'big'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/bus.jpg',
    sentence: 'Children ride the school bus',
    amharic: 'ልጆች የትምህርት ቤት አотобус ይጋልባሉ',
    extraWords: ['drive', 'train'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/airplane.jpg',
    sentence: 'The airplane flies in the sky',
    amharic: 'አውሮፕላን በሰማይ ይበራል',
    extraWords: ['swims', 'sea'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/train.jpg',
    sentence: 'The train is long and loud',
    amharic: 'ባቡሩ ረዥምና ጮሃ ነው',
    extraWords: ['short', 'quiet'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/bicycle.jpg',
    sentence: 'I ride my bicycle every day',
    amharic: 'ብስክሌቴን ሁልጊዜ እጋልባለሁ',
    extraWords: ['drive', 'week'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/boat.jpg',
    sentence: 'The boat sails on the water',
    amharic: 'ጀልባ በውሃ ላይ ይጓዛል',
    extraWords: ['flies', 'sky'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/helicopter.jpg',
    sentence: 'The helicopter flies up high',
    amharic: 'ሄሊኮፕተር ከፍ ብሎ ይበራል',
    extraWords: ['low', 'swims'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/fire_truck.jpg',
    sentence: 'Fire trucks are red and fast',
    amharic: 'የእሳት ማጥሰፊያ መኪናዎች ቀይ እና ፈጣን ናቸው',
    extraWords: ['blue', 'slow'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/vehicles/motorcycle.jpg',
    sentence: 'He rides a fast motorcycle',
    amharic: 'እርሱ ፈጣን ሞቶር ሳይክል ይጋልባል',
    extraWords: ['drives', 'slow'],
  ),

  // ─── Shapes ──────────────────────────────────────────────────────────────
  StoryQuestion(
    imageAsset: 'assets/images/shapes/circle.png',
    sentence: 'A circle has no corners',
    amharic: 'ክብ ምንም ማዕዘን የለውም',
    extraWords: ['sides', 'square'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/shapes/star.png',
    sentence: 'Stars shine bright at night',
    amharic: 'ኮከቦች ምሽት ያበራሉ',
    extraWords: ['day', 'dim'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/shapes/heart1.png',
    sentence: 'I draw a red heart',
    amharic: 'ቀይ ልብ እሳልላለሁ',
    extraWords: ['blue', 'write'],
  ),
  StoryQuestion(
    imageAsset: 'assets/images/shapes/triangle.png',
    sentence: 'A triangle has three sides',
    amharic: 'ሶስት ማዕዘን ሶስት ጎኖች አሉት',
    extraWords: ['four', 'circle'],
  ),
];
