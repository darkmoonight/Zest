import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/todo_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/todos/widgets/todos_list.dart';
import 'package:zest/app/ui/todos/widgets/todos_transfer.dart';
import 'package:zest/app/ui/widgets/my_delegate.dart';
import 'package:zest/main.dart';

class CalendarTodos extends StatefulWidget {
  const CalendarTodos({super.key});

  @override
  State<CalendarTodos> createState() => _CalendarTodosState();
}

class _CalendarTodosState extends State<CalendarTodos>
    with SingleTickerProviderStateMixin {
  final todoController = Get.put(TodoController());
  late TabController tabController;
  DateTime selectedDay = DateTime.now();
  DateTime fDay = DateTime.now().add(const Duration(days: -1000));
  DateTime lDay = DateTime.now().add(const Duration(days: 1000));

  @override
  void initState() {
    super.initState();
    tabController = TabController(vsync: this, length: 2);
  }

  @override
  void dispose() {
    tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Obx(
    () => PopScope(
      canPop: todoController.isPop.value,
      onPopInvokedWithResult: _handlePopInvokedWithResult,
      child: Scaffold(appBar: _buildAppBar(context), body: _buildBody(context)),
    ),
  );

  void _handlePopInvokedWithResult(bool didPop, dynamic value) {
    if (didPop) {
      return;
    }

    if (todoController.isMultiSelectionTodo.isTrue) {
      todoController.doMultiSelectionTodoClear();
    }
  }

  AppBar _buildAppBar(BuildContext context) => AppBar(
    centerTitle: true,
    leading: _buildLeadingIconButton(),
    title: _buildTitle(),
    actions: _buildActions(context),
  );

  IconButton? _buildLeadingIconButton() =>
      todoController.isMultiSelectionTodo.isTrue
      ? IconButton(
          onPressed: () => todoController.doMultiSelectionTodoClear(),
          icon: const Icon(IconsaxPlusLinear.close_square, size: 20),
        )
      : null;

  Text _buildTitle() => Text(
    'calendar'.tr,
    style: context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
  );

  List<Widget> _buildActions(BuildContext context) => [
    _buildTransferIconButton(context),
    _buildDeleteIconButton(context),
  ];

  Widget _buildTransferIconButton(BuildContext context) => Visibility(
    visible: todoController.selectedTodo.isNotEmpty,
    replacement: const Offstage(),
    child: IconButton(
      icon: const Icon(IconsaxPlusLinear.arrange_square, size: 20),
      onPressed: () => _showTodosTransferBottomSheet(context),
    ),
  );

  void _showTodosTransferBottomSheet(BuildContext context) =>
      showModalBottomSheet(
        enableDrag: false,
        context: context,
        isScrollControlled: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (BuildContext context) => TodosTransfer(
          text: 'editing'.tr,
          todos: todoController.selectedTodo,
        ),
      );

  Widget _buildDeleteIconButton(BuildContext context) => Visibility(
    visible: todoController.selectedTodo.isNotEmpty,
    child: IconButton(
      icon: const Icon(IconsaxPlusLinear.trash_square, size: 20),
      onPressed: () async => await _showDeleteConfirmationDialog(context),
    ),
  );

  Future<void> _showDeleteConfirmationDialog(BuildContext context) async =>
      await showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: Text('deletedTodo'.tr, style: context.textTheme.titleLarge),
          content: Text(
            'deletedTodoQuery'.tr,
            style: context.textTheme.titleMedium,
          ),
          actions: [_buildCancelButton(context), _buildDeleteButton(context)],
        ),
      );

  TextButton _buildCancelButton(BuildContext context) => TextButton(
    onPressed: () => Get.back(),
    child: Text(
      'cancel'.tr,
      style: context.textTheme.titleMedium?.copyWith(color: Colors.blueAccent),
    ),
  );

  TextButton _buildDeleteButton(BuildContext context) => TextButton(
    onPressed: () {
      todoController.deleteTodo(todoController.selectedTodo);
      todoController.doMultiSelectionTodoClear();
      Get.back();
    },
    child: Text(
      'delete'.tr,
      style: context.textTheme.titleMedium?.copyWith(color: Colors.red),
    ),
  );

  Widget _buildBody(BuildContext context) => DefaultTabController(
    length: 2,
    child: NestedScrollView(
      controller: ScrollController(),
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        _buildTableCalendar(),
        _buildTabBar(context),
      ],
      body: _buildTabBarView(),
    ),
  );

  Widget _buildTableCalendar() => SliverToBoxAdapter(
    child: Obx(
      () => TableCalendar(
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, day, events) => Obx(() {
            var countTodos = todoController.countTotalTodosCalendar(day);
            return countTodos != 0
                ? selectedDay.isAtSameMomentAs(day)
                      ? _buildSelectedDayMarker(countTodos)
                      : _buildDayMarker(countTodos)
                : const SizedBox.shrink();
          }),
        ),
        startingDayOfWeek: _getFirstDayOfWeek(),
        weekendDays: const [DateTime.sunday],
        firstDay: fDay,
        lastDay: lDay,
        focusedDay: selectedDay,
        locale: locale.languageCode,
        availableCalendarFormats: {
          CalendarFormat.month: 'week'.tr,
          CalendarFormat.twoWeeks: 'month'.tr,
          CalendarFormat.week: 'two_week'.tr,
        },
        selectedDayPredicate: (day) => isSameDay(selectedDay, day),
        onDaySelected: (selected, focused) =>
            setState(() => selectedDay = selected),
        onPageChanged: (focused) => setState(() => selectedDay = focused),
        calendarFormat: _getCalendarFormat(),
        onFormatChanged: (format) =>
            setState(() => _updateCalendarFormat(format)),
      ),
    ),
  );

  Widget _buildSelectedDayMarker(int countTodos) => Container(
    width: 16,
    height: 16,
    decoration: const BoxDecoration(
      color: Colors.amber,
      shape: BoxShape.circle,
    ),
    child: Center(
      child: Text(
        '$countTodos',
        style: context.textTheme.bodyLarge?.copyWith(
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ),
  );

  Widget _buildDayMarker(int countTodos) => Text(
    '$countTodos',
    style: const TextStyle(
      color: Colors.amber,
      fontWeight: FontWeight.bold,
      fontSize: 12,
    ),
  );

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
    if (format == CalendarFormat.week) {
      settings.calendarFormat = 'week';
    } else if (format == CalendarFormat.twoWeeks) {
      settings.calendarFormat = 'twoWeeks';
    } else if (format == CalendarFormat.month) {
      settings.calendarFormat = 'month';
    }
    isar.settings.putSync(settings);
  });

  Widget _buildTabBar(BuildContext context) => SliverOverlapAbsorber(
    handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
    sliver: SliverPersistentHeader(
      delegate: MyDelegate(
        TabBar(
          tabAlignment: TabAlignment.start,
          controller: tabController,
          isScrollable: true,
          dividerColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          overlayColor: WidgetStateProperty.resolveWith<Color?>(
            (states) => Colors.transparent,
          ),
          tabs: [
            Tab(text: 'doing'.tr),
            Tab(text: 'done'.tr),
          ],
        ),
      ),
      floating: true,
      pinned: true,
    ),
  );

  Widget _buildTabBarView() => TabBarView(
    controller: tabController,
    children: [
      TodosList(
        allTodos: false,
        calendar: true,
        done: false,
        selectedDay: selectedDay,
        searchTodo: '',
      ),
      TodosList(
        allTodos: false,
        calendar: true,
        done: true,
        selectedDay: selectedDay,
        searchTodo: '',
      ),
    ],
  );
}
