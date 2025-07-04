import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// API Configuration
class ApiConstants {
  static const String baseUrl = 'https://api.twelvedata.com';

  // Get API key from environment variables or fallback to embedded key for demo
  static String get apiKey =>
      dotenv.env['TWELVE_DATA_API_KEY'] ?? 'ccb56c55d594460fb390386e63d93a83';

  // Endpoints
  static const String stocksEndpoint = '/stocks';
  static const String quoteEndpoint = '/quote';
  static const String timeSeriesEndpoint = '/time_series';
  static const String searchEndpoint = '/symbol_search';
}

// App Configuration
class AppConstants {
  static String get appName => dotenv.env['APP_NAME'] ?? 'Indian Stocks';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get isDebug => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  static bool get enableLogging =>
      dotenv.env['ENABLE_LOGGING']?.toLowerCase() == 'true';

  // Storage Keys
  static const String watchlistKey = 'watchlist';
  static const String themeKey = 'theme_mode';
  static const String apiKeyKey = 'user_api_key';
  static const String useCustomApiKey = 'use_custom_api_key';

  // Popular Indian Stocks
  static const List<String> popularStocks = [
    'TCS',
    'INFY',
    // 'RELIANCE.BSE',
    // 'HDFCBANK.BSE',
    // 'ICICIBANK.BSE',
    // 'BHARTIARTL.BSE',
    // 'ITC.BSE',
    // 'HINDUNILVR.BSE',
    // 'LT.BSE',
    // 'SBIN.BSE',
    // 'KOTAKBANK.BSE',
    // 'BAJFINANCE.BSE',
    // 'ASIANPAINT.BSE',
    // 'MARUTI.BSE',
    // 'TITAN.BSE',
    // 'TECHM.BSE',
    // 'HCLTECH.BSE',
    // 'WIPRO.BSE',
    // 'ULTRACEMCO.BSE',
    // 'SUNPHARMA.BSE',
  ];

  // Chart Constants
  static const int defaultChartDays = 30;
  static const int maxChartDays = 365;

  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 300);
  static const Duration mediumAnimation = Duration(milliseconds: 500);
  static const Duration longAnimation = Duration(milliseconds: 800);
}

// UI Constants
class UIConstants {
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;

  static const double defaultRadius = 12.0;
  static const double smallRadius = 8.0;
  static const double largeRadius = 20.0;

  static const double cardElevation = 8.0;
  static const double buttonElevation = 4.0;
}

// Color Constants
class ColorConstants {
  static const Color primaryGreen = Color(0xFF00C853);
  static const Color primaryRed = Color(0xFFFF5252);
  static const Color accentBlue = Color(0xFF2196F3);
  static const Color accentPurple = Color(0xFF9C27B0);

  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color darkBackground = Color(0xFF121212);

  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color darkSurface = Color(0xFF1E1E1E);
}
