import 'package:flutter/material.dart';
import '../../../../core/models/stock.dart';
import '../../../../shared/widgets/glass_container.dart';

/// A widget that displays market summary information
class MarketSummaryCard extends StatelessWidget {
  final List<Stock> stocks;

  const MarketSummaryCard({
    super.key,
    required this.stocks,
  });

  @override
  Widget build(BuildContext context) {
    final gainers = stocks.where((s) => s.changePercent > 0).length;
    final losers = stocks.where((s) => s.changePercent < 0).length;
    final totalValue =
        stocks.fold<double>(0, (sum, stock) => sum + stock.currentPrice);
    final avgChange = stocks.isNotEmpty
        ? stocks.fold<double>(0, (sum, stock) => sum + stock.changePercent) /
            stocks.length
        : 0.0;

    return MinimalGlassCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Market Summary',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Gainers',
                  gainers.toString(),
                  Colors.green,
                  Icons.trending_up,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Losers',
                  losers.toString(),
                  Colors.red,
                  Icons.trending_down,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Total Value',
                  '₹${totalValue.toStringAsFixed(0)}',
                  Theme.of(context).colorScheme.primary,
                  Icons.account_balance_wallet,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Avg Change',
                  '${avgChange >= 0 ? '+' : ''}${avgChange.toStringAsFixed(2)}%',
                  avgChange >= 0 ? Colors.green : Colors.red,
                  avgChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
