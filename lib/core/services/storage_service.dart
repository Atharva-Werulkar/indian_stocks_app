import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../constants/app_constants.dart';
import '../models/stock.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;
  static Box<String>? _watchlistBox;

  StorageService._();

  static StorageService get instance {
    _instance ??= StorageService._();
    return _instance!;
  }

  /// Initialize storage services
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _watchlistBox = await Hive.openBox<String>(AppConstants.watchlistKey);
  }

  /// Watchlist operations
  Future<List<Stock>> getWatchlist() async {
    try {
      final stocksJson = _watchlistBox?.values.toList() ?? [];
      return stocksJson
          .map((json) => Stock.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<void> addToWatchlist(Stock stock) async {
    try {
      final stockJson = jsonEncode(stock.toJson());
      await _watchlistBox?.put(stock.symbol, stockJson);
    } catch (e) {
      throw Exception('Failed to add stock to watchlist: $e');
    }
  }

  Future<void> removeFromWatchlist(String symbol) async {
    try {
      await _watchlistBox?.delete(symbol);
    } catch (e) {
      throw Exception('Failed to remove stock from watchlist: $e');
    }
  }

  Future<bool> isInWatchlist(String symbol) async {
    try {
      return _watchlistBox?.containsKey(symbol) ?? false;
    } catch (e) {
      return false;
    }
  }

  Future<void> clearWatchlist() async {
    try {
      await _watchlistBox?.clear();
    } catch (e) {
      throw Exception('Failed to clear watchlist: $e');
    }
  }

  /// Theme operations
  Future<void> setThemeMode(String themeMode) async {
    try {
      await _prefs?.setString(AppConstants.themeKey, themeMode);
    } catch (e) {
      throw Exception('Failed to save theme mode: $e');
    }
  }

  String getThemeMode() {
    try {
      return _prefs?.getString(AppConstants.themeKey) ?? 'system';
    } catch (e) {
      return 'system';
    }
  }

  /// Search history operations
  Future<void> addToSearchHistory(String query) async {
    try {
      const key = 'search_history';
      List<String> history = _prefs?.getStringList(key) ?? [];

      // Remove if already exists
      history.remove(query);

      // Add to beginning
      history.insert(0, query);

      // Keep only last 10 searches
      if (history.length > 10) {
        history = history.take(10).toList();
      }

      await _prefs?.setStringList(key, history);
    } catch (e) {
      // Ignore error for search history
    }
  }

  List<String> getSearchHistory() {
    try {
      const key = 'search_history';
      return _prefs?.getStringList(key) ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<void> clearSearchHistory() async {
    try {
      const key = 'search_history';
      await _prefs?.remove(key);
    } catch (e) {
      // Ignore error
    }
  }

  /// App settings
  Future<void> setAutoRefresh(bool enabled) async {
    try {
      await _prefs?.setBool('auto_refresh', enabled);
    } catch (e) {
      throw Exception('Failed to save auto refresh setting: $e');
    }
  }

  bool getAutoRefresh() {
    try {
      return _prefs?.getBool('auto_refresh') ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<void> setRefreshInterval(int minutes) async {
    try {
      await _prefs?.setInt('refresh_interval', minutes);
    } catch (e) {
      throw Exception('Failed to save refresh interval: $e');
    }
  }

  int getRefreshInterval() {
    try {
      return _prefs?.getInt('refresh_interval') ?? 5;
    } catch (e) {
      return 5;
    }
  }

  /// Cache operations
  Future<void> setCacheData(String key, String data) async {
    try {
      await _prefs?.setString('cache_$key', data);
    } catch (e) {
      // Ignore cache errors
    }
  }

  String? getCacheData(String key) {
    try {
      return _prefs?.getString('cache_$key');
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    try {
      final keys = _prefs?.getKeys() ?? <String>{};
      for (final key in keys) {
        if (key.startsWith('cache_')) {
          await _prefs?.remove(key);
        }
      }
    } catch (e) {
      // Ignore cache errors
    }
  }

  /// Clean up resources
  Future<void> dispose() async {
    await _watchlistBox?.close();
  }
}
