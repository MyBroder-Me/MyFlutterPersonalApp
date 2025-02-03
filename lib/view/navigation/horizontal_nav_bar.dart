import 'package:flutter/material.dart';

class NavigationRailMenu extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final bool isExtended;

  const NavigationRailMenu({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.isExtended,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: NavigationRail(
        extended: isExtended,
        destinations: const [
          NavigationRailDestination(
            icon: Icon(Icons.home),
            label: Text('Home'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.abc_rounded),
            label: Text('WordGenerator'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.favorite),
            label: Text('Favorites'),
          ),
          NavigationRailDestination(
            icon: Icon(Icons.person),
            label: Text('Profile'),
          ),
        ],
        selectedIndex: selectedIndex,
        onDestinationSelected: onDestinationSelected,
      ),
    );
  }
}
