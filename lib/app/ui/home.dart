import 'package:flutter/scheduler.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:zest/app/ui/tasks/view/all_tasks.dart';
import 'package:zest/app/ui/settings/view/settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:get/get.dart';
import 'package:zest/app/ui/tasks/widgets/tasks_action.dart';
import 'package:zest/app/ui/todos/view/calendar_todos.dart';
import 'package:zest/app/ui/todos/view/all_todos.dart';
import 'package:zest/app/ui/todos/widgets/todos_action.dart';
import 'package:zest/theme/theme_controller.dart';
import 'package:zest/main.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final themeController = Get.put(ThemeController());
  int tabIndex = 0;

  final ScrollController _scrollController = ScrollController();
  final fabController = Get.put(FabController(), permanent: true);

  final List<Widget> pages = const [
    AllTasks(),
    AllTodos(),
    CalendarTodos(),
    SettingsPage(),
  ];

  @override
  void initState() {
    super.initState();
    _initializeTabIndex();
    ever(fabController.isVisible, (_) {
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    fabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<String> _getScreens() => ['categories', 'allTodos', 'calendar'];

  void _initializeTabIndex() {
    allScreens = _getScreens();
    tabIndex = allScreens.indexOf(
      allScreens.firstWhere(
        (element) => element == settings.defaultScreen,
        orElse: () => allScreens[0],
      ),
    );
  }

  void changeTabIndex(int index) {
    setState(() {
      tabIndex = index;
      if (index != 3) {
        fabController.show();
      }
    });
  }

  void onSwipe(DragEndDetails details) {
    if (details.primaryVelocity! < 0) {
      if (tabIndex < pages.length - 1) {
        changeTabIndex(tabIndex + 1);
      }
    } else if (details.primaryVelocity! > 0) {
      if (tabIndex > 0) {
        changeTabIndex(tabIndex - 1);
      }
    }
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (tabIndex == 3) return false;
    if (notification.depth > 0) return false;

    if (notification is UserScrollNotification) {
      final ScrollDirection direction = notification.direction;
      if (direction == ScrollDirection.reverse) {
        fabController.hide();
      } else if (direction == ScrollDirection.forward) {
        fabController.show();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: NotificationListener<ScrollNotification>(
      onNotification: _handleScrollNotification,
      child: IndexedStack(index: tabIndex, children: pages),
    ),
    bottomNavigationBar: _buildBottomNavigationBar(),
    floatingActionButton: _buildFloatingActionButton(),
  );

  Widget _buildBottomNavigationBar() => GestureDetector(
    onHorizontalDragEnd: onSwipe,
    child: NavigationBar(
      onDestinationSelected: changeTabIndex,
      selectedIndex: tabIndex,
      destinations: _buildNavigationDestinations(),
    ),
  );

  List<NavigationDestination> _buildNavigationDestinations() => [
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.folder_2,
      selectedIcon: IconsaxPlusBold.folder_2,
      label: allScreens[0].tr,
    ),
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.task_square,
      selectedIcon: IconsaxPlusBold.task_square,
      label: allScreens[1].tr,
    ),
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.calendar,
      selectedIcon: IconsaxPlusBold.calendar,
      label: allScreens[2].tr,
    ),
    _buildNavigationDestination(
      icon: IconsaxPlusLinear.category,
      selectedIcon: IconsaxPlusBold.category,
      label: 'settings'.tr,
    ),
  ];

  NavigationDestination _buildNavigationDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) => NavigationDestination(
    icon: Icon(icon),
    selectedIcon: Icon(selectedIcon),
    label: label,
  );

  Widget? _buildFloatingActionButton() {
    if (tabIndex == 3 || !fabController.isVisible.value) return null;
    return FloatingActionButton(
      onPressed: _showBottomSheet,
      child: const Icon(IconsaxPlusLinear.add),
    );
  }

  void _showBottomSheet() => showModalBottomSheet(
    enableDrag: false,
    context: context,
    isScrollControlled: true,
    builder: (BuildContext context) => tabIndex == 0
        ? TasksAction(text: 'create'.tr, edit: false)
        : TodosAction(text: 'create'.tr, edit: false, category: true),
  );
}
