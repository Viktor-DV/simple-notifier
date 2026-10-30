import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectedCategoryProvider = StateProvider<String>((ref) => 'all');

final searchQueryProvider = StateProvider<String>((ref) => '');

/// Sort by reminder date (scheduledAt).
enum SortType { dateAsc, dateDesc }

final sortTypeProvider =
    StateProvider<SortType>((ref) => SortType.dateAsc);
