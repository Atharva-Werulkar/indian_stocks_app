class ChartDataPoint {
  final DateTime timestamp;
  final double value;
  final String label;

  ChartDataPoint({
    required this.timestamp,
    required this.value,
    required this.label,
  });

  factory ChartDataPoint.fromJson(Map<String, dynamic> json) {
    return ChartDataPoint(
      timestamp: DateTime.parse(json['datetime'] ??
          json['timestamp'] ??
          DateTime.now().toIso8601String()),
      value: _parseDouble(json['close'] ?? json['value'] ?? 0.0),
      label: json['label'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'value': value,
      'label': label,
    };
  }

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class CandlestickData {
  final DateTime timestamp;
  final double open;
  final double high;
  final double low;
  final double close;
  final int volume;

  CandlestickData({
    required this.timestamp,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
  });

  factory CandlestickData.fromJson(Map<String, dynamic> json) {
    return CandlestickData(
      timestamp:
          DateTime.parse(json['datetime'] ?? DateTime.now().toIso8601String()),
      open: _parseDouble(json['open'] ?? 0.0),
      high: _parseDouble(json['high'] ?? 0.0),
      low: _parseDouble(json['low'] ?? 0.0),
      close: _parseDouble(json['close'] ?? 0.0),
      volume: _parseInt(json['volume'] ?? 0),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'timestamp': timestamp.toIso8601String(),
      'open': open,
      'high': high,
      'low': low,
      'close': close,
      'volume': volume,
    };
  }

  bool get isPositive => close >= open;

  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
