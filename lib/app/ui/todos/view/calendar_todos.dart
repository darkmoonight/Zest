import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/todos/widgets/selection_action_bar.dart';
import 'package:zest/app/ui/todos/widgets/sort_menu.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_screen_mixin.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/constants/app_constants.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/scroll_fab_handler.dart';
import 'package:zest/main.dart';

class CalendarTodos extends StatefulWidget {
  const CalendarTodos({super.key});

  @override
  State<CalendarTodos> createState() => _CalendarTodosState();
}

class _CalendarTodosState extends State<CalendarTodos>
    with SingleTickerProviderStateMixin, TodosScreenMixin {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime fDay = DateTime.now().add(const Duration(days: -1000));
  DateTime lDay = DateTime.now().add(const Duration(days: 1000));

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    initializeTodosScreen(
      initialSortOption: settings.calendarSortOption,
      vsync: this,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _updateFabVisibility();
  }

  void _updateFabVisibility() {
    if (!mounted) return;

    if (todoController.isMultiSelectionTodo.value) {
      fabController.setVisibility(false);
    } else if (tabController.index == 0) {
      fabController.setVisibility(true);
    } else {
      fabController.setVisibility(false);
    }
  }

  @override
  void dispose() {
    disposeTodosScreen();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: todoController.isPop.value,
        onPopInvokedWithResult: handlePopInvoked,
        child: Scaffold(body: SafeArea(child: _buildBody(context))),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Stack(
      children: [
        _buildScrollableContent(context),
        _buildSelectionActionBar(context),
      ],
    );
  }

  Widget _buildScrollableContent(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (todoController.isMultiSelectionTodo.value) {
          return true;
        }

        return ScrollFabHandler.handleScrollFabVisibility(
          notification: notification,
          tabController: tabController,
          fabController: fabController,
        );
      },
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: ScrollController(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildCalendar(context),
            _buildTabBar(context),
          ],
          body: _buildTabBarView(),
        ),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile
              ? AppConstants.spacingS + 2
              : AppConstants.spacingL,
        ),
        child: TableCalendar(
          firstDay: fDay,
          lastDay: lDay,
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          calendarFormat: _getCalendarFormat(),
          startingDayOfWeek: _getFirstDayOfWeek(),
          weekendDays: const [DateTime.sunday],
          locale: locale.languageCode,
          availableCalendarFormats: {
            CalendarFormat.month: 'month'.tr,
            CalendarFormat.twoWeeks: 'two_week'.tr,
            CalendarFormat.week: 'week'.tr,
          },
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) => Obx(() {
              final countTodos = todoController.countTotalTodosCalendar(day);
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
            }),
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
                AppConstants.borderRadiusSmall + 2,
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
            _focusedDay = focusedDay;
          },
        ),
      ),
    );
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });
    }
  }

  StartingDayOfWeek _getFirstDayOfWeek() {
    switch (firstDay.value) {
      case 'monday':
        return StartingDayOfWeek.monday;
      case 'tuesday':
        return StartingDayOfWeek.tuesday;
      case 'wednesday':
        return StartingDayOfWeek.wednesday;
      case 'thursday':
        return StartingDayOfWeek.thursday;
      case 'friday':
        return StartingDayOfWeek.friday;
      case 'saturday':
        return StartingDayOfWeek.saturday;
      case 'sunday':
        return StartingDayOfWeek.sunday;
      default:
        return StartingDayOfWeek.monday;
    }
  }

  CalendarFormat _getCalendarFormat() {
    switch (settings.calendarFormat) {
      case 'week':
        return CalendarFormat.week;
      case 'twoWeeks':
        return CalendarFormat.twoWeeks;
      case 'month':
        return CalendarFormat.month;
      default:
        return CalendarFormat.week;
    }
  }

  Future<void> _updateCalendarFormat(CalendarFormat format) async {
    switch (format) {
      case CalendarFormat.week:
        settings.calendarFormat = 'week';
        break;
      case CalendarFormat.twoWeeks:
        settings.calendarFormat = 'twoWeeks';
        break;
      case CalendarFormat.month:
        settings.calendarFormat = 'month';
        break;
    }
    await isar.writeTxn(() async {
      await isar.settings.put(settings);
    });
  }

  Widget _buildTabBar(BuildContext context) {
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
                onSortChanged: _handleSortChanged,
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

  Future<void> _handleSortChanged(SortOption option) async {
    updateSortOption(option);
    settings.calendarSortOption = option;
    await isar.writeTxn(() => isar.settings.put(settings));
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        TodosList(
          calendar: true,
          allTodos: false,
          statusFilter: TodoStatus.active,
          selectedDay: _selectedDay,
          searchTodo: searchFilter,
          sortOption: sortOption,
        ),
        TodosList(
          calendar: true,
          allTodos: false,
          statusFilter: TodoStatus.done,
          selectedDay: _selectedDay,
          searchTodo: searchFilter,
          sortOption: sortOption,
        ),
        TodosList(
          calendar: true,
          allTodos: false,
          statusFilter: TodoStatus.cancelled,
          selectedDay: _selectedDay,
          searchTodo: searchFilter,
          sortOption: sortOption,
        ),
      ],
    );
  }

  Widget _buildSelectionActionBar(BuildContext context) {
    return Obx(() {
      if (!todoController.isMultiSelectionTodo.isTrue) {
        return const SizedBox.shrink();
      }

      final selectedCount = todoController.selectedTodo.length;

      return SelectionActionBar(
        onTransfer: () => showTodosTransferSheet(context),
        onDelete: () => showDeleteDialog(context),
        onSelectAll: _toggleSelectAll,
        isAllSelected: _areAllSelectedInCurrentTab(),
        selectedCount: selectedCount,
      );
    });
  }

  bool _areAllSelectedInCurrentTab() {
    final statusFilter = tabController.index == 0
        ? TodoStatus.active
        : tabController.index == 1
        ? TodoStatus.done
        : TodoStatus.cancelled;
    return todoController.areAllSelected(
      statusFilter: statusFilter,
      searchQuery: searchFilter,
      selectedDay: _selectedDay,
    );
  }

  void _toggleSelectAll() {
    final allSelected = _areAllSelectedInCurrentTab();
    final statusFilter = tabController.index == 0
        ? TodoStatus.active
        : tabController.index == 1
        ? TodoStatus.done
        : TodoStatus.cancelled;

    todoController.selectAll(
      select: !allSelected,
      statusFilter: statusFilter,
      searchQuery: searchFilter,
      selectedDay: _selectedDay,
    );
  }
}
