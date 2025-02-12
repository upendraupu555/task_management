import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

final sortProvider = StateNotifierProvider<SortNotifier, String>((ref) {
  return SortNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _loadTheme();
  }

  void _loadTheme() async {
    final box = await Hive.openBox('settings');
    final isDark = box.get('isDarkMode', defaultValue: false);
    state = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  void toggleTheme() async {
    final box = await Hive.openBox('settings');
    final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    state = newTheme;
    box.put('isDarkMode', newTheme == ThemeMode.dark);
  }
}

class SortNotifier extends StateNotifier<String> {
  SortNotifier() : super(sortValue) {
    _loadSortValue();
  }

  static String sortValue = "date";

  void _loadSortValue() async {
    final box = await Hive.openBox('settings');
    sortValue = box.get('sortValue', defaultValue: 'date');
    state = sortValue;
  }

  changeSortValue(String newValue) async {
    // sortValue = newValue;
    final box = await Hive.openBox('settings');
    state = newValue;
    box.put('sortValue', newValue);
  }
}
