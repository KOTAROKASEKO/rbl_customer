import 'package:flutter/material.dart';

class Tabproviderservice extends ChangeNotifier {
  int tabIndex = 0;

  int getTabIndex() => tabIndex;

  void changeIndex(int newIndex) {
    tabIndex = newIndex;
    notifyListeners(); // Notify listeners about the change
  }
}
