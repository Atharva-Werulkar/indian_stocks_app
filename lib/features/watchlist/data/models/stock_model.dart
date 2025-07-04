import 'package:hive/hive.dart';
import '../../../../core/models/stock.dart';

part 'stock_model.g.dart';

@HiveType(typeId: 0)
class StockModel extends HiveObject {
  @HiveField(0)
  final String symbol;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final double change;

  @HiveField(4)
  final double changePercent;

  @HiveField(5)
  final int volume;

  @HiveField(6)
  final double marketCap;

  @HiveField(7)
  final String currency;

  @HiveField(8)
  final String exchange;

  @HiveField(9)
  final DateTime timestamp;

  @HiveField(10)
  final double? high;

  @HiveField(11)
  final double? low;

  @HiveField(12)
  final double? open;

  @HiveField(13)
  final double? previousClose;

  @HiveField(14)
  final double? fiftyTwoWeekHigh;

  @HiveField(15)
  final double? fiftyTwoWeekLow;

  StockModel({
    required this.symbol,
    required this.name,
    required this.price,
    required this.change,
    required this.changePercent,
    required this.volume,
    required this.marketCap,
    required this.currency,
    required this.exchange,
    required this.timestamp,
    this.high,
    this.low,
    this.open,
    this.previousClose,
    this.fiftyTwoWeekHigh,
    this.fiftyTwoWeekLow,
  });

  /// Convert StockModel to Stock
  Stock toStock() {
    return Stock(
      symbol: symbol,
      name: name,
      currentPrice: price,
      change: change,
      changePercent: changePercent,
      previousClose: previousClose ?? price - change,
      dayHigh: high ?? price,
      dayLow: low ?? price,
      open: open ?? price,
      volume: volume,
      marketCap: marketCap,
      sector: 'Unknown',
      exchange: exchange,
      lastUpdated: timestamp,
    );
  }

  /// Create StockModel from Stock
  factory StockModel.fromStock(Stock stock) {
    return StockModel(
      symbol: stock.symbol,
      name: stock.name,
      price: stock.currentPrice,
      change: stock.change,
      changePercent: stock.changePercent,
      volume: stock.volume,
      marketCap: stock.marketCap,
      currency: 'INR',
      exchange: stock.exchange,
      timestamp: stock.lastUpdated,
      high: stock.dayHigh,
      low: stock.dayLow,
      open: stock.open,
      previousClose: stock.previousClose,
    );
  }

  /// Create from JSON
  factory StockModel.fromJson(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['symbol'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      change: (json['change'] ?? 0).toDouble(),
      changePercent: (json['changePercent'] ?? 0).toDouble(),
      volume: json['volume'] ?? 0,
      marketCap: (json['marketCap'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'INR',
      exchange: json['exchange'] ?? 'NSE',
      timestamp: json['timestamp'] != null 
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      high: json['high']?.toDouble(),
      low: json['low']?.toDouble(),
      open: json['open']?.toDouble(),
      previousClose: json['previousClose']?.toDouble(),
      fiftyTwoWeekHigh: json['fiftyTwoWeekHigh']?.toDouble(),
      fiftyTwoWeekLow: json['fiftyTwoWeekLow']?.toDouble(),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'name': name,
      'price': price,
      'change': change,
      'changePercent': changePercent,
      'volume': volume,
      'marketCap': marketCap,
      'currency': currency,
      'exchange': exchange,
      'timestamp': timestamp.toIso8601String(),
      'high': high,
      'low': low,
      'open': open,
      'previousClose': previousClose,
      'fiftyTwoWeekHigh': fiftyTwoWeekHigh,
      'fiftyTwoWeekLow': fiftyTwoWeekLow,
    };
  }

  @override
  String toString() {
    return 'StockModel(symbol: $symbol, name: $name, price: $price, change: $change, changePercent: $changePercent%)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StockModel && other.symbol == symbol;
  }

  @override
  int get hashCode => symbol.hashCode;
}
