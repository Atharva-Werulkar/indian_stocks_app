import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';
import 'logging_service.dart';
import 'error_handling_service.dart';
import 'performance_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  /// Get quote for a single stock
  Future<Map<String, dynamic>> getStockQuote(String symbol,
      {String? apiKey}) async {
    return await PerformanceService.trackOperation(
      'getStockQuote_$symbol',
      () async {
        try {
          final key = apiKey ?? ApiConstants.apiKey;
          final url = Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.quoteEndpoint}?symbol=$symbol&apikey=$key',
          );

          LoggingService.apiRequest('GET', url.toString());
          final response = await _client.get(url).timeout(
                const Duration(seconds: 30),
              );

          LoggingService.apiResponse(url.toString(), response.statusCode);

          if (response.statusCode == 200) {
            return json.decode(response.body);
          } else {
            throw Exception(
                'HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          ErrorHandlingService.handleApiError(e,
              endpoint: 'getStockQuote', showToUser: false);
          rethrow;
        }
      },
    );
  }

  /// Get quotes for multiple stocks
  Future<List<Map<String, dynamic>>> getMultipleStockQuotes(
    List<String> symbols, {
    String? apiKey,
  }) async {
    return await PerformanceService.trackOperation(
      'getMultipleStockQuotes',
      () async {
        try {
          final key = apiKey ?? ApiConstants.apiKey;
          final symbolsString = symbols.join(',');
          final url = Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.quoteEndpoint}?symbol=$symbolsString&apikey=$key',
          );

          LoggingService.apiRequest('GET', url.toString());
          final response = await _client.get(url).timeout(
                const Duration(seconds: 30),
              );

          LoggingService.apiResponse(url.toString(), response.statusCode);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);

            // Handle different response formats
            if (data is List) {
              return List<Map<String, dynamic>>.from(data);
            } else if (data is Map) {
              // When multiple stocks are requested, API returns an object with symbol keys
              final List<Map<String, dynamic>> result = [];
              data.forEach((key, value) {
                if (value is Map<String, dynamic>) {
                  result.add(value);
                }
              });
              return result;
            }
            return [];
          } else {
            throw Exception(
                'HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          ErrorHandlingService.handleApiError(e,
              endpoint: 'getMultipleStockQuotes', showToUser: false);
          rethrow;
        }
      },
    );
  }

  /// Get time series data for charts
  Future<Map<String, dynamic>> getTimeSeries({
    required String symbol,
    required String interval,
    String? startDate,
    String? endDate,
    int? outputsize,
    String? apiKey,
  }) async {
    return await PerformanceService.trackOperation(
      'getTimeSeries_$symbol',
      () async {
        try {
          final key = apiKey ?? ApiConstants.apiKey;
          var url =
              '${ApiConstants.baseUrl}${ApiConstants.timeSeriesEndpoint}?symbol=$symbol&interval=$interval&apikey=$key';

          if (startDate != null) url += '&start_date=$startDate';
          if (endDate != null) url += '&end_date=$endDate';
          if (outputsize != null) url += '&outputsize=$outputsize';

          LoggingService.apiRequest('GET', url);
          final response = await _client.get(Uri.parse(url)).timeout(
                const Duration(seconds: 30),
              );

          LoggingService.apiResponse(url, response.statusCode);

          if (response.statusCode == 200) {
            return json.decode(response.body);
          } else {
            throw Exception(
                'HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          ErrorHandlingService.handleApiError(e,
              endpoint: 'getTimeSeries', showToUser: false);
          rethrow;
        }
      },
    );
  }

  /// Search for stocks
  Future<List<Map<String, dynamic>>> searchStocks(String query,
      {String? apiKey}) async {
    return await PerformanceService.trackOperation(
      'searchStocks',
      () async {
        try {
          final key = apiKey ?? ApiConstants.apiKey;
          final url = Uri.parse(
            '${ApiConstants.baseUrl}${ApiConstants.searchEndpoint}?symbol=$query&apikey=$key',
          );

          LoggingService.apiRequest('GET', url.toString());
          final response = await _client.get(url).timeout(
                const Duration(seconds: 30),
              );

          LoggingService.apiResponse(url.toString(), response.statusCode);

          if (response.statusCode == 200) {
            final data = json.decode(response.body);
            if (data['data'] != null && data['data'] is List) {
              return List<Map<String, dynamic>>.from(data['data']);
            }
            return [];
          } else {
            throw Exception(
                'HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }
        } catch (e) {
          ErrorHandlingService.handleApiError(e,
              endpoint: 'searchStocks', showToUser: false);
          rethrow;
        }
      },
    );
  }

  /// Get popular Indian stocks data
  Future<List<Map<String, dynamic>>> getPopularIndianStocks(
      {String? apiKey}) async {
    try {
      return await getMultipleStockQuotes(AppConstants.popularStocks,
          apiKey: apiKey);
    } catch (e) {
      ErrorHandlingService.handleApiError(e,
          endpoint: 'getPopularIndianStocks', showToUser: false);
      rethrow;
    }
  }

  /// Get historical data for candlestick chart
  Future<Map<String, dynamic>> getCandlestickData({
    required String symbol,
    int days = 30,
    String? apiKey,
  }) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: days));

      return await getTimeSeries(
        symbol: symbol,
        interval: '1day',
        startDate: _formatDate(startDate),
        endDate: _formatDate(endDate),
        outputsize: days,
        apiKey: apiKey,
      );
    } catch (e) {
      ErrorHandlingService.handleApiError(e,
          endpoint: 'getCandlestickData', showToUser: false);
      rethrow;
    }
  }

  /// Get intraday data for line chart
  Future<Map<String, dynamic>> getIntradayData({
    required String symbol,
    String interval = '5min',
    String? apiKey,
  }) async {
    try {
      return await getTimeSeries(
        symbol: symbol,
        interval: interval,
        outputsize: 100,
        apiKey: apiKey,
      );
    } catch (e) {
      ErrorHandlingService.handleApiError(e,
          endpoint: 'getIntradayData', showToUser: false);
      rethrow;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  void dispose() {
    _client.close();
  }
}
