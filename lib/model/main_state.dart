import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'wordpair/wordpair_state.dart';

class MyAppState extends ChangeNotifier {
  final WordPairState wordPairState = WordPairState();
  GlobalKey? historyListKey;
  Session? _session;

  WordPair get current => wordPairState.current;
  List<WordPair> get history => wordPairState.history;
  Set<WordPair> get favorites => wordPairState.favorites;
  Session? get session => _session;
  void getNext() {
    wordPairState.getNext();
    var animatedList = historyListKey?.currentState as AnimatedListState?;
    animatedList?.insertItem(0);
    notifyListeners();
  }

  void toggleFavorite([WordPair? pair]) {
    wordPairState.toggleFavorite(pair);
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    wordPairState.removeFavorite(pair);
    notifyListeners();
  }

  void updateSession(Session? session) {
    _session = session;
    notifyListeners();
  }
}
