import 'package:flutter/foundation.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../core/models/stock.dart';

/// Search Provider for managing search state without BLoC
class SearchProvider with ChangeNotifier {
  final ApiService _apiService;
  final StorageService _storageService;

  // State variables
  List<Stock> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _currentQuery = '';

  // Constructor
  SearchProvider({
    ApiService? apiService,
    required StorageService storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService {
    _loadSearchHistory();
  }

  // Getters
  List<Stock> get searchResults => _searchResults;
  List<String> get searchHistory => _searchHistory;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String get currentQuery => _currentQuery;
  bool get hasError => _errorMessage != null;
  bool get hasResults => _searchResults.isNotEmpty;
  bool get hasHistory => _searchHistory.isNotEmpty;

  /// Search for stocks
  Future<void> searchStocks(String query) async {
    if (query.trim().isEmpty) {
      _clearSearch();
      return;
    }

    try {
      _setLoading(true);
      _clearError();
      _currentQuery = query;

      // Use API to search for stocks
      final stocksData = await _apiService.searchStocks(query);
      _searchResults = stocksData.map((json) => Stock.fromJson(json)).toList();

      // Add to search history
      await _addToSearchHistory(query);

      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Clear search results
  void clearSearch() {
    _clearSearch();
  }

  /// Load search history from storage
  Future<void> _loadSearchHistory() async {
    try {
      _searchHistory = _storageService.getSearchHistory();
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to load search history: $e');
    }
  }

  /// Add query to search history
  Future<void> _addToSearchHistory(String query) async {
    try {
      await _storageService.addToSearchHistory(query);
      _searchHistory = _storageService.getSearchHistory();
    } catch (e) {
      debugPrint('Failed to add to search history: $e');
    }
  }

  /// Clear search history
  Future<void> clearSearchHistory() async {
    try {
      await _storageService.clearSearchHistory();
      _searchHistory = [];
      notifyListeners();
    } catch (e) {
      _setError('Failed to clear search history');
    }
  }

  /// Get popular Indian stocks
  Future<void> loadPopularStocks() async {
    try {
      _setLoading(true);
      _clearError();

      // Fetch popular Indian stocks from API
      final stocksData = await _apiService.getPopularIndianStocks();
      _searchResults = stocksData.map((json) => Stock.fromJson(json)).take(10).toList(); // Show only top 10 popular stocks
      _currentQuery = '';
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Search by symbol from history
  Future<void> searchFromHistory(String query) async {
    await searchStocks(query);
  }

  /// Get suggestions based on current query
  List<String> getSuggestions(String query) {
    if (query.isEmpty) return [];

    return _searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  // Private helper methods
  void _clearSearch() {
    _searchResults = [];
    _currentQuery = '';
    _clearError();
    notifyListeners();
  }

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
      return 'Search timed out. Please try again.';
    } else if (errorString.contains('404')) {
      return 'No stocks found. Try a different search term.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'Authentication failed. Please check API key.';
    } else if (errorString.contains('403')) {
      return 'Access denied. Please check API permissions.';
    } else {
      return 'Search failed. Please try again.';
    }
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
