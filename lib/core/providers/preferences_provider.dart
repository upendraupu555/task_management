import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../database/hive_preferences.dart';

class PreferencesViewModel {
  bool isDarkMode = HivePreferences.getDarkMode();
  String sortOrder = HivePreferences.getSortOrder();

  void toggleDarkMode() {
    isDarkMode = !isDarkMode;
    HivePreferences.setDarkMode(isDarkMode);
  }

  void updateSortOrder(String newOrder) {
    sortOrder = newOrder;
    HivePreferences.setSortOrder(newOrder);
  }
}

final preferencesProvider = StateProvider((ref) => PreferencesViewModel());
