import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/breach_record.dart';
import '../providers/breach_catalog_provider.dart';
import '../widgets/breach_card.dart';
import 'breach_detail_page.dart';

/// Searchable breach catalog page (D-07).
///
/// Displays all known HIBP breaches with:
/// - Search field in app bar
/// - Filter chips (Verified only, Exclude sensitive)
/// - Sort dropdown (Newest, Largest, A-Z)
/// - ListView of BreachCard widgets
class BreachCatalogPage extends ConsumerStatefulWidget {
  const BreachCatalogPage({super.key});

  @override
  ConsumerState<BreachCatalogPage> createState() => _BreachCatalogPageState();
}

class _BreachCatalogPageState extends ConsumerState<BreachCatalogPage> {
  final _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredAsync = ref.watch(filteredBreachesProvider);
    final filter = ref.watch(breachFilterProvider);
    final sort = ref.watch(breachSortProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search breaches...',
                  border: InputBorder.none,
                ),
                onChanged: (value) {
                  ref.read(breachSearchQueryProvider.notifier).state = value;
                },
              )
            : const Text('Breach Catalog'),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref.read(breachSearchQueryProvider.notifier).state = '';
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter chips and sort dropdown
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Verified only'),
                  selected: filter.verifiedOnly,
                  onSelected: (value) {
                    ref.read(breachFilterProvider.notifier).state =
                        filter.copyWith(verifiedOnly: value);
                  },
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Exclude sensitive'),
                  selected: filter.excludeSensitive,
                  onSelected: (value) {
                    ref.read(breachFilterProvider.notifier).state =
                        filter.copyWith(excludeSensitive: value);
                  },
                ),
                const Spacer(),
                PopupMenuButton<BreachSort>(
                  initialValue: sort,
                  onSelected: (value) {
                    ref.read(breachSortProvider.notifier).state = value;
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: BreachSort.newest,
                      child: Text('Newest'),
                    ),
                    const PopupMenuItem(
                      value: BreachSort.largest,
                      child: Text('Largest'),
                    ),
                    const PopupMenuItem(
                      value: BreachSort.alphabetical,
                      child: Text('A-Z'),
                    ),
                  ],
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: theme.colorScheme.outlineVariant,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _sortLabel(sort),
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_drop_down, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Breach list
          Expanded(
            child: filteredAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, _) => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 48,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load breaches',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: () => ref.invalidate(breachCatalogProvider),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (breaches) {
                if (breaches.isEmpty) {
                  final query = ref.read(breachSearchQueryProvider);
                  return Center(
                    child: Text(
                      query.isNotEmpty
                          ? 'No results for "$query"'
                          : 'No breaches found',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: breaches.length,
                  itemBuilder: (context, index) {
                    final breach = breaches[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: BreachCard(
                        breach: breach,
                        onTap: () => _navigateToDetail(context, breach),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _sortLabel(BreachSort sort) {
    switch (sort) {
      case BreachSort.newest:
        return 'Newest';
      case BreachSort.largest:
        return 'Largest';
      case BreachSort.alphabetical:
        return 'A-Z';
    }
  }

  void _navigateToDetail(BuildContext context, BreachRecord breach) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BreachDetailPage(breach: breach),
      ),
    );
  }
}
