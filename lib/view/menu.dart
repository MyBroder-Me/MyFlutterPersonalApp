import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/menu.dart';
import 'navigation/bottom_nav_bar.dart';
import 'navigation/horizontal_nav_bar.dart';
import 'navigation/menu_items.dart';

class Menu extends StatefulWidget {
  @override
  MenuState createState() => MenuState();
}

class MenuState extends State<Menu> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MenuModel(),
      child: Consumer<MenuModel>(
        builder: (context, model, child) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (MediaQuery.of(context).size.width > 450) {
              model.setShowNavigationRail(true);
            }
          });

          return Scaffold(
            body: GestureDetector(
              onTap: () {
                if (model.showNavigationRail &&
                    MediaQuery.of(context).size.width < 450) {
                  model.setShowNavigationRail(false);
                }
              },
              child: Stack(
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      Widget mainArea =
                          MainArea(selectedIndex: model.selectedIndex);

                      if (constraints.maxWidth < 450) {
                        // Layout móvil
                        return Column(
                          children: [
                            Expanded(child: mainArea),
                            BottomNavBar(
                              selectedIndex: model.selectedIndex < 2
                                  ? model.selectedIndex
                                  : 0,
                              onTap: model.onBottomNavTap,
                            ),
                          ],
                        );
                      } else {
                        // Layout para pantallas más grandes
                        return Scaffold(
                          body: GestureDetector(
                            onTap: () {
                              if (model.isRailExtended) {
                                model.setIsRailExtended(false);
                              }
                            },
                            child: Row(
                              children: [
                                if (model.showNavigationRail)
                                  GestureDetector(
                                    onTap: () {
                                      if (!model.isRailExtended) {
                                        model.setIsRailExtended(true);
                                      }
                                    },
                                    child: NavigationRailMenu(
                                      selectedIndex: model.selectedIndex,
                                      onDestinationSelected: (index) =>
                                          model.onRailDestinationSelected(
                                              index, context),
                                      isExtended: model.isRailExtended,
                                    ),
                                  ),
                                Expanded(child: mainArea),
                              ],
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  if (model.showNavigationRail &&
                      MediaQuery.of(context).size.width < 450)
                    Positioned(
                      left: 0,
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () {
                          model.setShowNavigationRail(false);
                        },
                        child: NavigationRailMenu(
                          selectedIndex: model.selectedIndex,
                          onDestinationSelected: (index) =>
                              model.onRailDestinationSelected(index, context),
                          isExtended:
                              false, // Ensure the rail is contracted when shown
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
