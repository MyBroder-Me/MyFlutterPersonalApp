import 'package:flutter/material.dart';

import '../../controller/pages/profile_page.dart';
import '../wordpair/favorites_page.dart';
import '../wordpair/generator_page.dart';

class MainArea extends StatelessWidget {
  final int selectedIndex;

  const MainArea({super.key, required this.selectedIndex});

  @override
  Widget build(BuildContext context) {
    late Widget page;
    switch (selectedIndex) {
      case 0:
        page = Placeholder();
        break;
      case 1:
        page = GeneratorPage();
        break;
      case 2:
        page = FavoritesPage();
        break;
      case 3:
        page = ProfilePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: page,
      ),
    );
  }
}
