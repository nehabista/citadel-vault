import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/models/breach_record.dart';

/// Fetches the full HIBP breach catalog via BreachRepository with 7-day cache.
final breachCatalogProvider = FutureProvider<List<BreachRecord>>((ref) async {
  final breachRepo = ref.read(breachRepositoryProvider);
  return breachRepo.getAllBreachesCached();
});

/// Search query state for the breach catalog.
final breachSearchQueryProvider = StateProvider<String>((ref) => '');

/// Filter options for the breach catalog.
class BreachFilter {
  final bool verifiedOnly;
  final bool excludeSensitive;

  const BreachFilter({
    this.verifiedOnly = false,
    this.excludeSensitive = false,
  });

  BreachFilter copyWith({
    bool? verifiedOnly,
    bool? excludeSensitive,
  }) {
    return BreachFilter(
      verifiedOnly: verifiedOnly ?? this.verifiedOnly,
      excludeSensitive: excludeSensitive ?? this.excludeSensitive,
    );
  }
}

/// Filter state for the breach catalog.
final breachFilterProvider = StateProvider<BreachFilter>(
  (ref) => const BreachFilter(),
);

/// Sort options for the breach catalog (D-07).
enum BreachSort {
  newest,
  largest,
  alphabetical,
}

/// Sort state for the breach catalog.
final breachSortProvider = StateProvider<BreachSort>(
  (ref) => BreachSort.newest,
);

/// Combined filtered + searched + sorted breach list.
///
/// Combines breachCatalogProvider data with search, filter, and sort state.
final filteredBreachesProvider = Provider<AsyncValue<List<BreachRecord>>>((ref) {
  final catalogAsync = ref.watch(breachCatalogProvider);
  final query = ref.watch(breachSearchQueryProvider).toLowerCase();
  final filter = ref.watch(breachFilterProvider);
  final sort = ref.watch(breachSortProvider);

  return catalogAsync.whenData((breaches) {
    var result = breaches.toList();

    // Search: filter by name/title/domain containing query (case-insensitive)
    if (query.isNotEmpty) {
      result = result.where((b) {
        return b.name.toLowerCase().contains(query) ||
            b.title.toLowerCase().contains(query) ||
            b.domain.toLowerCase().contains(query);
      }).toList();
    }

    // Filter: verified only
    if (filter.verifiedOnly) {
      result = result.where((b) => b.verified).toList();
    }

    // Filter: exclude sensitive
    if (filter.excludeSensitive) {
      result = result.where((b) => !b.isSensitive).toList();
    }

    // Sort
    switch (sort) {
      case BreachSort.newest:
        result.sort((a, b) => b.breachDate.compareTo(a.breachDate));
        break;
      case BreachSort.largest:
        result.sort((a, b) => (b.pwnCount ?? 0).compareTo(a.pwnCount ?? 0));
        break;
      case BreachSort.alphabetical:
        result.sort(
            (a, b) => a.displayTitle.toLowerCase().compareTo(b.displayTitle.toLowerCase()));
        break;
    }

    return result;
  });
});
