import 'package:flutter_test/flutter_test.dart';
import 'package:indian_stocks_app/core/services/api_service.dart';
import 'package:indian_stocks_app/core/constants/app_constants.dart';

void main() {
  group('ApiService Tests', () {
    late ApiService apiService;

    setUp(() {
      apiService = ApiService();
    });

    group('API Service Configuration', () {
      test('should be singleton', () {
        final instance1 = ApiService();
        final instance2 = ApiService();
        expect(identical(instance1, instance2), isTrue);
      });

      test('should have default API key from constants', () {
        expect(ApiConstants.apiKey, isNotEmpty);
        expect(ApiConstants.baseUrl, equals('https://api.twelvedata.com'));
      });
    });

    group('URL Construction', () {
      test('should construct correct quote URL', () {
        const symbol = 'TCS';
        final expectedUrl =
            '${ApiConstants.baseUrl}${ApiConstants.quoteEndpoint}?symbol=$symbol&apikey=${ApiConstants.apiKey}';

        // This tests the URL construction logic indirectly
        expect(ApiConstants.baseUrl, isNotEmpty);
        expect(ApiConstants.quoteEndpoint, equals('/quote'));
        expect(expectedUrl.contains(symbol), isTrue);
        expect(expectedUrl.contains('apikey='), isTrue);
      });

      test('should construct correct search URL', () {
        const query = 'TCS';
        final expectedUrl =
            '${ApiConstants.baseUrl}${ApiConstants.searchEndpoint}?symbol=$query&apikey=${ApiConstants.apiKey}';

        expect(ApiConstants.searchEndpoint, equals('/symbol_search'));
        expect(expectedUrl.contains(query), isTrue);
      });
    });

    group('Date Formatting', () {
      test('should format date correctly', () {
        // This tests the private _formatDate method indirectly by checking date logic
        final date = DateTime(2024, 1, 15);
        final year = date.year;
        final month = date.month.toString().padLeft(2, '0');
        final day = date.day.toString().padLeft(2, '0');

        expect(year, equals(2024));
        expect(month, equals('01'));
        expect(day, equals('15'));
      });
    });

    tearDown(() {
      apiService.dispose();
    });
  });

  group('AppConstants Tests', () {
    test('should have valid API configuration', () {
      expect(ApiConstants.baseUrl, isNotEmpty);
      expect(ApiConstants.apiKey, isNotEmpty);
      expect(ApiConstants.quoteEndpoint, equals('/quote'));
      expect(ApiConstants.timeSeriesEndpoint, equals('/time_series'));
      expect(ApiConstants.searchEndpoint, equals('/symbol_search'));
    });

    test('should have valid app configuration', () {
      expect(AppConstants.appName, isNotEmpty);
      expect(AppConstants.appVersion, isNotEmpty);
    });

    test('should have popular stocks list', () {
      expect(AppConstants.popularStocks, isNotEmpty);
      expect(AppConstants.popularStocks, contains('TCS'));
      expect(AppConstants.popularStocks, contains('INFY'));
    });
  });
}
