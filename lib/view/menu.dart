import 'package:flutter/material.dart';
import 'navigation/bottom_nav_bar.dart';
import 'navigation/horizontal_nav_bar.dart';
import 'navigation/menu_items.dart';

class Menu extends StatefulWidget {
  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  int selectedIndex = 0;
  bool showNavigationRail = false;
  bool isRailExtended = true;

  void onBottomNavTap(int index) {
    setState(() {
      if (index == 1) {
        showNavigationRail = true;
      } else {
        selectedIndex = index;
        showNavigationRail = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (isRailExtended && MediaQuery.of(context).size.width > 450) {
            setState(() {
              isRailExtended = false;
            });
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 450) {
              showNavigationRail = true;
            }

            Widget mainArea = MainArea(selectedIndex: selectedIndex);

            if (constraints.maxWidth < 450) {
              // Layout móvil
              return Column(
                children: [
                  Expanded(child: mainArea),
                  BottomNavBar(
                    selectedIndex: selectedIndex,
                    onTap: onBottomNavTap,
                  ),
                ],
              );
            } else {
              // Layout para pantallas más grandes
              return Row(
                children: [
                  if (showNavigationRail)
                    GestureDetector(
                      onTap: () {
                        if (!isRailExtended) {
                          setState(() {
                            isRailExtended = true;
                          });
                        }
                      },
                      child: NavigationRailMenu(
                        selectedIndex: selectedIndex,
                        onDestinationSelected: (value) {
                          setState(() {
                            selectedIndex = value;
                            isRailExtended = false;
                          });
                        },
                        isExtended: isRailExtended,
                      ),
                    ),
                  Expanded(child: mainArea),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
