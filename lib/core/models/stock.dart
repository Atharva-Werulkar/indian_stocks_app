/// Stock data model for the Indian Stocks App
class Stock {
  final String symbol;
  final String name;
  final double currentPrice;
  final double change;
  final double changePercent;
  final double previousClose;
  final double dayHigh;
  final double dayLow;
  final double open;
  final int volume;
  final double marketCap;
  final String sector;
  final String exchange;
  final DateTime lastUpdated;
  final List<double>? chartData;

  Stock({
    required this.symbol,
    required this.name,
    required this.currentPrice,
    required this.change,
    required this.changePercent,
    required this.previousClose,
    required this.dayHigh,
    required this.dayLow,
    required this.open,
    required this.volume,
    required this.marketCap,
    required this.sector,
    required this.exchange,
    DateTime? lastUpdated,
    this.chartData,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  /// Create a Stock from JSON data
  factory Stock.fromJson(Map<String, dynamic> json) {
    // Handle TwelveData API response format
    final symbol = json['symbol'] ?? json['name'] ?? '';
    final price = _parseDouble(json['close'] ?? json['price'] ?? json['currentPrice'] ?? 0);
    final previousClose = _parseDouble(json['previous_close'] ?? json['previousClose'] ?? price);
    final change = _parseDouble(json['change'] ?? 0);
    final changePercent = _parseDouble(json['percent_change'] ?? json['changePercent'] ?? 0);
    
    return Stock(
      symbol: symbol,
      name: json['name'] ?? json['symbol'] ?? symbol,
      currentPrice: price,
      change: change,
      changePercent: changePercent,
      previousClose: previousClose,
      dayHigh: _parseDouble(json['high'] ?? json['dayHigh'] ?? price),
      dayLow: _parseDouble(json['low'] ?? json['dayLow'] ?? price),
      open: _parseDouble(json['open'] ?? price),
      volume: _parseInt(json['volume'] ?? 0),
      marketCap: _parseDouble(json['market_cap'] ?? json['marketCap'] ?? 0),
      sector: json['sector'] ?? json['exchange'] ?? 'Unknown',
      exchange: json['exchange'] ?? json['mic_code'] ?? 'NSE',
      lastUpdated: json['datetime'] != null
          ? DateTime.tryParse(json['datetime'].toString()) ?? DateTime.now()
          : json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
      chartData: json['chartData'] != null
          ? List<double>.from(json['chartData'].map((x) => _parseDouble(x)))
          : null,
    );
  }

  /// Convert Stock to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'currentPrice': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'previousClose': previousClose,
      'dayHigh': dayHigh,
      'dayLow': dayLow,
      'open': open,
      'volume': volume,
      'marketCap': marketCap,
      'sector': sector,
      'exchange': exchange,
      'lastUpdated': lastUpdated.toIso8601String(),
      'chartData': chartData,
    };
  }

