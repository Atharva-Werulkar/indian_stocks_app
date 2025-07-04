import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'dart:ui';

import '../providers/dashboard_provider.dart';
import '../widgets/stock_card.dart';
import '../widgets/market_summary_card.dart';
import '../widgets/trending_stocks_widget.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';
import '../../../../shared/widgets/glass_container.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
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
    context.read<DashboardProvider>().refreshDashboardData();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(context),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: Theme.of(context).brightness == Brightness.dark
                ? [
                    const Color(0xFF0A0A0A),
                    const Color(0xFF1A1A1A),
                  ]
                : [
                    const Color(0xFFF8F9FA),
                    const Color(0xFFE9ECEF),
                  ],
          ),
        ),
        child: Consumer<DashboardProvider>(
          builder: (context, dashboardProvider, child) {
            // Handle refresh completion
            if (!dashboardProvider.isLoading) {
              _refreshController.refreshCompleted();
            }

            if (dashboardProvider.isLoading && !dashboardProvider.hasData) {
              return const Center(child: LoadingWidget());
            }

            if (dashboardProvider.hasError && !dashboardProvider.hasData) {
              return Center(
                child: CustomErrorWidget(
                  message: dashboardProvider.errorMessage!,
                  onRetry: () => dashboardProvider.loadDashboardData(),
                ),
              );
            }

            return SmartRefresher(
              controller: _refreshController,
              onRefresh: _onRefresh,
              header: WaterDropMaterialHeader(
                backgroundColor: Theme.of(context).colorScheme.primary,
                color: Colors.white,
              ),
              child: _buildDashboardContent(context, dashboardProvider),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return const GlassAppBar(
      title: 'Indian Stocks',
    );
  }

  Widget _buildDashboardContent(
      BuildContext context, DashboardProvider provider) {
    final stocks = provider.stocks;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: kToolbarHeight + 40,
        left: 16,
        right: 16,
        bottom: 16,
      ),
      child: AnimationLimiter(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),

            // Market Summary
            AnimationConfiguration.staggeredList(
              position: 0,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: MarketSummaryCard(stocks: stocks),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Trending Stocks
            AnimationConfiguration.staggeredList(
              position: 1,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: TrendingStocksWidget(stocks: stocks.take(5).toList()),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Popular Stocks Section
            _buildSectionHeader(context, 'Popular Stocks'),

            const SizedBox(height: 16),

            // Stocks List
            if (stocks.isNotEmpty)
              ...stocks.asMap().entries.map((entry) {
                final index = entry.key;
                final stock = entry.value;

                return AnimationConfiguration.staggeredList(
                  position: index + 2,
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
              })
            else
              _buildEmptyState(context),

            // Loading indicator for refresh
            if (provider.isLoading && stocks.isNotEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: LoadingWidget()),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            color:
                Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
            fontWeight: FontWeight.w500,
          ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(
            Icons.trending_up_rounded,
            size: 80,
            color: Theme.of(context).textTheme.bodyMedium?.color ??
                Colors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No stocks available',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.8),
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Pull down to refresh',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.6),
                ),
          ),
        ],
      ),
    );
  }
}
