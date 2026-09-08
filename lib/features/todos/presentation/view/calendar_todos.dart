import 'package:flutter/material.dart' as flutter;
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/core/navigation/home_tabs.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/i18n/tr.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/todos/presentation/widgets/todos_screen_mixin.dart';
import 'package:zest/features/todos/presentation/widgets/todos_status_tab_bar.dart';
import 'package:zest/features/todos/presentation/widgets/todos_tab_views.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/services/recurrence_service.dart';
import 'package:zest/core/utils/calendar_format_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/scroll_fab_listener.dart';

/// Calendar tab: day picker plus filtered list for the selected day.
class CalendarTodos extends ConsumerStatefulWidget {
  /// Creates a [CalendarTodos].
  const CalendarTodos({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<CalendarTodos> createState() => _CalendarTodosState();
}

class _CalendarTodosState extends ConsumerState<CalendarTodos>
    with
        SingleTickerProviderStateMixin,
        TodosScreenMixin,
        WidgetsBindingObserver {
  /// Focused day.
  DateTime _focusedDay = DateTime.now();

  /// The selected day.
  DateTime? _selectedDay;

  /// Calendar day when selection was last auto-synced to "today".
  ///
  /// Used so resume/tab-enter only jump when the calendar day actually changed.
  late DateTime _calendarDayAtLastSync;

  /// F day.
  DateTime fDay = DateTime.now().subtract(AppConstants.calendarSelectableRange);

  /// L day.
  DateTime lDay = DateTime.now().add(AppConstants.calendarSelectableRange);

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final now = DateTime.now();
    _focusedDay = now;
    _selectedDay = now;
    _calendarDayAtLastSync = RecurrenceService.calendarDay(now);
    initializeTodosScreen(
      initialSortOption: ref.read(settingsProvider).calendarSortOption,
      vsync: this,
    );
    setupTodosScreenListeners();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateFabVisibility();
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeTodosScreen();
    super.dispose();
  }

  @override
  /// Syncs the calendar when the app returns to the foreground.
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _syncCalendarToTodayIfNeeded();
    }
  }

  /// Jumps to today only when the calendar day changed since last sync.
  void _syncCalendarToTodayIfNeeded() {
    final now = DateTime.now();
    final today = RecurrenceService.calendarDay(now);
    if (isSameDay(_calendarDayAtLastSync, today)) return;

    _calendarDayAtLastSync = today;
    if (isSameDay(_selectedDay, today)) return;

    setState(() {
      _focusedDay = today;
      _selectedDay = today;
    });
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    ref.listen<int>(homeTabIndexProvider, (previous, next) {
      if (next == calendarTabIndex && previous != calendarTabIndex) {
        _syncCalendarToTodayIfNeeded();
      }
    });

    final todosState = ref.watch(todosNotifierProvider);

    return PopScope(
      canPop: todosState.isPop,
      onPopInvokedWithResult: handlePopInvoked,
      child: Scaffold(body: SafeArea(child: _buildBody(context, todosState))),
    );
  }

  /// Builds the body widget.
  Widget _buildBody(BuildContext context, TodosState todosState) {
    return Stack(
      children: [
        _buildScrollableContent(context, todosState),
        _buildSelectionActionBar(context, todosState),
      ],
    );
  }

  /// Builds the scrollable content widget.
  Widget _buildScrollableContent(BuildContext context, TodosState todosState) {
    final showArchived = ref.watch(settingsProvider).showArchivedInCalendar;
    final excludeArchived = !showArchived;

    return ScrollFabListener(
      tabController: tabController,
      setFabVisibility: setFabVisible,
      disabled: todosState.isMultiSelectionTodo,
      child: NestedScrollView(
        controller: scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          _buildCalendar(context, excludeArchived),
          TodosStatusTabBar(
            tabController: tabController,
            sortOption: sortOption,
            onSortChanged: _handleSortChanged,
            showArchived: showArchived,
            onShowArchivedChanged: _handleShowArchivedChanged,
          ),
        ],
        body: TodosTabViews(
          config: TodosTabViewsConfig(
            tabController: tabController,
            searchFilter: searchFilter,
            sortOption: sortOption,
            calendar: true,
            selectedDay: _selectedDay,
            excludeArchivedCategories: excludeArchived,
          ),
        ),
      ),
    );
  }

  /// Builds the calendar widget.
  Widget _buildCalendar(BuildContext context, bool excludeArchived) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);
    final dayCounts = ref
        .read(todosNotifierProvider.notifier)
        .calendarDayCounts(excludeArchivedCategories: excludeArchived);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile
              ? AppConstants.spacingS + 2
              : AppConstants.spacingL,
        ),
        // table_calendar uses package:flutter/material InkWell; material_ui's
        // Material is a different type, so provide a Flutter Material ancestor.
        child: flutter.Material(
          type: flutter.MaterialType.transparency,
          child: TableCalendar(
            firstDay: fDay,
            lastDay: lDay,
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: _getCalendarFormat(),
            startingDayOfWeek: _getFirstDayOfWeek(),
            weekendDays: const [DateTime.sunday],
            locale: ref.watch(appSettingsProvider).locale.languageCode,
            availableCalendarFormats: {
              CalendarFormat.month: 'month'.tr,
              CalendarFormat.twoWeeks: 'two_week'.tr,
              CalendarFormat.week: 'week'.tr,
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                final key = DateTime(day.year, day.month, day.day);
                final countTodos = dayCounts[key] ?? 0;
                if (countTodos == 0) return const SizedBox.shrink();

                return Positioned(
                  bottom: 1,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: colorScheme.tertiary,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '$countTodos',
                        style: TextStyle(
                          color: colorScheme.onTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              todayTextStyle: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w600,
              ),
              selectedTextStyle: TextStyle(
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w600,
              ),
              weekendTextStyle: TextStyle(color: colorScheme.error),
              outsideDaysVisible: false,
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: true,
              titleCentered: true,
              formatButtonShowsNext: false,
              titleTextStyle: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 16),
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              formatButtonTextStyle: TextStyle(
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
                color: colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
              formatButtonDecoration: BoxDecoration(
                border: Border.all(
                  color: colorScheme.primary.withValues(alpha: 0.5),
                  width: AppConstants.borderWidthThin,
                ),
                borderRadius: BorderRadius.circular(
                  AppConstants.borderRadiusCompact,
                ),
              ),
              leftChevronIcon: Icon(
                IconsaxPlusLinear.arrow_left_1,
                color: colorScheme.onSurface,
                size: AppConstants.iconSizeMedium,
              ),
              rightChevronIcon: Icon(
                IconsaxPlusLinear.arrow_right_3,
                color: colorScheme.onSurface,
                size: AppConstants.iconSizeMedium,
              ),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
              weekendStyle: TextStyle(
                color: colorScheme.error.withValues(alpha: 0.7),
                fontWeight: FontWeight.w600,
                fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              ),
            ),
            onDaySelected: _onDaySelected,
            onFormatChanged: (format) {
              _updateCalendarFormat(format);
              setState(() {});
            },
            onPageChanged: (focusedDay) {
              setState(() => _focusedDay = focusedDay);
            },
          ),
        ),
      ),
    );
  }

  /// On day selected.
  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  /// Get first day of week from the live settings instance.
  StartingDayOfWeek _getFirstDayOfWeek() =>
      CalendarFormatHelper.startingDayOfWeekFromString(
        ref.read(liveSettingsProvider).firstDay,
      );

  /// Get calendar format from the live settings instance (avoids clone lag).
  CalendarFormat _getCalendarFormat() =>
      CalendarFormatHelper.calendarFormatFromString(
        ref.read(liveSettingsProvider).calendarFormat,
      );

  /// Persists the Calendar view format.
  Future<void> _updateCalendarFormat(CalendarFormat format) async {
    await ref.writeLiveSettings(
      mutate: (s) => s.calendarFormat =
          CalendarFormatHelper.calendarFormatToString(format),
    );
  }

  /// Persists archived-category visibility on Calendar.
  Future<void> _handleShowArchivedChanged(bool value) async {
    await ref.writeLiveSettings(
      mutate: (s) => s.showArchivedInCalendar = value,
    );
    if (mounted) setState(() {});
  }

  /// Persists the Calendar sort option.
  Future<void> _handleSortChanged(SortOption option) async {
    updateSortOption(option);
    await ref.writeLiveSettings(mutate: (s) => s.calendarSortOption = option);
  }

  /// Builds the selection action bar widget.
  Widget _buildSelectionActionBar(BuildContext context, TodosState todosState) {
    return buildSelectionActionBar(
      isMultiSelection: todosState.isMultiSelectionTodo,
      selectedCount: todosState.selectedTodo.length,
      onTransfer: () => showTodosTransferSheet(context),
      onDelete: () => showDeleteDialog(context),
      onSelectAll: _toggleSelectAll,
      isAllSelected: _areAllSelectedInCurrentTab(),
    );
  }

  /// Are all selected in current tab.
  bool _areAllSelectedInCurrentTab() {
    final excludeArchived = !ref.read(settingsProvider).showArchivedInCalendar;
    return todosNotifier.areAllSelected(
      statusFilter: TodoStatus.fromTabIndex(tabController.index),
      searchQuery: searchFilter,
      selectedDay: _selectedDay,
      excludeArchivedCategories: excludeArchived,
    );
  }

  void _toggleSelectAll() {
    final excludeArchived = !ref.read(settingsProvider).showArchivedInCalendar;
    final allSelected = _areAllSelectedInCurrentTab();
    todosNotifier.selectAll(
      select: !allSelected,
      statusFilter: TodoStatus.fromTabIndex(tabController.index),
      searchQuery: searchFilter,
      selectedDay: _selectedDay,
      excludeArchivedCategories: excludeArchived,
    );
  }
}
