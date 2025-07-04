import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:share_plus/share_plus.dart';

import '../providers/stock_detail_provider.dart';
import '../../../../core/models/stock.dart';
import '../../../watchlist/presentation/providers/watchlist_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/syncfusion_stock_chart.dart';

class StockDetailPage extends StatefulWidget {
  final Stock stock;

  const StockDetailPage({
    super.key,
    required this.stock,
  });

  @override
  _StockDetailPageState createState() => _StockDetailPageState();
}

class _StockDetailPageState extends State<StockDetailPage>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  ChartType _selectedChartType = ChartType.line;
  ChartPeriod _selectedPeriod = ChartPeriod.oneDay;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppConstants.mediumAnimation,
      vsync: this,
    );

    // Load stock detail data using Provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StockDetailProvider>().loadStockDetail(
            symbol: widget.stock.symbol,
            chartType: _selectedChartType,
            period: _selectedPeriod,
          );
    });

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onChartTypeChanged(ChartType chartType) {
    setState(() {
      _selectedChartType = chartType;
    });
    context.read<StockDetailProvider>().loadChartData(
          symbol: widget.stock.symbol,
          chartType: chartType,
          period: _selectedPeriod,
        );
  }

  void _onPeriodChanged(ChartPeriod period) {
    setState(() {
      _selectedPeriod = period;
    });
    context.read<StockDetailProvider>().loadChartData(
          symbol: widget.stock.symbol,
          chartType: _selectedChartType,
          period: period,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: _animationController,
              curve: Curves.easeOutQuart,
            )),
            child: FadeTransition(
              opacity: _animationController,
              child: _buildBody(),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: ElevatedButton(
        onPressed: () => Navigator.of(context).pop(),
        child: Icon(
          Icons.arrow_back_ios_rounded,
          color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.stock.symbol.replaceAll('.BSE', '').replaceAll('.NSE', ''),
            style: AppTheme.headingSmall.copyWith(
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.stock.exchange,
            style: AppTheme.bodySmall.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black.withOpacity(0.6),
            ),
          ),
        ],
      ),
      actions: [
        Consumer<WatchlistProvider>(
          builder: (context, watchlistProvider, child) {
            final isInWatchlist =
                watchlistProvider.isInWatchlist(widget.stock.symbol);

            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                backgroundColor: Colors.transparent,
                padding: const EdgeInsets.all(8),
              ),
              onPressed: () {
                if (isInWatchlist) {
                  watchlistProvider.removeFromWatchlist(widget.stock.symbol);
                } else {
                  watchlistProvider.addToWatchlist(widget.stock);
                }
              },
              child: Icon(
                isInWatchlist ? Icons.favorite : Icons.favorite_border,
                color: isInWatchlist
                    ? Colors.red
                    : Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.black,
              ),
            );
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            backgroundColor: Colors.transparent,
            padding: const EdgeInsets.all(8),
          ),
          onPressed: () => _shareStock(widget.stock),
          child: Icon(
            Icons.share_rounded,
            color:
                Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          ),
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildBody() {
    return Consumer<StockDetailProvider>(
      builder: (context, stockDetailProvider, child) {
        if (stockDetailProvider.isLoading) {
          return const Center(
            child: LoadingWidget(
              message: 'Loading stock details...',
            ),
          );
        }

        if (stockDetailProvider.hasError) {
          return Center(
            child: CustomErrorWidget(
              message: stockDetailProvider.errorMessage!,
              onRetry: () => stockDetailProvider.loadStockDetail(
                symbol: widget.stock.symbol,
                chartType: _selectedChartType,
                period: _selectedPeriod,
              ),
            ),
          );
        }

        final stock = stockDetailProvider.stock ?? widget.stock;

        return SingleChildScrollView(
          child: AnimationLimiter(
            child: Column(
              children: [
                // Price Header
                AnimationConfiguration.staggeredList(
                  position: 0,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildPriceHeader(stock),
                    ),
                  ),
                ),

                // Chart Type Selector
                AnimationConfiguration.staggeredList(
                  position: 1,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildChartTypeSelector(),
                    ),
                  ),
                ),

                // Chart Section
                AnimationConfiguration.staggeredList(
                  position: 2,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildChartSection(stockDetailProvider),
                    ),
                  ),
                ),

                // Metrics Section
                AnimationConfiguration.staggeredList(
                  position: 3,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: _buildMetricsSection(stock),
                    ),
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPriceHeader(Stock stock) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.getCardDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                stock.name,
                style: AppTheme.headingMedium.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                stock.formattedPrice,
                style: AppTheme.headingLarge.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: stock.isGaining ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          stock.isGaining
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          stock.formattedChangePercent,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    stock.formattedChange,
                    style: TextStyle(
                      color: stock.isGaining ? Colors.green : Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartTypeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Chart Type',
                style: AppTheme.headingSmall.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: ChartType.values.map((type) {
                  return _buildChartTypeButton(
                    type.displayName,
                    type,
                    _selectedChartType == type,
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(
                'Time Period',
                style: AppTheme.headingSmall.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ChartPeriod.values.map((period) {
                  return _buildPeriodButton(
                    period.displayName,
                    period,
                    _selectedPeriod == period,
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartTypeButton(String label, ChartType type, bool isSelected) {
    return ElevatedButton.icon(
      onPressed: () => _onChartTypeChanged(type),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      ),
      icon: Icon(
        type.icon,
        size: 16,
        color: isSelected
            ? Theme.of(context).colorScheme.primary
            : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildPeriodButton(String label, ChartPeriod period, bool isSelected) {
    return ElevatedButton(
      onPressed: () => _onPeriodChanged(period),
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        backgroundColor: isSelected
            ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
            : Theme.of(context).scaffoldBackgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildChartSection(StockDetailProvider provider) {
    final chartData = provider.chartData;
    final candlestickData = provider.candlestickData;
    final chartType = provider.chartType;

    // Check if we have data for the selected chart type
    final hasData = (chartType == ChartType.candlestick)
        ? candlestickData.isNotEmpty
        : chartData.isNotEmpty;

    if (!hasData) {
      return Container(
        height: 350,
        margin: const EdgeInsets.all(16),
        child: Container(
          decoration: AppTheme.getCardDecoration(context),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.show_chart_rounded,
                  size: 64,
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No Chart Data',
                  style: AppTheme.headingSmall.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.black.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'No data available for the selected period',
                  style: AppTheme.bodySmall.copyWith(
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.black.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isGaining = chartData.isNotEmpty
        ? chartData.last.value > chartData.first.value
        : candlestickData.isNotEmpty
            ? candlestickData.last.close > candlestickData.first.open
            : true;

    return Container(
      height: 400,
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: AppTheme.getCardDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SyncfusionStockChart(
            data: chartData,
            candlestickData:
                candlestickData.isNotEmpty ? candlestickData : null,
            title: _getChartTitle(chartType),
            chartType: chartType,
            lineColor: isGaining ? Colors.green : Colors.red,
            showGrid: true,
            showTooltip: true,
            height: 350,
          ),
        ),
      ),
    );
  }

  String _getChartTitle(ChartType chartType) {
    switch (chartType) {
      case ChartType.line:
        return 'Price Chart';
      case ChartType.candlestick:
        return 'Candlestick Chart';
      case ChartType.area:
        return 'Area Chart';
      case ChartType.column:
        return 'Volume Chart';
    }
  }

  Widget _buildMetricsSection(Stock stock) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: AppTheme.getCardDecoration(context),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Key Metrics',
                style: AppTheme.headingSmall.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildMetricRow('Volume', stock.formattedVolume),
              _buildMetricRow('Exchange', stock.exchange),
              _buildMetricRow('Symbol', stock.symbol),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTheme.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black.withOpacity(0.7),
            ),
          ),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  void _shareStock(Stock stock) {
    final changeDirection = stock.isGaining ? "📈" : "📉";
    final changeColor = stock.isGaining ? "🟢" : "🔴";

    final shareText = '''
$changeDirection ${stock.name} (${stock.symbol})
Current Price: ${stock.formattedPrice}
Change: ${stock.formattedChange} (${stock.formattedChangePercent}) $changeColor
Exchange: ${stock.exchange}

Track more Indian stocks with Indian Stocks app!
Download: https://play.google.com/store/apps/details?id=com.yourapp.indianstocks

#IndianStocks #${stock.symbol} #StockMarket #BSE #NSE
''';

    Share.share(
      shareText,
      subject: '${stock.symbol} Stock Update',
    );
  }
}
