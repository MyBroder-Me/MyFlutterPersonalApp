import 'package:flutter/material.dart';

class MenuModel extends ChangeNotifier {
  int _selectedIndex = 0;
  bool _showNavigationRail = false;
  bool _isRailExtended = true;

  int get selectedIndex => _selectedIndex;
  bool get showNavigationRail => _showNavigationRail;
  bool get isRailExtended => _isRailExtended;

  void setSelectedIndex(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void setShowNavigationRail(bool value) {
    _showNavigationRail = value;
    notifyListeners();
  }

  void setIsRailExtended(bool value) {
    _isRailExtended = value;
    notifyListeners();
  }

  void onBottomNavTap(int index) {
    if (index == 1) {
      setShowNavigationRail(true);
      setIsRailExtended(false); // Ensure the rail is contracted when shown
    } else {
      setSelectedIndex(index);
      setShowNavigationRail(false);
    }
  }

  void onRailDestinationSelected(int index, BuildContext context) {
    setSelectedIndex(index);
    if (MediaQuery.of(context).size.width < 450) {
      setShowNavigationRail(false);
    }
  }
}
