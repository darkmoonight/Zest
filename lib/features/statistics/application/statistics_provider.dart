import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/domain/usecases/statistics_usecases.dart';
import 'package:zest/domain/models/statistics_data.dart';
import 'package:zest/features/categories/application/categories_notifier.dart';
import 'package:zest/features/todos/application/todos_notifier.dart';

/// Recomputes statistics when item/category revisions or settings change.
final statisticsProvider = FutureProvider<StatisticsData>((ref) async {
  // Revision-only watches avoid reloads on multi-select / filter noise.
  ref.watch(todosNotifierProvider.select((s) => s.todosRevision));
  ref.watch(categoriesNotifierProvider.select((s) => s.categoriesRevision));
  final includeArchived = ref.watch(
    settingsProvider.select((s) => s.showArchivedInStatistics),
  );

  final todoRepo = ref.watch(todoRepositoryProvider);
  final categoryRepo = ref.watch(categoryRepositoryProvider);
  return StatisticsService.calculateStatistics(
    todoRepo,
    categoryRepo: categoryRepo,
    includeArchivedCategories: includeArchived,
  );
});
