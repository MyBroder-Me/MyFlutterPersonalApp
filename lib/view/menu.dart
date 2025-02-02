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
        isRailExtended = false; // Ensure the rail is contracted when shown
      } else {
        selectedIndex = index;
        showNavigationRail = false;
      }
    });
  }

  void onRailDestinationSelected(int index) {
    setState(() {
      selectedIndex = index;
      if (MediaQuery.of(context).size.width < 450) {
        showNavigationRail = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          if (showNavigationRail && MediaQuery.of(context).size.width < 450) {
            setState(() {
              showNavigationRail = false;
            });
          }
        },
        child: Stack(
          children: [
            LayoutBuilder(
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
                        selectedIndex: 0,
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
                            onDestinationSelected: onRailDestinationSelected,
                            isExtended: isRailExtended,
                          ),
                        ),
                      Expanded(child: mainArea),
                    ],
                  );
                }
              },
            ),
            if (showNavigationRail && MediaQuery.of(context).size.width < 450)
              Positioned(
                left: 0,
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  // Hides the rail when tapping outside of it
                  onTap: () {
                    setState(() {
                      showNavigationRail = false;
                    });
                  },
                  child: NavigationRailMenu(
                    selectedIndex: selectedIndex,
                    onDestinationSelected: onRailDestinationSelected,
                    isExtended:
                        false, // Ensure the rail is contracted when shown
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
