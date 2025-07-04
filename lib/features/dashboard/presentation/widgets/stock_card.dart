import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/stock.dart';
import '../../../watchlist/presentation/providers/watchlist_provider.dart';
import '../../../../shared/widgets/glass_container.dart';

class StockCard extends StatefulWidget {
  final Stock stock;
  final bool showWatchlistButton;
  final VoidCallback? onTap;

  const StockCard({
    super.key,
    required this.stock,
    this.showWatchlistButton = true,
    this.onTap,
  });

  @override
  _StockCardState createState() => _StockCardState();
}

class _StockCardState extends State<StockCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _onTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  void _navigateToStockDetail() {
    // Navigator.of(context).push(
    //   PageRouteBuilder(
    //     pageBuilder: (context, animation, secondaryAnimation) =>
    //         StockDetailPage(stock: widget.stock),
    //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
    //       return SlideTransition(
    //         position: Tween<Offset>(
    //           begin: const Offset(1.0, 0.0),
    //           end: Offset.zero,
    //         ).animate(CurvedAnimation(
    //           parent: animation,
    //           curve: Curves.easeInOut,
    //         )),
    //         child: child,
    //       );
    //     },
    //     transitionDuration: const Duration(milliseconds: 300),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTapDown: _onTapDown,
            onTapUp: _onTapUp,
            onTapCancel: _onTapCancel,
            onTap: widget.onTap ?? _navigateToStockDetail,
            child: MinimalGlassCard(
              onTap: widget.onTap ?? _navigateToStockDetail,
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  _buildStockInfo(),
                  const Spacer(),
                  _buildPriceInfo(),
                  if (widget.showWatchlistButton) ...[
                    const SizedBox(width: 12),
                    _buildWatchlistButton(),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStockInfo() {
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.stock.symbol.replaceAll('.BSE', '').replaceAll('.NSE', ''),
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontWeight: FontWeight.w500,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.stock.name,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withOpacity(0.7),
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.business_rounded,
                size: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                widget.stock.exchange,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5),
                    ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.volume_up_rounded,
                size: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black.withOpacity(0.5),
              ),
              const SizedBox(width: 4),
              Text(
                widget.stock.formattedVolume,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.5),
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPriceInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          widget.stock.formattedPrice,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            gradient: widget.stock.isGaining
                ? LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  )
                : LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                  ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.stock.isGaining
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 4),
              Text(
                widget.stock.formattedChangePercent,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.stock.formattedChange,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: widget.stock.isGaining ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
        ),
      ],
    );
  }

  Widget _buildWatchlistButton() {
    return Consumer<WatchlistProvider>(
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
                : Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          ),
        );
      },
    );
  }
}
