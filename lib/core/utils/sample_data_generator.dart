import 'dart:math';
import '../../features/stock_detail/data/models/chart_data.dart';

/// Utility class for generating sample chart data for testing and development
class SampleDataGenerator {
  static final Random _random = Random();

  /// Generate sample line chart data points
  static List<ChartDataPoint> generateLineChartData({
    int days = 30,
    double startPrice = 1000.0,
    double volatility = 0.05,
  }) {
    final data = <ChartDataPoint>[];
    final startDate = DateTime.now().subtract(Duration(days: days));
    double currentPrice = startPrice;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));

      // Add some realistic price movement with volatility
      final change = (_random.nextDouble() - 0.5) * 2 * volatility;
      currentPrice = currentPrice * (1 + change);

      // Ensure price doesn't go negative
      currentPrice = currentPrice.clamp(startPrice * 0.5, startPrice * 2.0);

      data.add(ChartDataPoint(
        timestamp: date,
        value: currentPrice,
        label: date.toString().split(' ')[0],
      ));
    }

    return data;
  }

  /// Generate sample candlestick chart data
  static List<CandlestickData> generateCandlestickData({
    int days = 30,
    double startPrice = 1000.0,
    double volatility = 0.05,
  }) {
    final data = <CandlestickData>[];
    final startDate = DateTime.now().subtract(Duration(days: days));
    double previousClose = startPrice;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));

      // Generate OHLC data with realistic patterns
      final open =
          previousClose + (_random.nextDouble() - 0.5) * volatility * 10;
      final high = open + _random.nextDouble() * volatility * 50;
      final low = open - _random.nextDouble() * volatility * 50;
      final close = low + _random.nextDouble() * (high - low);

      // Generate volume (10k to 100k)
      final volume = 10000 + _random.nextInt(90000);

      data.add(CandlestickData(
        timestamp: date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      previousClose = close;
    }

    return data;
  }

  /// Generate trending stock data with positive bias
  static List<ChartDataPoint> generateTrendingData({
    int days = 30,
    double startPrice = 1000.0,
    double trendStrength = 0.02,
  }) {
    final data = <ChartDataPoint>[];
    final startDate = DateTime.now().subtract(Duration(days: days));
    double currentPrice = startPrice;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));

      // Add trend bias plus some volatility
      final trend = trendStrength * (i / days);
      final volatility = (_random.nextDouble() - 0.5) * 0.03;
      currentPrice = currentPrice * (1 + trend + volatility);

      data.add(ChartDataPoint(
        timestamp: date,
        value: currentPrice,
        label: date.toString().split(' ')[0],
      ));
    }

    return data;
  }

  /// Generate declining stock data with negative bias
  static List<ChartDataPoint> generateDecliningData({
    int days = 30,
    double startPrice = 1000.0,
    double declineRate = 0.015,
  }) {
    final data = <ChartDataPoint>[];
    final startDate = DateTime.now().subtract(Duration(days: days));
    double currentPrice = startPrice;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));

      // Add decline bias plus some volatility
      final decline = -declineRate * (i / days);
      final volatility = (_random.nextDouble() - 0.5) * 0.03;
      currentPrice = currentPrice * (1 + decline + volatility);

      data.add(ChartDataPoint(
        timestamp: date,
        value: currentPrice,
        label: date.toString().split(' ')[0],
      ));
    }

    return data;
  }

  /// Generate volatile stock data with high price swings
  static List<ChartDataPoint> generateVolatileData({
    int days = 30,
    double startPrice = 1000.0,
    double volatility = 0.08,
  }) {
    final data = <ChartDataPoint>[];
    final startDate = DateTime.now().subtract(Duration(days: days));
    double currentPrice = startPrice;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));

      // High volatility with occasional spikes
      final change = (_random.nextDouble() - 0.5) * 2 * volatility;
      final spike =
          _random.nextDouble() < 0.1 ? (_random.nextDouble() - 0.5) * 0.15 : 0;
      currentPrice = currentPrice * (1 + change + spike);

      // Keep within reasonable bounds
      currentPrice = currentPrice.clamp(startPrice * 0.3, startPrice * 3.0);

      data.add(ChartDataPoint(
        timestamp: date,
        value: currentPrice,
        label: date.toString().split(' ')[0],
      ));
    }

    return data;
  }

  /// Generate data for different chart periods
  static List<ChartDataPoint> generateDataForPeriod(
    int days, {
    double startPrice = 1000.0,
    String pattern = 'normal',
  }) {
    switch (pattern) {
      case 'trending':
        return generateTrendingData(days: days, startPrice: startPrice);
      case 'declining':
        return generateDecliningData(days: days, startPrice: startPrice);
      case 'volatile':
        return generateVolatileData(days: days, startPrice: startPrice);
      default:
        return generateLineChartData(days: days, startPrice: startPrice);
    }
  }

  /// Generate bullish candlestick pattern
  static List<CandlestickData> generateBullishCandlesticks({
    int days = 30,
    double startPrice = 1000.0,
  }) {
    final data = <CandlestickData>[];
    final startDate = DateTime.now().subtract(Duration(days: days));
    double basePrice = startPrice;

    for (int i = 0; i < days; i++) {
      final date = startDate.add(Duration(days: i));

      // Bullish bias - close > open more often
      final isBullish = _random.nextDouble() > 0.3;
      final range = basePrice * 0.05;

      double open, high, low, close;

      if (isBullish) {
        open = basePrice + (_random.nextDouble() - 0.5) * range * 0.5;
        close = open + _random.nextDouble() * range * 0.8;
        high = close + _random.nextDouble() * range * 0.3;
        low = open - _random.nextDouble() * range * 0.3;
      } else {
        open = basePrice + (_random.nextDouble() - 0.5) * range * 0.5;
        close = open - _random.nextDouble() * range * 0.6;
        high = open + _random.nextDouble() * range * 0.3;
        low = close - _random.nextDouble() * range * 0.3;
      }

      final volume = 10000 + _random.nextInt(90000);

      data.add(CandlestickData(
        timestamp: date,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: volume,
      ));

      basePrice = close;
    }

    return data;
  }
}
