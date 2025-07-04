import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

/// A reusable animated line chart widget for displaying stock price data
class AnimatedStockChart extends StatefulWidget {
  final List<FlSpot> data;
  final String title;
  final Color? lineColor;
  final Color? gradientStartColor;
  final Color? gradientEndColor;
  final double? minY;
  final double? maxY;
  final bool showGrid;
  final bool showTooltip;
  final Duration animationDuration;

  const AnimatedStockChart({
    super.key,
    required this.data,
    required this.title,
    this.lineColor,
    this.gradientStartColor,
    this.gradientEndColor,
    this.minY,
    this.maxY,
    this.showGrid = true,
    this.showTooltip = true,
    this.animationDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<AnimatedStockChart> createState() => _AnimatedStockChartState();
}

class _AnimatedStockChartState extends State<AnimatedStockChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOutCubic,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPositive =
        widget.data.isNotEmpty && widget.data.first.y < widget.data.last.y;

    final defaultLineColor = isPositive ? Colors.green : Colors.red;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: LineChart(
            LineChartData(
              minY: widget.minY,
              maxY: widget.maxY,
              gridData: FlGridData(
                show: widget.showGrid,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
                getDrawingVerticalLine: (value) {
                  return FlLine(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 30,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Container(
                        margin: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${value.toInt()}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        '₹${value.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 12,
                        ),
                      );
                    },
                    reservedSize: 42,
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(
                  color: theme.colorScheme.primary.withOpacity(0.3),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: widget.data
                      .take(
                        (widget.data.length * _animation.value).round(),
                      )
                      .toList(),
                  isCurved: true,
                  color: widget.lineColor ?? defaultLineColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        (widget.gradientStartColor ?? defaultLineColor)
                            .withOpacity(0.3),
                        (widget.gradientEndColor ?? defaultLineColor)
                            .withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
              lineTouchData: widget.showTooltip
                  ? LineTouchData(
                      handleBuiltInTouches: true,
                      touchTooltipData: LineTouchTooltipData(
                        tooltipBgColor: theme.cardColor,
                        tooltipRoundedRadius: 8,
                        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                          return touchedBarSpots.map((barSpot) {
                            return LineTooltipItem(
                              '₹${barSpot.y.toStringAsFixed(2)}',
                              TextStyle(
                                color: theme.colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }).toList();
                        },
                      ),
                    )
                  : const LineTouchData(enabled: false),
            ),
          ),
        );
      },
    );
  }
}

/// A reusable candlestick chart widget for detailed stock analysis
class CandlestickChart extends StatelessWidget {
  final List<CandlestickData> data;
  final String title;
  final double? minY;
  final double? maxY;

  const CandlestickChart({
    super.key,
    required this.data,
    required this.title,
    this.minY,
    this.maxY,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      height: 300,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: CustomPaint(
              painter: CandlestickPainter(data: data, theme: theme),
              child: Container(),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model for candlestick chart
class CandlestickData {
  final double open;
  final double high;
  final double low;
  final double close;
  final int timestamp;

  CandlestickData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.timestamp,
  });

  bool get isBullish => close > open;
}

/// Custom painter for candlestick chart
class CandlestickPainter extends CustomPainter {
  final List<CandlestickData> data;
  final ThemeData theme;

  CandlestickPainter({
    required this.data,
    required this.theme,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final bodyPaint = Paint()..style = PaintingStyle.fill;

    // Calculate min and max values
    double minPrice = data.first.low;
    double maxPrice = data.first.high;
    for (final candle in data) {
      minPrice = minPrice < candle.low ? minPrice : candle.low;
      maxPrice = maxPrice > candle.high ? maxPrice : candle.high;
    }

    final priceRange = maxPrice - minPrice;
    final candleWidth = size.width / data.length * 0.8;
    final spacing = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final candle = data[i];
      final x = i * spacing + spacing / 2;

      // Calculate y positions
      final highY = (maxPrice - candle.high) / priceRange * size.height;
      final lowY = (maxPrice - candle.low) / priceRange * size.height;
      final openY = (maxPrice - candle.open) / priceRange * size.height;
      final closeY = (maxPrice - candle.close) / priceRange * size.height;

      // Set colors
      final color = candle.isBullish ? Colors.green : Colors.red;
      paint.color = color;
      bodyPaint.color = candle.isBullish ? color : color;

      // Draw high-low line
      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        paint,
      );

      // Draw body
      final bodyTop = candle.isBullish ? closeY : openY;
      final bodyBottom = candle.isBullish ? openY : closeY;
      final bodyHeight = bodyBottom - bodyTop;

      final rect = Rect.fromLTWH(
        x - candleWidth / 2,
        bodyTop,
        candleWidth,
        bodyHeight,
      );

      if (candle.isBullish) {
        canvas.drawRect(rect, bodyPaint);
      } else {
        canvas.drawRect(rect, bodyPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
