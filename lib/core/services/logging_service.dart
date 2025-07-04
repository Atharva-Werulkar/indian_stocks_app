import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import '../constants/app_constants.dart';

/// Centralized logging service for the application
class LoggingService {
  static const String _tag = 'IndianStocksApp';

  /// Log an informational message
  static void info(String message, [String? tag]) {
    if (AppConstants.enableLogging || kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 800,
      );
    }
  }

  /// Log a warning message
  static void warning(String message, [String? tag]) {
    if (AppConstants.enableLogging || kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 900,
      );
    }
  }

  /// Log an error message
  static void error(String message,
      [dynamic error, StackTrace? stackTrace, String? tag]) {
    if (AppConstants.enableLogging || kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 1000,
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Log a debug message (only in debug mode)
  static void debug(String message, [String? tag]) {
    if (kDebugMode) {
      developer.log(
        message,
        name: tag ?? _tag,
        level: 700,
      );
    }
  }

  /// Log API requests
  static void apiRequest(String method, String url,
      [Map<String, dynamic>? data]) {
    if (AppConstants.enableLogging || kDebugMode) {
      final message = 'API $method: $url${data != null ? '\nData: $data' : ''}';
      info(message, 'API');
    }
  }

  /// Log API responses
  static void apiResponse(String url, int statusCode, [dynamic response]) {
    if (AppConstants.enableLogging || kDebugMode) {
      final message =
          'API Response: $url\nStatus: $statusCode${response != null ? '\nResponse: $response' : ''}';
      info(message, 'API');
    }
  }

  /// Log user actions for analytics
  static void userAction(String action, [Map<String, dynamic>? properties]) {
    if (AppConstants.enableLogging || kDebugMode) {
      final message =
          'User Action: $action${properties != null ? '\nProperties: $properties' : ''}';
      info(message, 'UserAction');
    }
  }

  /// Log performance metrics
  static void performance(String operation, Duration duration) {
    if (AppConstants.enableLogging || kDebugMode) {
      final message =
          'Performance: $operation took ${duration.inMilliseconds}ms';
      info(message, 'Performance');
    }
  }
}
