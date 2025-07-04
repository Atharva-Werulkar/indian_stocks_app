import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import '../../features/stock_detail/data/models/chart_data.dart';

/// Enhanced chart widget using Syncfusion for better performance and features
class SyncfusionStockChart extends StatefulWidget {
  final List<ChartDataPoint> data;
  final List<CandlestickData>? candlestickData;
  final String title;
  final ChartType chartType;
  final Color? lineColor;
  final bool showGrid;
  final bool showTooltip;
  final Duration animationDuration;
  final double height;

  const SyncfusionStockChart({
    super.key,
    required this.data,
    this.candlestickData,
    required this.title,
    required this.chartType,
    this.lineColor,
    this.showGrid = true,
    this.showTooltip = true,
    this.animationDuration = const Duration(milliseconds: 1500),
    this.height = 300,
  });

  @override
  State<SyncfusionStockChart> createState() => _SyncfusionStockChartState();
}

class _SyncfusionStockChartState extends State<SyncfusionStockChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late TrackballBehavior _trackballBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _trackballBehavior = TrackballBehavior(
      enable: widget.showTooltip,
      activationMode: ActivationMode.singleTap,
      tooltipDisplayMode: TrackballDisplayMode.groupAllPoints,
      tooltipSettings: const InteractiveTooltip(
        enable: true,
        color: Colors.black87,
        textStyle: TextStyle(color: Colors.white),
      ),
    );

    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      enableSelectionZooming: true,
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

    return Container(
      height: widget.height,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.title.isNotEmpty) ...[
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
          ],
          Expanded(
            child: _buildChart(theme),
          ),
        ],
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    switch (widget.chartType) {
      case ChartType.line:
        return _buildLineChart(theme);
      case ChartType.candlestick:
        return _buildCandlestickChart(theme);
      case ChartType.area:
        return _buildAreaChart(theme);
      case ChartType.column:
        return _buildColumnChart(theme);
    }
  }

  Widget _buildLineChart(ThemeData theme) {
    if (widget.data.isEmpty) return _buildNoDataWidget(theme);

    final isPositive = widget.data.isNotEmpty &&
        widget.data.first.value < widget.data.last.value;
    final defaultColor = isPositive ? Colors.green : Colors.red;

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        majorGridLines: MajorGridLines(
          width: widget.showGrid ? 1 : 0,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            DateFormat('dd/MM').format(DateTime.fromMillisecondsSinceEpoch(
              details.value.toInt(),
            )),
            details.textStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          );
        },
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: widget.showGrid ? 1 : 0,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        numberFormat: NumberFormat.currency(
          symbol: '₹',
          decimalDigits: 0,
        ),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            NumberFormat.compact().format(details.value),
            details.textStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          );
        },
      ),
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      backgroundColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      series: <CartesianSeries<ChartDataPoint, DateTime>>[
        LineSeries<ChartDataPoint, DateTime>(
          dataSource: widget.data,
          xValueMapper: (ChartDataPoint data, _) => data.timestamp,
          yValueMapper: (ChartDataPoint data, _) => data.value,
          color: widget.lineColor ?? defaultColor,
          width: 2.5,
          markerSettings: const MarkerSettings(
            isVisible: false,
          ),
          enableTooltip: true,
          animationDuration: widget.animationDuration.inMilliseconds.toDouble(),
        ),
      ],
    );
  }

  Widget _buildAreaChart(ThemeData theme) {
    if (widget.data.isEmpty) return _buildNoDataWidget(theme);

    final isPositive = widget.data.isNotEmpty &&
        widget.data.first.value < widget.data.last.value;
    final defaultColor = isPositive ? Colors.green : Colors.red;

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        majorGridLines: MajorGridLines(
          width: widget.showGrid ? 1 : 0,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            DateFormat('dd/MM').format(DateTime.fromMillisecondsSinceEpoch(
              details.value.toInt(),
            )),
            details.textStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          );
        },
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: widget.showGrid ? 1 : 0,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        numberFormat: NumberFormat.currency(
          symbol: '₹',
          decimalDigits: 0,
        ),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            NumberFormat.compact().format(details.value),
            details.textStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          );
        },
      ),
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      backgroundColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      series: <CartesianSeries<ChartDataPoint, DateTime>>[
        AreaSeries<ChartDataPoint, DateTime>(
          dataSource: widget.data,
          xValueMapper: (ChartDataPoint data, _) => data.timestamp,
          yValueMapper: (ChartDataPoint data, _) => data.value,
          color: (widget.lineColor ?? defaultColor).withOpacity(0.3),
          borderColor: widget.lineColor ?? defaultColor,
          borderWidth: 2.5,
          enableTooltip: true,
          animationDuration: widget.animationDuration.inMilliseconds.toDouble(),
        ),
      ],
    );
  }

  Widget _buildColumnChart(ThemeData theme) {
    if (widget.data.isEmpty) return _buildNoDataWidget(theme);

    final isPositive = widget.data.isNotEmpty &&
        widget.data.first.value < widget.data.last.value;
    final defaultColor = isPositive ? Colors.green : Colors.red;

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        majorGridLines: MajorGridLines(
          width: widget.showGrid ? 1 : 0,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            DateFormat('dd/MM').format(DateTime.fromMillisecondsSinceEpoch(
              details.value.toInt(),
            )),
            details.textStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          );
        },
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: widget.showGrid ? 1 : 0,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        numberFormat: NumberFormat.currency(
          symbol: '₹',
          decimalDigits: 0,
        ),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            NumberFormat.compact().format(details.value),
            details.textStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          );
        },
      ),
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      backgroundColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      series: <CartesianSeries<ChartDataPoint, DateTime>>[
        ColumnSeries<ChartDataPoint, DateTime>(
          dataSource: widget.data,
          xValueMapper: (ChartDataPoint data, _) => data.timestamp,
          yValueMapper: (ChartDataPoint data, _) => data.value,
          color: widget.lineColor ?? defaultColor,
          enableTooltip: true,
          animationDuration: widget.animationDuration.inMilliseconds.toDouble(),
          pointColorMapper: (ChartDataPoint data, _) {
            final isUp = widget.data.indexOf(data) == 0
                ? true
                : data.value >=
                    widget.data[widget.data.indexOf(data) - 1].value;
            return isUp ? Colors.green : Colors.red;
          },
        ),
      ],
    );
  }

  Widget _buildCandlestickChart(ThemeData theme) {
    if (widget.candlestickData == null || widget.candlestickData!.isEmpty) {
      return _buildNoDataWidget(theme);
    }

    return SfCartesianChart(
      primaryXAxis: DateTimeAxis(
        majorGridLines: MajorGridLines(
          width: widget.showGrid ? 1 : 0,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            DateFormat('dd/MM').format(DateTime.fromMillisecondsSinceEpoch(
              details.value.toInt(),
            )),
            details.textStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          );
        },
      ),
      primaryYAxis: NumericAxis(
        majorGridLines: MajorGridLines(
          width: widget.showGrid ? 1 : 0,
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        numberFormat: NumberFormat.currency(
          symbol: '₹',
          decimalDigits: 0,
        ),
        axisLabelFormatter: (AxisLabelRenderDetails details) {
          return ChartAxisLabel(
            NumberFormat.compact().format(details.value),
            details.textStyle.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontSize: 10,
            ),
          );
        },
      ),
      trackballBehavior: _trackballBehavior,
      zoomPanBehavior: _zoomPanBehavior,
      backgroundColor: Colors.transparent,
      plotAreaBorderWidth: 0,
      series: <CartesianSeries<CandlestickData, DateTime>>[
        CandleSeries<CandlestickData, DateTime>(
          dataSource: widget.candlestickData!,
          xValueMapper: (CandlestickData data, _) => data.timestamp,
          lowValueMapper: (CandlestickData data, _) => data.low,
          highValueMapper: (CandlestickData data, _) => data.high,
          openValueMapper: (CandlestickData data, _) => data.open,
          closeValueMapper: (CandlestickData data, _) => data.close,
          enableTooltip: true,
          animationDuration: widget.animationDuration.inMilliseconds.toDouble(),
          bearColor: Colors.red,
          bullColor: Colors.green,
          showIndicationForSameValues: true,
          enableSolidCandles: true,
        ),
      ],
    );
  }

  Widget _buildNoDataWidget(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart_rounded,
            size: 64,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No Chart Data Available',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please select a different time period',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// Chart type enumeration
enum ChartType {
  line,
  candlestick,
  area,
  column,
}

extension ChartTypeExtension on ChartType {
  String get displayName {
    switch (this) {
      case ChartType.line:
        return 'Line';
      case ChartType.candlestick:
        return 'Candlestick';
      case ChartType.area:
        return 'Area';
      case ChartType.column:
        return 'Column';
    }
  }

  IconData get icon {
    switch (this) {
      case ChartType.line:
        return Icons.show_chart;
      case ChartType.candlestick:
        return Icons.bar_chart_outlined;
      case ChartType.area:
        return Icons.area_chart_outlined;
      case ChartType.column:
        return Icons.bar_chart;
    }
  }
}

/// Chart period enumeration
enum ChartPeriod {
  oneDay,
  oneWeek,
  oneMonth,
  threeMonths,
  sixMonths,
  oneYear,
}

extension ChartPeriodExtension on ChartPeriod {
  String get displayName {
    switch (this) {
      case ChartPeriod.oneDay:
        return '1D';
      case ChartPeriod.oneWeek:
        return '1W';
      case ChartPeriod.oneMonth:
        return '1M';
      case ChartPeriod.threeMonths:
        return '3M';
      case ChartPeriod.sixMonths:
        return '6M';
      case ChartPeriod.oneYear:
        return '1Y';
    }
  }

  int get days {
    switch (this) {
      case ChartPeriod.oneDay:
        return 1;
      case ChartPeriod.oneWeek:
        return 7;
      case ChartPeriod.oneMonth:
        return 30;
      case ChartPeriod.threeMonths:
        return 90;
      case ChartPeriod.sixMonths:
        return 180;
      case ChartPeriod.oneYear:
        return 365;
    }
  }

  String get apiInterval {
    switch (this) {
      case ChartPeriod.oneDay:
        return '5min';
      case ChartPeriod.oneWeek:
        return '1h';
      case ChartPeriod.oneMonth:
        return '1day';
      case ChartPeriod.threeMonths:
        return '1day';
      case ChartPeriod.sixMonths:
        return '1day';
      case ChartPeriod.oneYear:
        return '1week';
    }
  }
}
