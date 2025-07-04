import 'dart:async';
import 'logging_service.dart';

/// Performance monitoring service for tracking app performance
class PerformanceService {
  static final Map<String, DateTime> _startTimes = {};
  static final Map<String, List<Duration>> _metrics = {};

  /// Start tracking an operation
  static void startOperation(String operationName) {
    _startTimes[operationName] = DateTime.now();
  }

  /// End tracking an operation and log the duration
  static Duration endOperation(String operationName) {
    final startTime = _startTimes.remove(operationName);
    if (startTime == null) {
      LoggingService.warning('Operation $operationName was not started');
      return Duration.zero;
    }

    final duration = DateTime.now().difference(startTime);

    // Store metric for analysis
    _metrics.putIfAbsent(operationName, () => []).add(duration);

    // Log the performance
    LoggingService.performance(operationName, duration);

    return duration;
  }

  /// Track a specific operation with automatic timing
  static Future<T> trackOperation<T>(
    String operationName,
    Future<T> Function() operation,
  ) async {
    startOperation(operationName);
    try {
      final result = await operation();
      endOperation(operationName);
      return result;
    } catch (error) {
      endOperation(operationName);
      rethrow;
    }
  }

  /// Track a synchronous operation
  static T trackSyncOperation<T>(
    String operationName,
    T Function() operation,
  ) {
    startOperation(operationName);
    try {
      final result = operation();
      endOperation(operationName);
      return result;
    } catch (error) {
      endOperation(operationName);
      rethrow;
    }
  }

  /// Get average duration for an operation
  static Duration? getAverageDuration(String operationName) {
    final durations = _metrics[operationName];
    if (durations == null || durations.isEmpty) return null;

    final totalMs = durations.fold<int>(
      0,
      (sum, duration) => sum + duration.inMilliseconds,
    );

    return Duration(milliseconds: totalMs ~/ durations.length);
  }

  /// Get all performance metrics
  static Map<String, Duration?> getAllMetrics() {
    final result = <String, Duration?>{};
    for (final operation in _metrics.keys) {
      result[operation] = getAverageDuration(operation);
    }
    return result;
  }

  /// Clear all metrics
  static void clearMetrics() {
    _metrics.clear();
    _startTimes.clear();
  }

  /// Log performance summary
  static void logPerformanceSummary() {
    final metrics = getAllMetrics();
    if (metrics.isEmpty) return;

    LoggingService.info('Performance Summary:', 'Performance');
    for (final entry in metrics.entries) {
      final duration = entry.value;
      if (duration != null) {
        LoggingService.info(
          '  ${entry.key}: ${duration.inMilliseconds}ms avg',
          'Performance',
        );
      }
    }
  }
}
