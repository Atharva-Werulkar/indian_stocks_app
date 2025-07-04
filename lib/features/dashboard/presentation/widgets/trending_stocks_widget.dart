import 'package:flutter/material.dart';
import '../../../../core/models/stock.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../stock_detail/presentation/pages/stock_detail_page.dart';

/// A widget that displays trending stocks in a horizontal scrollable list
class TrendingStocksWidget extends StatelessWidget {
  final List<Stock> stocks;

  const TrendingStocksWidget({
    super.key,
    required this.stocks,
  });

  @override
  Widget build(BuildContext context) {
    if (stocks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.whatshot_rounded,
              color: Colors.orange,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Trending Stocks',
              style: AppTheme.headingMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 4),
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: _buildTrendingStockCard(context, stock),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingStockCard(BuildContext context, Stock stock) {
    final isPositive = stock.changePercent >= 0;
    final changeColor = isPositive ? Colors.green : Colors.red;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StockDetailPage(stock: stock),
          ),
        );
      },
      child: Container(
        decoration: AppTheme.getCardDecoration(context),
        child: Container(
          width: 160,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      stock.symbol,
                      style: AppTheme.bodyMedium.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color ??
                            Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(
                    isPositive ? Icons.trending_up : Icons.trending_down,
                    color: changeColor,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                stock.formattedPrice,
                style: AppTheme.headingSmall.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Text(
                    stock.formattedChange,
                    style: AppTheme.bodySmall.copyWith(
                      color: changeColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '(${stock.formattedChangePercent})',
                    style: AppTheme.bodySmall.copyWith(
                      color: changeColor,
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
}
