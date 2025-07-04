import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../../../core/services/storage_service.dart';
import '../../../../core/models/stock.dart';

/// Watchlist Provider for managing watchlist state without BLoC
class WatchlistProvider with ChangeNotifier {
  final StorageService _storageService;

  // State variables
  List<Stock> _stocks = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Constructor
  WatchlistProvider({required StorageService storageService})
      : _storageService = storageService;

  // Getters
  List<Stock> get stocks => _stocks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get hasStocks => _stocks.isNotEmpty;
  int get stockCount => _stocks.length;

  /// Load watchlist from storage
  Future<void> loadWatchlist() async {
    try {
      _setLoading(true);
      _clearError();

      final stocks = await _storageService.getWatchlist();
      _stocks = stocks;
      notifyListeners();
    } catch (e) {
      _setError('Failed to load watchlist: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Add stock to watchlist
  Future<void> addToWatchlist(Stock stock) async {
    try {
      await _storageService.addToWatchlist(stock);
      await loadWatchlist(); // Reload to get updated list

      // Show success message
      Fluttertoast.showToast(
        msg:
            '${stock.symbol.replaceAll('.BSE', '').replaceAll('.NSE', '')} added to watchlist',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      _setError('Failed to add to watchlist: ${e.toString()}');

      Fluttertoast.showToast(
        msg: 'Failed to add to watchlist',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// Remove stock from watchlist
  Future<void> removeFromWatchlist(String symbol) async {
    try {
      await _storageService.removeFromWatchlist(symbol);
      await loadWatchlist(); // Reload to get updated list

      // Show success message
      Fluttertoast.showToast(
        msg: 'Removed from watchlist',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      _setError('Failed to remove from watchlist: ${e.toString()}');

      Fluttertoast.showToast(
        msg: 'Failed to remove from watchlist',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    }
  }

  /// Clear entire watchlist
  Future<void> clearWatchlist() async {
    try {
      await _storageService.clearWatchlist();
      _stocks = [];
      notifyListeners();

      Fluttertoast.showToast(
        msg: 'Watchlist cleared',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
      );
    } catch (e) {
      _setError('Failed to clear watchlist: ${e.toString()}');
    }
  }

  /// Update specific stock in watchlist
  Future<void> updateWatchlistStock(Stock stock) async {
    try {
      // Find and update the stock in local list
      final index = _stocks.indexWhere((s) => s.symbol == stock.symbol);
      if (index != -1) {
        _stocks[index] = stock;
        notifyListeners();

        // Update in storage
        await _storageService.addToWatchlist(stock);
      }
    } catch (e) {
      // Keep current state if update fails, don't show error for background updates
      debugPrint('Failed to update watchlist stock: $e');
    }
  }

  /// Check if stock is in watchlist
  bool isInWatchlist(String symbol) {
    return _stocks.any((stock) => stock.symbol == symbol);
  }

  /// Get stock from watchlist by symbol
  Stock? getWatchlistStock(String symbol) {
    try {
      return _stocks.firstWhere((stock) => stock.symbol == symbol);
    } catch (e) {
      return null;
    }
  }

  /// Toggle stock in watchlist (add if not present, remove if present)
  Future<void> toggleWatchlist(Stock stock) async {
    if (isInWatchlist(stock.symbol)) {
      await removeFromWatchlist(stock.symbol);
    } else {
      await addToWatchlist(stock);
    }
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

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
