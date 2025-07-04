import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

import '../providers/search_provider.dart';
import '../../../dashboard/presentation/widgets/stock_card.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/loading_widget.dart';
import '../../../../shared/widgets/error_widget.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.trim().isNotEmpty) {
      context.read<SearchProvider>().searchStocks(query.trim());
    } else {
      context.read<SearchProvider>().clearSearch();
    }
  }

  void _onSearchHistoryTap(String query) {
    _searchController.text = query;
    _onSearchChanged(query);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Search Bar
          _buildSearchBar(),

          // Content
          Expanded(
            child: Consumer<SearchProvider>(
              builder: (context, searchProvider, child) {
                if (searchProvider.isLoading) {
                  return const Center(
                    child: LoadingWidget(
                      message: 'Searching stocks...',
                    ),
                  );
                }

                if (searchProvider.hasError) {
                  return Center(
                    child: CustomErrorWidget(
                      message: searchProvider.errorMessage!,
                      onRetry: () => searchProvider.searchStocks(
                        searchProvider.currentQuery,
                      ),
                    ),
                  );
                }

                if (searchProvider.searchResults.isNotEmpty) {
                  return _buildSearchResults(searchProvider);
                }

                if (searchProvider.currentQuery.isNotEmpty) {
                  return _buildNoResults();
                }

                return _buildSearchHistory(searchProvider);
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.search_rounded,
            color: Theme.of(context).colorScheme.primary,
            size: 28,
          ),
          const SizedBox(width: 12),
          Text(
            'Search Stocks',
            style: AppTheme.headingMedium.copyWith(
              color:
                  Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocusNode,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search stocks by name or symbol...',
            hintStyle: TextStyle(
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black.withOpacity(0.5),
            ),
            prefixIcon: Icon(
              Icons.search_rounded,
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black.withOpacity(0.7),
            ),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.black.withOpacity(0.7),
                    ),
                    onPressed: () {
                      _searchController.clear();
                      _onSearchChanged('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
          ),
          style: TextStyle(
            color:
                Theme.of(context).textTheme.bodyMedium?.color ?? Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(SearchProvider searchProvider) {
    return AnimationLimiter(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: searchProvider.searchResults.length,
        itemBuilder: (context, index) {
          final stock = searchProvider.searchResults[index];

          return AnimationConfiguration.staggeredList(
            position: index,
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
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 80,
            color: Theme.of(context).textTheme.bodyMedium?.color ??
                Colors.black.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No stocks found',
            style: AppTheme.headingSmall.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords',
            style: AppTheme.bodyMedium.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchHistory(SearchProvider searchProvider) {
    if (searchProvider.searchHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history_rounded,
              size: 80,
              color: Theme.of(context).textTheme.bodyMedium?.color ??
                  Colors.black.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Start searching',
              style: AppTheme.headingSmall.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Search for Indian stocks by name or symbol',
              style: AppTheme.bodyMedium.copyWith(
                color: Theme.of(context).textTheme.bodyMedium?.color ??
                    Colors.black.withOpacity(0.5),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Searches',
                style: AppTheme.headingSmall.copyWith(
                  color: Theme.of(context).textTheme.bodyMedium?.color ??
                      Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () => searchProvider.clearSearchHistory(),
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: searchProvider.searchHistory.length,
            itemBuilder: (context, index) {
              final query = searchProvider.searchHistory[index];

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.history_rounded,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.black.withOpacity(0.7),
                  ),
                  title: Text(
                    query,
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color ??
                          Colors.black,
                    ),
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color ??
                        Colors.black.withOpacity(0.5),
                  ),
                  onTap: () => _onSearchHistoryTap(query),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
