import 'package:material_ui/material_ui.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/widgets/my_delegate.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/widgets/sort_menu.dart';
import 'package:zest/i18n/tr.dart';

/// Status tab bar sliver with optional archived toggle in [SortMenu].
class TodosStatusTabBar extends StatelessWidget {
  /// Creates a pinned status tab bar for todo screens.
  const TodosStatusTabBar({
    super.key,
    required this.tabController,
    required this.sortOption,
    required this.onSortChanged,
    this.showArchived,
    this.onShowArchivedChanged,
  });

  /// Tab controller for doing / done / cancelled tabs.
  final TabController tabController;

  /// Current sort option shown in [SortMenu].
  final SortOption sortOption;

  /// Persists and applies a new sort option.
  final ValueChanged<SortOption> onSortChanged;

  /// When set, shows the archived-categories toggle in [SortMenu].
  final bool? showArchived;

  /// Called when the archived toggle changes.
  final ValueChanged<bool>? onShowArchivedChanged;

  @override
  Widget build(BuildContext context) {
    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverPersistentHeader(
        delegate: MyDelegate(
          child: Row(
            children: [
              Expanded(
                child: TabBar(
                  tabAlignment: TabAlignment.start,
                  controller: tabController,
                  isScrollable: true,
                  dividerColor: Colors.transparent,
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: [
                    Tab(text: 'doing'.tr),
                    Tab(text: 'done'.tr),
                    Tab(text: 'cancelled'.tr),
                  ],
                ),
              ),
              SortMenu(
                currentSortOption: sortOption,
                onSortChanged: onSortChanged,
                showArchived: showArchived,
                onShowArchivedChanged: onShowArchivedChanged,
              ),
              SizedBox(width: AppConstants.spacingS),
            ],
          ),
        ),
        floating: true,
        pinned: true,
      ),
    );
  }
}
