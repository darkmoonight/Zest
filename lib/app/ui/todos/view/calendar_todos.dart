import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_transfer.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/app/utils/responsive_utils.dart';
import 'package:zest/app/utils/scroll_fab_handler.dart';
import 'package:zest/main.dart';

class CalendarTodos extends StatefulWidget {
  const CalendarTodos({super.key});

  @override
  State<CalendarTodos> createState() => _CalendarTodosState();
}

class _CalendarTodosState extends State<CalendarTodos>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  final fabController = Get.find<FabController>();
  late TabController tabController;
  DateTime selectedDay = DateTime.now();
  DateTime focusedDay = DateTime.now();
  DateTime fDay = DateTime.now().add(const Duration(days: -1000));
  DateTime lDay = DateTime.now().add(const Duration(days: 1000));

  SortOption _sortOption = SortOption.none;

  @override
  void initState() {
    super.initState();
    _sortOption = settings.sortOption;
    tabController = TabController(vsync: this, length: 2);
    tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    tabController.removeListener(_onTabChanged);
    tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (tabController.index == 1) {
      fabController.hide();
    } else {
      fabController.show();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => PopScope(
        canPop: todoController.isPop.value,
        onPopInvokedWithResult: _handlePopInvokedWithResult,
        child: Scaffold(
          appBar: _buildAppBar(context),
          body: _buildBody(context),
        ),
      ),
    );
  }

  void _handlePopInvokedWithResult(bool didPop, dynamic value) {
    if (didPop) return;
    if (todoController.isMultiSelectionTodo.isTrue) {
      todoController.doMultiSelectionTodoClear();
    }
  }

  AppBar _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppBar(
      centerTitle: true,
      leading: _buildLeadingIconButton(),
      title: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildTitle(context),
      ),
      actions: _buildActions(context, colorScheme),
    );
  }

  IconButton? _buildLeadingIconButton() {
    return todoController.isMultiSelectionTodo.isTrue
        ? IconButton(
            onPressed: () => todoController.doMultiSelectionTodoClear(),
            icon: const Icon(IconsaxPlusLinear.close_square, size: 22),
            tooltip: 'cancel'.tr,
          )
        : null;
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      'calendar'.tr,
      key: ValueKey(todoController.isMultiSelectionTodo.value),
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        fontSize: ResponsiveUtils.getResponsiveFontSize(context, 20),
      ),
    );
  }

  List<Widget> _buildActions(BuildContext context, ColorScheme colorScheme) {
    return [
      _buildTransferIconButton(context, colorScheme),
      _buildDeleteIconButton(context, colorScheme),
    ];
  }

  Widget _buildTransferIconButton(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    return AnimatedOpacity(
      opacity: todoController.selectedTodo.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: todoController.selectedTodo.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            IconsaxPlusLinear.arrange_square_2,
            size: 22,
            color: todoController.selectedTodo.isNotEmpty
                ? colorScheme.primary
                : Colors.transparent,
          ),
          onPressed: todoController.selectedTodo.isNotEmpty
              ? () => _showTodosTransferBottomSheet(context)
              : null,
          tooltip: 'transfer'.tr,
        ),
      ),
    );
  }

  void _showTodosTransferBottomSheet(BuildContext context) {
    showModalBottomSheet(
      enableDrag: false,
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) =>
          TodosTransfer(text: 'editing'.tr, todos: todoController.selectedTodo),
    );
  }

  Widget _buildDeleteIconButton(BuildContext context, ColorScheme colorScheme) {
    return AnimatedOpacity(
      opacity: todoController.selectedTodo.isNotEmpty ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: AnimatedScale(
        scale: todoController.selectedTodo.isNotEmpty ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 200),
        child: IconButton(
          icon: Icon(
            IconsaxPlusLinear.trash_square,
            size: 22,
            color: todoController.selectedTodo.isNotEmpty
                ? colorScheme.error
                : Colors.transparent,
          ),
          onPressed: todoController.selectedTodo.isNotEmpty
              ? () => _showDeleteConfirmationDialog(context)
              : null,
          tooltip: 'delete'.tr,
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: colorScheme.outlineVariant.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.errorContainer.withValues(
                          alpha: 0.3,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        IconsaxPlusBold.trash,
                        size: 32,
                        color: colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'deletedTodo'.tr,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                            fontSize: ResponsiveUtils.getResponsiveFontSize(
                              context,
                              20,
                            ),
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'deletedTodoQuery'.tr,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: ResponsiveUtils.getResponsiveFontSize(
                          context,
                          14,
                        ),
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'cancel'.tr,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        FilledButton.tonal(
                          onPressed: () {
                            todoController.deleteTodo(
                              todoController.selectedTodo,
                            );
                            todoController.doMultiSelectionTodoClear();
                            Navigator.of(context).pop();
                          },
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            backgroundColor: colorScheme.errorContainer,
                            foregroundColor: colorScheme.onErrorContainer,
                          ),
                          child: Text(
                            'delete'.tr,
                            style: TextStyle(
                              fontSize: ResponsiveUtils.getResponsiveFontSize(
                                context,
                                14,
                              ),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) => handleScrollFabVisibility(
        notification: notification,
        tabController: tabController,
        fabController: fabController,
        context: context,
      ),
      child: DefaultTabController(
        length: 2,
        child: NestedScrollView(
          controller: ScrollController(),
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            _buildTableCalendar(context),
            _buildTabBar(context),
          ],
          body: _buildTabBarView(),
        ),
      ),
    );
  }

  Widget _buildTableCalendar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isMobile = ResponsiveUtils.isMobile(context);

    return SliverToBoxAdapter(
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
        ),
        child: TableCalendar(
          calendarBuilders: CalendarBuilders(
            markerBuilder: (context, day, events) => Obx(() {
              var countTodos = todoController.countTotalTodosCalendar(day);
              return countTodos != 0
                  ? isSameDay(selectedDay, day)
                        ? _buildSelectedDayMarker(countTodos, colorScheme)
                        : _buildDayMarker(countTodos, colorScheme)
                  : const SizedBox.shrink();
            }),
          ),
          startingDayOfWeek: _getFirstDayOfWeek(),
          weekendDays: const [DateTime.sunday],
          firstDay: fDay,
          lastDay: lDay,
          focusedDay: focusedDay,
          locale: locale.languageCode,
          availableCalendarFormats: {
            CalendarFormat.month: 'week'.tr,
            CalendarFormat.twoWeeks: 'month'.tr,
            CalendarFormat.week: 'two_week'.tr,
          },
          selectedDayPredicate: (day) => isSameDay(selectedDay, day),
          onDaySelected: (selected, focused) => setState(() {
            selectedDay = selected;
            focusedDay = focused;
          }),
          onPageChanged: (focused) => setState(() => focusedDay = focused),
          onFormatChanged: (format) =>
              setState(() => _updateCalendarFormat(format)),
          calendarFormat: _getCalendarFormat(),
          calendarStyle: CalendarStyle(
            markerSize: 0,
            markersMaxCount: 1,
            todayDecoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            todayTextStyle: TextStyle(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w600,
            ),
            selectedDecoration: BoxDecoration(
              color: colorScheme.primary,
              shape: BoxShape.circle,
            ),
            selectedTextStyle: TextStyle(
              color: colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
            weekendTextStyle: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
            defaultTextStyle: TextStyle(color: colorScheme.onSurface),
            outsideTextStyle: TextStyle(
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
            ),
          ),
          headerStyle: HeaderStyle(
            titleCentered: true,
            formatButtonVisible: true,
            titleTextStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 17),
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            formatButtonTextStyle: TextStyle(
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
              fontWeight: FontWeight.w600,
              color: colorScheme.primary,
            ),
            formatButtonDecoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            leftChevronIcon: Icon(
              IconsaxPlusLinear.arrow_left_1,
              color: colorScheme.onSurface,
              size: 20,
            ),
            rightChevronIcon: Icon(
              IconsaxPlusLinear.arrow_right_3,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
          daysOfWeekStyle: DaysOfWeekStyle(
            weekdayStyle: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
            ),
            weekendStyle: TextStyle(
              color: colorScheme.error.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedDayMarker(int countTodos, ColorScheme colorScheme) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        color: colorScheme.tertiaryContainer,
        shape: BoxShape.circle,
        border: Border.all(color: colorScheme.tertiary, width: 2),
      ),
      child: Center(
        child: Text(
          '$countTodos',
          style: TextStyle(
            color: colorScheme.onTertiaryContainer,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ),
    );
  }

  Widget _buildDayMarker(int countTodos, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$countTodos',
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
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

  void _updateCalendarFormat(CalendarFormat format) => isar.writeTxnSync(() {
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
    isar.settings.putSync(settings);
  });

  Widget _buildTabBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SliverOverlapAbsorber(
      handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
      sliver: SliverPersistentHeader(
        delegate: MyDelegate(
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: TabBar(
                    tabAlignment: TabAlignment.start,
                    controller: tabController,
                    isScrollable: true,
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: WidgetStateProperty.resolveWith<Color?>(
                      (Set<WidgetState> states) => Colors.transparent,
                    ),
                    tabs: [
                      Tab(text: 'doing'.tr),
                      Tab(text: 'done'.tr),
                    ],
                  ),
                ),
                _buildSortButton(context, colorScheme),
                if (todoController.isMultiSelectionTodo.isTrue)
                  AnimatedScale(
                    scale: 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Checkbox(
                      value: _areAllSelectedInCurrentTab(),
                      onChanged: (val) =>
                          _selectAllInCurrentTab(val ?? false),
                      shape: const CircleBorder(),
                    ),
                  ),
                const SizedBox(width: 8),
              ],
            ),
          ),
          height: kTextTabBarHeight,
        ),
        floating: true,
        pinned: true,
      ),
    );
  }

  Widget _buildSortButton(BuildContext context, ColorScheme colorScheme) {
    return PopupMenuButton<SortOption>(
      tooltip: 'sort'.tr,
      icon: Icon(
        IconsaxPlusLinear.sort,
        size: 22,
        color: colorScheme.onSurface,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      onSelected: (SortOption option) {
        setState(() => _sortOption = option);
        settings.sortOption = option;
        isar.writeTxnSync(() => isar.settings.putSync(settings));
      },
      itemBuilder: (context) => <PopupMenuEntry<SortOption>>[
        _buildSortMenuItem(
          SortOption.none,
          'sortByIndex'.tr,
          IconsaxPlusLinear.menu,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.alphaAsc,
          'sortByNameAsc'.tr,
          IconsaxPlusLinear.text,
        ),
        _buildSortMenuItem(
          SortOption.alphaDesc,
          'sortByNameDesc'.tr,
          IconsaxPlusLinear.text,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.dateAsc,
          'sortByDateAsc'.tr,
          IconsaxPlusLinear.calendar_1,
        ),
        _buildSortMenuItem(
          SortOption.dateDesc,
          'sortByDateDesc'.tr,
          IconsaxPlusLinear.calendar_1,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.dateNotifAsc,
          'sortByDateNotifAsc'.tr,
          IconsaxPlusLinear.notification,
        ),
        _buildSortMenuItem(
          SortOption.dateNotifDesc,
          'sortByDateNotifDesc'.tr,
          IconsaxPlusLinear.notification,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.priorityAsc,
          'sortByPriorityAsc'.tr,
          IconsaxPlusLinear.flag,
        ),
        _buildSortMenuItem(
          SortOption.priorityDesc,
          'sortByPriorityDesc'.tr,
          IconsaxPlusLinear.flag,
        ),
        const PopupMenuDivider(),
        _buildSortMenuItem(
          SortOption.random,
          'sortByRandom'.tr,
          IconsaxPlusLinear.shuffle,
        ),
      ],
    );
  }

  PopupMenuItem<SortOption> _buildSortMenuItem(
    SortOption value,
    String text,
    IconData icon,
  ) {
    return PopupMenuItem(
      value: value,
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: _sortOption == value
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: _sortOption == value
                    ? FontWeight.w600
                    : FontWeight.w400,
                color: _sortOption == value
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: tabController,
      children: [
        TodosList(
          allTodos: false,
          calendar: true,
          done: false,
          selectedDay: selectedDay,
          searchTodo: '',
          sortOption: _sortOption,
        ),
        TodosList(
          allTodos: false,
          calendar: true,
          done: true,
          selectedDay: selectedDay,
          searchTodo: '',
          sortOption: _sortOption,
        ),
      ],
    );
  }

  bool _areAllSelectedInCurrentTab() {
    final isDone = tabController.index == 1;
    return todoController.areAllSelected(
      done: isDone,
      selectedDay: selectedDay,
    );
  }

  void _selectAllInCurrentTab(bool select) {
    final isDone = tabController.index == 1;
    todoController.selectAll(
      select: select,
      done: isDone,
      selectedDay: selectedDay,
    );
  }
}
