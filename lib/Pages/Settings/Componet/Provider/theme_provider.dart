// ignore_for_file: unused_local_variable

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Theme/components/app_colors_themes.dart';

class ThemeProvider with ChangeNotifier {
  Future<void> getSavedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('themeMode') ?? 0; // Default theme name
    final savedPrimaryColorIndex = prefs.getInt('primaryColor') ?? 0; // Default theme name
    notifyListeners();
  }

  ThemeMode selectedThemeMode = appThemes[0].mode;
  Color selectedPrimaryColor = AppColors.primaryColors[0];

  ThemeProvider() {
    // Load saved preferences on initialization
    loadSavedPreferences();
  }

  Future<void> loadSavedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    ThemeMode? savedThemeMode = ThemeMode.values[prefs.getInt('themeMode') ?? 0];
    Color savedPrimaryColor = Color(prefs.getInt('primaryColor') ?? AppColors.primaryColors[0].value);

    setSelectedThemeMode(savedThemeMode);
    setSelectedPrimaryColor(savedPrimaryColor);
  }

  setSelectedThemeMode(ThemeMode _themeMode) async {
    selectedThemeMode = _themeMode;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeMode', _themeMode.index);
  }

  setSelectedPrimaryColor(Color _color) async {
    selectedPrimaryColor = _color;
    notifyListeners();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('primaryColor', _color.value);
  }
}
