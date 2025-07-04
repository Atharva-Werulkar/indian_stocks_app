import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../providers/watchlist_provider.dart';
import '../../../dashboard/presentation/widgets/stock_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class WatchlistPage extends StatefulWidget {
  const WatchlistPage({super.key});

  @override
  _WatchlistPageState createState() => _WatchlistPageState();
}

class _WatchlistPageState extends State<WatchlistPage>
    with AutomaticKeepAliveClientMixin {
  final RefreshController _refreshController = RefreshController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _onRefresh() {
    context.read<WatchlistProvider>().loadWatchlist();
  }

  void _onClearWatchlist() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Watchlist'),
        content: const Text(
            'Are you sure you want to remove all stocks from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<WatchlistProvider>().clearWatchlist();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Consumer<WatchlistProvider>(
        builder: (context, watchlistProvider, child) {
          // Handle refresh completion
          if (!watchlistProvider.isLoading) {
            _refreshController.refreshCompleted();
          }

          if (watchlistProvider.isLoading && !watchlistProvider.hasStocks) {
            return const Center(child: LoadingWidget());
          }

          if (watchlistProvider.hasError && !watchlistProvider.hasStocks) {
            return Center(
              child: CustomErrorWidget(
                message: watchlistProvider.errorMessage!,
                onRetry: () => watchlistProvider.loadWatchlist(),
              ),
            );
          }

          if (!watchlistProvider.hasStocks) {
            return _buildEmptyState();
          }

          return SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            header: WaterDropMaterialHeader(
              backgroundColor: Theme.of(context).colorScheme.primary,
              color: Colors.white,
            ),
            child: _buildWatchlistContent(watchlistProvider),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.favorite_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Watchlist',
            style: AppTheme.headingMedium.copyWith(
              color: Theme.of(context).textTheme.headlineMedium?.color,
            ),
          ),
        ],
      ),
      actions: [
        Consumer<WatchlistProvider>(
          builder: (context, watchlistProvider, child) {
            if (watchlistProvider.hasStocks) {
              return IconButton(
                onPressed: _onClearWatchlist,
                icon: Icon(
                  Icons.clear_all_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        const SizedBox(width: 16),
      ],
    );
  }

  Widget _buildWatchlistContent(WatchlistProvider watchlistProvider) {
    final stocks = watchlistProvider.stocks;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Watchlist Summary
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: _buildWatchlistSummary(watchlistProvider),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Stocks Section Header
            Text(
              'Your Stocks (${stocks.length})',
              style: AppTheme.headingSmall.copyWith(
                color: Theme.of(context).textTheme.headlineSmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Stocks List
            ...stocks.asMap().entries.map((entry) {
              final index = entry.key;
              final stock = entry.value;

              return AnimationConfiguration.staggeredList(
                position: index + 1,
                duration: const Duration(milliseconds: 600),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: StockCard(stock: stock),
                    ),
                  ),
                ),
              );
            }),

            // Loading indicator for refresh
            if (watchlistProvider.isLoading && stocks.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: LoadingWidget()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistSummary(WatchlistProvider watchlistProvider) {
    final stocks = watchlistProvider.stocks;
    final positiveStocks = stocks.where((stock) => stock.isGaining).length;
    final negativeStocks = stocks.where((stock) => !stock.isGaining).length;

    return Container(
      decoration: AppTheme.getCardDecoration(context),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Watchlist Summary',
              style: AppTheme.headingSmall.copyWith(
                color: Theme.of(context).textTheme.headlineSmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildSummaryItem(
                    'Total Stocks',
                    '${stocks.length}',
                    Icons.list_rounded,
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Gainers',
                    '$positiveStocks',
                    Icons.trending_up_rounded,
                    Colors.green,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildSummaryItem(
                    'Losers',
                    '$negativeStocks',
                    Icons.trending_down_rounded,
                    Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
      String label, String value, IconData icon, Color color) {
    return Container(
      decoration: AppTheme.neumorphicDecoration(
        context: context,
        borderRadius: 12,
        depth: 4,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTheme.headingSmall.copyWith(
                color: Theme.of(context).textTheme.headlineSmall?.color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.favorite_border_rounded,
            size: 80,
            color: Theme.of(context).iconTheme.color?.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Your watchlist is empty',
            style: AppTheme.headingSmall.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.color
                  ?.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Add stocks to your watchlist to track them here',
            style: AppTheme.bodyMedium.copyWith(
              color: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.color
                  ?.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // Show a message that user can use search tab
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                      'Use the Search tab to find and add stocks to your watchlist'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            icon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
            label: Text(
              'Search Stocks',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
