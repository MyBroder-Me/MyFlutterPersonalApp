import 'package:english_words/english_words.dart';

class WordPairState {
  WordPair current = WordPair.random();
  final List<WordPair> history = [];
  final Set<WordPair> favorites = {};

  void getNext() {
    history.insert(0, current);
    current = WordPair.random();
  }

  void toggleFavorite([WordPair? pair]) {
    pair = pair ?? current;
    if (favorites.contains(pair)) {
      favorites.remove(pair);
    } else {
      favorites.add(pair);
    }
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
  }
}
