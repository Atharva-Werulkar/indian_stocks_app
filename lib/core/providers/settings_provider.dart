import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class SettingsProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // API Key settings
  String _userApiKey = '';
  bool _useCustomApiKey = false;

  // Theme settings
  bool _isDarkMode = false;

  // Notification settings
  bool _enableNotifications = true;
  bool _priceAlerts = true;

  // Getters
  bool get isInitialized => _isInitialized;
  String get userApiKey => _userApiKey;
  bool get useCustomApiKey => _useCustomApiKey;
  bool get isDarkMode => _isDarkMode;
  bool get enableNotifications => _enableNotifications;
  bool get priceAlerts => _priceAlerts;

  String get currentApiKey {
    return _useCustomApiKey && _userApiKey.isNotEmpty
        ? _userApiKey
        : ApiConstants.apiKey;
  }

  /// Initialize settings from SharedPreferences
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();

      // Load API key settings
      _userApiKey = _prefs.getString(AppConstants.apiKeyKey) ?? '';
      _useCustomApiKey = _prefs.getBool(AppConstants.useCustomApiKey) ?? false;

      // Load theme settings
      _isDarkMode = _prefs.getBool(AppConstants.themeKey) ?? false;

      // Load notification settings
      _enableNotifications = _prefs.getBool('enable_notifications') ?? true;
      _priceAlerts = _prefs.getBool('price_alerts') ?? true;

      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error initializing settings: $e');
    }
  }

  /// Set user's custom API key
  Future<void> setApiKey(String apiKey) async {
    try {
      _userApiKey = apiKey.trim();
      await _prefs.setString(AppConstants.apiKeyKey, _userApiKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving API key: $e');
    }
  }

  /// Toggle between custom and default API key
  Future<void> setUseCustomApiKey(bool useCustom) async {
    try {
      _useCustomApiKey = useCustom;
      await _prefs.setBool(AppConstants.useCustomApiKey, _useCustomApiKey);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving API key preference: $e');
    }
  }

  /// Clear user's API key
  Future<void> clearApiKey() async {
    try {
      _userApiKey = '';
      _useCustomApiKey = false;
      await _prefs.remove(AppConstants.apiKeyKey);
      await _prefs.setBool(AppConstants.useCustomApiKey, false);
      notifyListeners();
    } catch (e) {
      debugPrint('Error clearing API key: $e');
    }
  }

  /// Toggle dark mode
  Future<void> setDarkMode(bool isDark) async {
    try {
      _isDarkMode = isDark;
      await _prefs.setBool(AppConstants.themeKey, _isDarkMode);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Set notifications enabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    try {
      _enableNotifications = enabled;
      await _prefs.setBool('enable_notifications', _enableNotifications);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving notification preference: $e');
    }
  }

  /// Set price alerts enabled
  Future<void> setPriceAlertsEnabled(bool enabled) async {
    try {
      _priceAlerts = enabled;
      await _prefs.setBool('price_alerts', _priceAlerts);
      notifyListeners();
    } catch (e) {
      debugPrint('Error saving price alerts preference: $e');
    }
  }

  /// Reset all settings to defaults
  Future<void> resetSettings() async {
    try {
      await _prefs.clear();
      _userApiKey = '';
      _useCustomApiKey = false;
      _isDarkMode = false;
      _enableNotifications = true;
      _priceAlerts = true;
      notifyListeners();
    } catch (e) {
      debugPrint('Error resetting settings: $e');
    }
  }

  /// Validate API key format
  bool isValidApiKey(String apiKey) {
    if (apiKey.isEmpty) return false;
    // Basic validation - TwelveData API keys are typically 32 characters
    return apiKey.length >= 20 && apiKey.length <= 50;
  }
}
