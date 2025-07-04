import 'package:flutter/foundation.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/models/stock.dart';

/// Dashboard Provider for managing dashboard state without BLoC
class DashboardProvider with ChangeNotifier {
  final ApiService _apiService;

  // State variables
  List<Stock> _stocks = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;

  // Constructor
  DashboardProvider({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // Getters
  List<Stock> get stocks => _stocks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  bool get hasError => _errorMessage != null;
  bool get hasData => _stocks.isNotEmpty;

  /// Load dashboard data
  Future<void> loadDashboardData() async {
    try {
      _setLoading(true);
      _clearError();

      // Fetch popular Indian stocks from API
      final stocksData = await _apiService.getPopularIndianStocks();
      _stocks = stocksData.map((json) => Stock.fromJson(json)).toList();
      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh dashboard data
  Future<void> refreshDashboardData() async {
    try {
      // Don't show loading if we already have data
      if (_stocks.isEmpty) {
        _setLoading(true);
      }
      _clearError();

      // Fetch popular Indian stocks from API
      final stocksData = await _apiService.getPopularIndianStocks();
      _stocks = stocksData.map((json) => Stock.fromJson(json)).toList();
      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Update specific stock data
  void updateStockData(List<Stock> stocks) {
    _stocks = stocks;
    _lastUpdated = DateTime.now();
    notifyListeners();
  }

  /// Get stock by symbol
  Stock? getStockBySymbol(String symbol) {
    try {
      return _stocks.firstWhere((stock) => stock.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  /// Search stocks by query
  List<Stock> searchStocks(String query) {
    if (query.isEmpty) return _stocks;

    final lowercaseQuery = query.toLowerCase();
    return _stocks
        .where((stock) =>
            stock.symbol.toLowerCase().contains(lowercaseQuery) ||
            stock.name.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  /// Get top gainers
  List<Stock> getTopGainers({int limit = 5}) {
    final gainers = _stocks.where((stock) => stock.changePercent > 0).toList();
    gainers.sort((a, b) => b.changePercent.compareTo(a.changePercent));
    return gainers.take(limit).toList();
  }

  /// Get top losers
  List<Stock> getTopLosers({int limit = 5}) {
    final losers = _stocks.where((stock) => stock.changePercent < 0).toList();
    losers.sort((a, b) => a.changePercent.compareTo(b.changePercent));
    return losers.take(limit).toList();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  String _getErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('connection') ||
        errorString.contains('internet')) {
      return 'No internet connection. Please check your network and try again.';
    } else if (errorString.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('404')) {
      return 'Data not found. Please try again later.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'Authentication failed. Please check API key.';
    } else if (errorString.contains('403')) {
      return 'Access denied. Please check API permissions.';
    } else {
      return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
