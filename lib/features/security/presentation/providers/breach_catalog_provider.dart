import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/core_providers.dart';
import '../../data/models/breach_record.dart';

/// Fetches the full HIBP breach catalog via BreachRepository with 7-day cache.
final breachCatalogProvider = FutureProvider<List<BreachRecord>>((ref) async {
  final breachRepo = ref.read(breachRepositoryProvider);
  return breachRepo.getAllBreachesCached();
});

/// Search query state for the breach catalog.
class BreachSearchNotifier extends Notifier<String> {
  @override
  String build() => '';

  void update(String query) => state = query;
}

final breachSearchQueryProvider =
    NotifierProvider<BreachSearchNotifier, String>(BreachSearchNotifier.new);

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

class BreachFilterNotifier extends Notifier<BreachFilter> {
  @override
  BreachFilter build() => const BreachFilter();

  void update(BreachFilter filter) => state = filter;
}

final breachFilterProvider =
    NotifierProvider<BreachFilterNotifier, BreachFilter>(
        BreachFilterNotifier.new);

/// Sort options for the breach catalog (D-07).
enum BreachSort {
  newest,
  largest,
  alphabetical,
}

class BreachSortNotifier extends Notifier<BreachSort> {
  @override
  BreachSort build() => BreachSort.newest;

  void update(BreachSort sort) => state = sort;
}

final breachSortProvider =
    NotifierProvider<BreachSortNotifier, BreachSort>(BreachSortNotifier.new);

/// Combined filtered + searched + sorted breach list.
final filteredBreachesProvider =
    Provider<AsyncValue<List<BreachRecord>>>((ref) {
  final catalogAsync = ref.watch(breachCatalogProvider);
  final query = ref.watch(breachSearchQueryProvider).toLowerCase();
  final filter = ref.watch(breachFilterProvider);
  final sort = ref.watch(breachSortProvider);

  return catalogAsync.whenData((breaches) {
    var result = breaches.toList();

    if (query.isNotEmpty) {
      result = result.where((b) {
        return b.name.toLowerCase().contains(query) ||
            b.title.toLowerCase().contains(query) ||
            b.domain.toLowerCase().contains(query);
      }).toList();
    }

    if (filter.verifiedOnly) {
      result = result.where((b) => b.verified).toList();
    }

    if (filter.excludeSensitive) {
      result = result.where((b) => !b.isSensitive).toList();
    }

    switch (sort) {
      case BreachSort.newest:
        result.sort((a, b) => b.breachDate.compareTo(a.breachDate));
      case BreachSort.largest:
        result.sort((a, b) => (b.pwnCount ?? 0).compareTo(a.pwnCount ?? 0));
      case BreachSort.alphabetical:
        result.sort((a, b) => a.displayTitle
            .toLowerCase()
            .compareTo(b.displayTitle.toLowerCase()));
    }

    return result;
  });
});
