import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  Future<ThemeMode> themeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? ThemeMode.dark.index;
    return ThemeMode.values[themeModeIndex];
  }

  Future<void> updateThemeMode(ThemeMode theme) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', theme.index);
  }

  // Last inn apiBaseUrl fra lokal lagring
  Future<String> apiBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('apiBaseUrl') ?? 'http://192.168.68.65:8090';
  }

  // Oppdater apiBaseUrl i lokal lagring
  Future<void> updateApiBaseUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('apiBaseUrl', url);
  }
}
