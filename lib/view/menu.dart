import 'package:flutter/material.dart';
import 'navigation/bottom_nav_bar.dart';
import 'navigation/menu_items.dart';
import 'navigation/horizontal_nav_bar.dart';

class Menu extends StatefulWidget {
  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          Widget mainArea = MainArea(selectedIndex: selectedIndex);

          if (constraints.maxWidth < 450) {
            // Layout móvil
            return Column(
              children: [
                Expanded(child: mainArea),
                BottomNavBar(
                  selectedIndex: selectedIndex,
                  onTap: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
              ],
            );
          } else {
            // Layout para pantallas más grandes
            return Row(
              children: [
                NavigationRailMenu(
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                ),
                Expanded(child: mainArea),
              ],
            );
          }
        },
      ),
    );
  }
}
