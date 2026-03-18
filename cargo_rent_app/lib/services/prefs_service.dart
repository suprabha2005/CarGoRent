import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const String _keyOnboarded      = 'is_onboarded';
  static const String _keyLastSearchType = 'last_search_type';
  static const String _keyLastSearchText = 'last_search_text';
  static const String _keyDarkMode       = 'dark_mode';

  // ── Onboarding ───────────────────────────────────────
  static Future<bool> isOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyOnboarded) ?? false;
  }

  static Future<void> setOnboarded() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyOnboarded, true);
  }

  // ── Last search ──────────────────────────────────────
  static Future<String?> getLastSearchType() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearchType);
  }

  static Future<void> saveLastSearch({
    required String type,
    required String text,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSearchType, type);
    await prefs.setString(_keyLastSearchText, text);
  }

  static Future<String?> getLastSearchText() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastSearchText);
  }

  // ── Dark mode ────────────────────────────────────────
  static Future<bool> isDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  static Future<void> setDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyDarkMode, value);
  }

  // ── Clear all ────────────────────────────────────────
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}