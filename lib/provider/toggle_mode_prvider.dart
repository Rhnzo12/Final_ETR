import 'package:flutter/material.dart';

class DarkModeProvider with ChangeNotifier {
  bool isDarkModeEnabled = false;

  bool get isDarkMode => isDarkModeEnabled;

  void toggleLightMode() {
    isDarkModeEnabled = !isDarkModeEnabled;
    notifyListeners();
  }
}
