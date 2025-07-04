import 'package:flutter_test/flutter_test.dart';
import 'package:indian_stocks_app/core/providers/settings_provider.dart';
import 'package:indian_stocks_app/core/constants/app_constants.dart';

void main() {
  group('SettingsProvider Tests', () {
    late SettingsProvider settingsProvider;

    setUp(() {
      settingsProvider = SettingsProvider();
    });

    group('Initial State', () {
      test('should have correct initial values', () {
        expect(settingsProvider.isInitialized, isFalse);
        expect(settingsProvider.userApiKey, isEmpty);
        expect(settingsProvider.useCustomApiKey, isFalse);
        expect(settingsProvider.isDarkMode, isFalse);
        expect(settingsProvider.enableNotifications, isTrue);
        expect(settingsProvider.priceAlerts, isTrue);
      });

      test('should return default API key when no custom key set', () {
        expect(settingsProvider.currentApiKey, equals(ApiConstants.apiKey));
      });
    });

    group('API Key Validation', () {
      test('should validate API key correctly', () {
        expect(settingsProvider.isValidApiKey(''), isFalse);
        expect(settingsProvider.isValidApiKey('short'), isFalse);
        expect(settingsProvider.isValidApiKey('valid_api_key_with_good_length'),
            isTrue);
        expect(settingsProvider.isValidApiKey('a' * 32), isTrue);
        expect(settingsProvider.isValidApiKey('a' * 51), isFalse);
      });
    });

    group('Current API Key Logic', () {
      test('should return default API key when custom key is disabled', () {
        settingsProvider.setUseCustomApiKey(false);
        expect(settingsProvider.currentApiKey, equals(ApiConstants.apiKey));
      });

      test('should return default API key when custom key is enabled but empty',
          () {
        settingsProvider.setUseCustomApiKey(true);
        expect(settingsProvider.currentApiKey, equals(ApiConstants.apiKey));
      });
    });

    group('Theme Settings', () {
      test('should toggle dark mode', () async {
        expect(settingsProvider.isDarkMode, isFalse);

        await settingsProvider.setDarkMode(true);
        expect(settingsProvider.isDarkMode, isTrue);

        await settingsProvider.setDarkMode(false);
        expect(settingsProvider.isDarkMode, isFalse);
      });
    });

    group('Notification Settings', () {
      test('should toggle notifications', () async {
        expect(settingsProvider.enableNotifications, isTrue);

        await settingsProvider.setNotificationsEnabled(false);
        expect(settingsProvider.enableNotifications, isFalse);

        await settingsProvider.setNotificationsEnabled(true);
        expect(settingsProvider.enableNotifications, isTrue);
      });

      test('should toggle price alerts', () async {
        expect(settingsProvider.priceAlerts, isTrue);

        await settingsProvider.setPriceAlertsEnabled(false);
        expect(settingsProvider.priceAlerts, isFalse);

        await settingsProvider.setPriceAlertsEnabled(true);
        expect(settingsProvider.priceAlerts, isTrue);
      });
    });

    group('Reset Settings', () {
      test('should reset all settings to defaults', () async {
        // Change some settings first
        await settingsProvider.setDarkMode(true);
        await settingsProvider.setNotificationsEnabled(false);
        await settingsProvider.setPriceAlertsEnabled(false);

        // Reset
        await settingsProvider.resetSettings();

        // Check defaults are restored
        expect(settingsProvider.isDarkMode, isFalse);
        expect(settingsProvider.enableNotifications, isTrue);
        expect(settingsProvider.priceAlerts, isTrue);
        expect(settingsProvider.userApiKey, isEmpty);
        expect(settingsProvider.useCustomApiKey, isFalse);
      });
    });
  });
}
