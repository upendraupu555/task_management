import 'package:hive/hive.dart';

class HivePreferences {
  static late Box _box;

  static Future<void> init() async {
    _box = await Hive.openBox('preferences');
  }

  static bool getDarkMode() => _box.get('darkMode', defaultValue: false);
  static void setDarkMode(bool value) => _box.put('darkMode', value);

  static String getSortOrder() => _box.get('sortOrder', defaultValue: 'date');
  static void setSortOrder(String value) => _box.put('sortOrder', value);
}
