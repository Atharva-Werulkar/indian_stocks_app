import 'package:flutter/foundation.dart';

import '../../../../core/services/api_service.dart';
import '../../../../core/services/api_key_service.dart';
import '../../../../core/models/stock.dart';
import '../../data/models/chart_data.dart';
import '../../../../shared/widgets/syncfusion_stock_chart.dart';
import '../../../../core/utils/sample_data_generator.dart';

// Enums are now imported from syncfusion_stock_chart.dart

/// Stock Detail Provider for managing stock detail state without BLoC
class StockDetailProvider with ChangeNotifier {
  final ApiService _apiService;
  final ApiKeyService _apiKeyService = ApiKeyService();

  // State variables
  Stock? _stock;
  List<ChartDataPoint> _chartData = [];
  List<CandlestickData> _candlestickData = [];
  ChartType _chartType = ChartType.line;
  ChartPeriod _period = ChartPeriod.oneDay;
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastUpdated;
  String? _currentSymbol;

  // Constructor
  StockDetailProvider({required ApiService apiService})
      : _apiService = apiService;

  // Getters
  Stock? get stock => _stock;
  List<ChartDataPoint> get chartData => _chartData;
  List<CandlestickData> get candlestickData => _candlestickData;
  ChartType get chartType => _chartType;
  ChartPeriod get period => _period;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  DateTime? get lastUpdated => _lastUpdated;
  String? get currentSymbol => _currentSymbol;
  bool get hasError => _errorMessage != null;
  bool get hasData => _stock != null;

  /// Load stock detail data
  Future<void> loadStockDetail({
    required String symbol,
    ChartType? chartType,
    ChartPeriod? period,
  }) async {
    try {
      _setLoading(true);
      _clearError();
      _currentSymbol = symbol;

      if (chartType != null) _chartType = chartType;
      if (period != null) _period = period;

      // Load stock quote
      final stockData = await _apiService.getStockQuote(symbol,
          apiKey: _apiKeyService.getCurrentApiKey());
      _stock = Stock.fromStockModelJson(stockData);

      // Load chart data based on type
      if (_chartType == ChartType.line) {
        _chartData = await _loadLineChartData(symbol, _period);
        _candlestickData = [];
      } else {
        _candlestickData = await _loadCandlestickData(symbol, _period);
        _chartData = [];
      }

      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Load chart data only (when switching chart type or period)
  Future<void> loadChartData({
    required String symbol,
    required ChartType chartType,
    required ChartPeriod period,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      _chartType = chartType;
      _period = period;

      // Load chart data based on type
      if (chartType == ChartType.line) {
        _chartData = await _loadLineChartData(symbol, period);
        _candlestickData = [];
      } else {
        _candlestickData = await _loadCandlestickData(symbol, period);
        _chartData = [];
      }

      _lastUpdated = DateTime.now();
      notifyListeners();
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Refresh stock detail data
  Future<void> refreshStockDetail({
    required String symbol,
    ChartType? chartType,
    ChartPeriod? period,
  }) async {
    return loadStockDetail(
      symbol: symbol,
      chartType: chartType ?? _chartType,
      period: period ?? _period,
    );
  }

  /// Change chart type
  Future<void> changeChartType(ChartType chartType) async {
    if (_currentSymbol != null && chartType != _chartType) {
      await loadChartData(
        symbol: _currentSymbol!,
        chartType: chartType,
        period: _period,
      );
    }
  }

  /// Change chart period
  Future<void> changePeriod(ChartPeriod period) async {
    if (_currentSymbol != null && period != _period) {
      await loadChartData(
        symbol: _currentSymbol!,
        chartType: _chartType,
        period: period,
      );
    }
  }

  // Private helper methods
  Future<List<ChartDataPoint>> _loadLineChartData(
      String symbol, ChartPeriod period) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: period.days));

      final timeSeriesData = await _apiService.getTimeSeries(
        symbol: symbol,
        interval: period.apiInterval,
        startDate: startDate.toIso8601String().split('T')[0],
        endDate: endDate.toIso8601String().split('T')[0],
        apiKey: _apiKeyService.getCurrentApiKey(),
      );

      // Parse time series data to chart data points
      final values = timeSeriesData['values'] as List<dynamic>?;
      if (values == null || values.isEmpty) {
        // Fallback to sample data if no API data available
        return SampleDataGenerator.generateDataForPeriod(
          period.days,
          startPrice: 1000.0,
          pattern: 'normal',
        );
      }

      return values.map<ChartDataPoint>((item) {
        return ChartDataPoint(
          timestamp: DateTime.parse(item['datetime']),
          value: double.tryParse(item['close'].toString()) ?? 0.0,
          label: item['datetime'],
        );
      }).toList()
        ..sort((a, b) =>
            a.timestamp.compareTo(b.timestamp)); // Sort by timestamp ascending
    } catch (e) {
      debugPrint('Error loading line chart data: $e, using sample data');
      // Return sample data as fallback
      return SampleDataGenerator.generateDataForPeriod(
        period.days,
        startPrice: 1000.0,
        pattern: 'volatile',
      );
    }
  }

  Future<List<CandlestickData>> _loadCandlestickData(
      String symbol, ChartPeriod period) async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(Duration(days: period.days));

      final timeSeriesData = await _apiService.getTimeSeries(
        symbol: symbol,
        interval: period.apiInterval,
        startDate: startDate.toIso8601String().split('T')[0],
        endDate: endDate.toIso8601String().split('T')[0],
        apiKey: _apiKeyService.getCurrentApiKey(),
      );

      // Parse time series data to candlestick data
      final values = timeSeriesData['values'] as List<dynamic>?;
      if (values == null || values.isEmpty) {
        // Fallback to sample candlestick data
        return SampleDataGenerator.generateBullishCandlesticks(
          days: period.days,
          startPrice: 1000.0,
        );
      }

      return values.map<CandlestickData>((item) {
        return CandlestickData(
          timestamp: DateTime.parse(item['datetime']),
          open: double.tryParse(item['open'].toString()) ?? 0.0,
          high: double.tryParse(item['high'].toString()) ?? 0.0,
          low: double.tryParse(item['low'].toString()) ?? 0.0,
          close: double.tryParse(item['close'].toString()) ?? 0.0,
          volume: int.tryParse(item['volume']?.toString() ?? '0') ?? 0,
        );
      }).toList()
        ..sort((a, b) =>
            a.timestamp.compareTo(b.timestamp)); // Sort by timestamp ascending
    } catch (e) {
      debugPrint('Error loading candlestick data: $e, using sample data');
      // Return sample candlestick data as fallback
      return SampleDataGenerator.generateCandlestickData(
        days: period.days,
        startPrice: 1000.0,
        volatility: 0.05,
      );
    }
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
      return 'Request timed out. Please try again.';
    } else if (errorString.contains('404')) {
      return 'Stock data not found. Please try again later.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('unauthorized') ||
        errorString.contains('401')) {
      return 'Authentication failed. Please check API key.';
    } else if (errorString.contains('403')) {
      return 'Access denied. Please check API permissions.';
    } else {
      return 'Failed to load stock details. Please try again.';
    }
  }

  @override
  void dispose() {
    // Clean up resources if needed
    super.dispose();
  }
}
