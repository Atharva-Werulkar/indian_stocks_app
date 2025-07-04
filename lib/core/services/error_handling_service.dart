import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'logging_service.dart';

/// Centralized error handling service
class ErrorHandlingService {
  /// Handle and display errors to users
  static void handleError(
    dynamic error, {
    StackTrace? stackTrace,
    String? context,
    bool showToUser = true,
    String? userMessage,
  }) {
    // Log the error
    LoggingService.error(
      'Error${context != null ? ' in $context' : ''}: $error',
      error,
      stackTrace,
    );

    // Show user-friendly message if requested
    if (showToUser) {
      final message = userMessage ?? _getErrorMessage(error);
      _showErrorToUser(message);
    }
  }

  /// Show error message to user via toast
  static void _showErrorToUser(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 14.0,
    );
  }

  /// Convert technical errors to user-friendly messages
  static String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('socket')) {
      return 'Network connection error. Please check your internet connection.';
    }

    if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (errorString.contains('unauthorized') || errorString.contains('401')) {
      return 'Authentication failed. Please check your API key.';
    }

    if (errorString.contains('forbidden') || errorString.contains('403')) {
      return 'Access denied. Please check your permissions.';
    }

    if (errorString.contains('not found') || errorString.contains('404')) {
      return 'Requested data not found.';
    }

    if (errorString.contains('server') || errorString.contains('500')) {
      return 'Server error. Please try again later.';
    }

    if (errorString.contains('format') || errorString.contains('parse')) {
      return 'Data format error. Please try again.';
    }

    // Default fallback message
    return 'An unexpected error occurred. Please try again.';
  }

  /// Handle specific API errors
  static void handleApiError(
    dynamic error, {
    String? endpoint,
    bool showToUser = true,
  }) {
    handleError(
      error,
      context: endpoint != null ? 'API call to $endpoint' : 'API call',
      showToUser: showToUser,
    );
  }

  /// Handle widget build errors
  static Widget handleWidgetError(
    FlutterErrorDetails details, {
    String? fallbackMessage,
  }) {
    LoggingService.error(
      'Widget build error: ${details.exception}',
      details.exception,
      details.stack,
    );

    return Material(
      color: Colors.red.shade50,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                fallbackMessage ?? 'Something went wrong',
                style: TextStyle(
                  color: Colors.red.shade800,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              if (kDebugMode) ...[
                const SizedBox(height: 8),
                Text(
                  details.exception.toString(),
                  style: TextStyle(
                    color: Colors.red.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