  /// Convert to StockModel for compatibility with existing features
  Map<String, dynamic> toStockModelJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': currentPrice,
      'change': change,
      'changePercent': changePercent,
      'volume': volume,
      'marketCap': marketCap,
      'currency': 'INR',
      'exchange': exchange,
      'sector': sector,
      'high': dayHigh,
      'low': dayLow,
      'previousClose': previousClose,
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Create Stock from StockModel-like JSON
  factory Stock.fromStockModelJson(Map<String, dynamic> json) {
    return Stock(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      currentPrice: _parseDouble(json['price'] ?? json['currentPrice'] ?? 0),
      change: _parseDouble(json['change'] ?? 0),
      changePercent: _parseDouble(json['changePercent'] ?? 0),
      previousClose: _parseDouble(json['previousClose'] ?? 0),
      dayHigh: _parseDouble(json['high'] ?? json['dayHigh'] ?? 0),
      dayLow: _parseDouble(json['low'] ?? json['dayLow'] ?? 0),
      open: _parseDouble(json['open'] ?? 0),
      volume: _parseInt(json['volume'] ?? 0),
      marketCap: _parseDouble(json['marketCap'] ?? 0),
      sector: json['sector'] ?? 'Unknown',
      exchange: json['exchange'] ?? 'NSE',
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.tryParse(json['lastUpdated'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Create a Stock from Time Series data (for charts)
  factory Stock.fromTimeSeriesJson(Map<String, dynamic> json) {
    final meta = json['meta'] ?? {};
    final values = json['values'] as List<dynamic>? ?? [];
    
    // Get the latest data point for current price
    final latestData = values.isNotEmpty ? values.first : <String, dynamic>{};
    final price = _parseDouble(latestData['close'] ?? 0);
    
    // Extract chart data from all values
    final chartData = values
        .map((value) => _parseDouble(value['close'] ?? 0))
        .toList();
    
    final lastUpdatedTime = latestData['datetime'] != null
        ? DateTime.tryParse(latestData['datetime'].toString()) ?? DateTime.now()
        : DateTime.now();
    
    return Stock(
      symbol: meta['symbol'] ?? '',
      name: meta['symbol'] ?? '', // Time series doesn't provide company name
      currentPrice: price,
      change: 0, // Calculate from previous if needed
      changePercent: 0, // Calculate from previous if needed
      previousClose: values.length > 1 ? _parseDouble(values[1]['close'] ?? price) : price,
      dayHigh: _parseDouble(latestData['high'] ?? price),
      dayLow: _parseDouble(latestData['low'] ?? price),
      open: _parseDouble(latestData['open'] ?? price),
      volume: _parseInt(latestData['volume'] ?? 0),
      marketCap: 0, // Not available in time series
      sector: 'Technology', // Default sector
      exchange: meta['exchange'] ?? 'NSE',
      lastUpdated: lastUpdatedTime,
      chartData: chartData,
    );
  }

  /// Check if the stock is gaining (positive change)
  bool get isGaining => changePercent > 0;

  /// Check if the stock is losing (negative change)
  bool get isLosing => changePercent < 0;

  /// Get formatted price string
  String get formattedPrice => '₹${currentPrice.toStringAsFixed(2)}';

  /// Get formatted change string with sign
  String get formattedChange =>
      '${change >= 0 ? '+' : ''}₹${change.toStringAsFixed(2)}';

  /// Get formatted change percent string with sign
  String get formattedChangePercent =>
      '${changePercent >= 0 ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

  /// Get formatted volume string (e.g., 1.2M, 12.5K)
  String get formattedVolume {
    if (volume >= 1000000) {
      return '${(volume / 1000000).toStringAsFixed(1)}M';
    } else if (volume >= 1000) {
      return '${(volume / 1000).toStringAsFixed(1)}K';
    }
    return volume.toString();
  }

  /// Get formatted market cap string
  String get formattedMarketCap {
    if (marketCap >= 10000000000) {
      return '₹${(marketCap / 10000000000).toStringAsFixed(1)}B';
    } else if (marketCap >= 10000000) {
      return '₹${(marketCap / 10000000).toStringAsFixed(1)}M';
    } else if (marketCap >= 100000) {
      return '₹${(marketCap / 100000).toStringAsFixed(1)}L';
    }
    return '₹${marketCap.toStringAsFixed(0)}';
  }

  /// Create a copy of the stock with updated values
  Stock copyWith({
    String? symbol,
    String? name,
    double? currentPrice,
    double? change,
    double? changePercent,
    double? previousClose,
    double? dayHigh,
    double? dayLow,
    double? open,
    int? volume,
    double? marketCap,
    String? sector,
    String? exchange,
    DateTime? lastUpdated,
    List<double>? chartData,
  }) {
    return Stock(
      symbol: symbol ?? this.symbol,
      name: name ?? this.name,
      currentPrice: currentPrice ?? this.currentPrice,
      change: change ?? this.change,
      changePercent: changePercent ?? this.changePercent,
      previousClose: previousClose ?? this.previousClose,
      dayHigh: dayHigh ?? this.dayHigh,
      dayLow: dayLow ?? this.dayLow,
      open: open ?? this.open,
      volume: volume ?? this.volume,
      marketCap: marketCap ?? this.marketCap,
      sector: sector ?? this.sector,
      exchange: exchange ?? this.exchange,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      chartData: chartData ?? this.chartData,
    );
  }

  @override
  String toString() {
    return 'Stock(symbol: $symbol, name: $name, currentPrice: $currentPrice, changePercent: $changePercent)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Stock && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;

  /// Helper method to safely parse double values
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Helper method to safely parse int values
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}