import 'package:flutter/scheduler.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/app/controller/fab_controller.dart';
import 'package:zest/app/utils/responsive_utils.dart' show ResponsiveUtils;
import 'package:zest/app/ui/tasks/view/all_tasks.dart';
import 'package:zest/app/ui/settings/view/settings.dart';
import 'package:flutter/material.dart';
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
  final fabController = Get.put(FabController(), permanent: true);

  int tabIndex = 0;
  late PageController pageController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

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
    pageController = PageController(initialPage: tabIndex);
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    ever(fabController.isVisible, (isVisible) {
      if (mounted) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          if (isVisible) {
            _fabAnimationController.forward();
          } else {
            _fabAnimationController.reverse();
          }
        });
      }
    });

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    pageController.dispose();
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
    if (tabIndex != index) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
      setState(() {
        tabIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = !ResponsiveUtils.isMobile(context);
    final isExtraLarge = ResponsiveUtils.isDesktop(context);

    final content = PageView(
      controller: pageController,
      physics: isLargeScreen ? const NeverScrollableScrollPhysics() : null,
      onPageChanged: (index) {
        setState(() {
          tabIndex = index;
        });
      },
      children: pages,
    );

    final body = isLargeScreen
        ? Row(
      children: [
        _buildNavigationRail(context, isExtraLarge),
        const VerticalDivider(thickness: 1, width: 1),
        Expanded(child: content),
      ],
    )
        : content;

    return Scaffold(
      body: body,
      bottomNavigationBar: isLargeScreen ? null : _buildBottomNavigationBar(),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildNavigationRail(BuildContext context, bool isExtended) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return NavigationRail(
      selectedIndex: tabIndex,
      extended: isExtended,
      groupAlignment: -1.0,
      onDestinationSelected: changeTabIndex,
      labelType: isExtended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: Padding(
        padding: EdgeInsets.symmetric(vertical: padding * 1.5),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            IconsaxPlusBold.user,
            size: 24,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      destinations: [
        _buildRailDestination(
          IconsaxPlusLinear.folder_2,
          IconsaxPlusBold.folder_2,
          allScreens[0].tr,
        ),
        _buildRailDestination(
          IconsaxPlusLinear.task_square,
          IconsaxPlusBold.task_square,
          allScreens[1].tr,
        ),
        _buildRailDestination(
          IconsaxPlusLinear.calendar,
          IconsaxPlusBold.calendar,
          allScreens[2].tr,
        ),
        _buildRailDestination(
          IconsaxPlusLinear.setting_2,
          IconsaxPlusBold.setting_2,
          'settings'.tr,
        ),
      ],
    );
  }

  NavigationRailDestination _buildRailDestination(
      IconData icon,
      IconData selectedIcon,
      String label,
      ) =>
      NavigationRailDestination(
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: Text(label),
      );

  Widget _buildBottomNavigationBar() => NavigationBar(
    onDestinationSelected: changeTabIndex,
    selectedIndex: tabIndex,
    destinations: _buildNavigationDestinations(),
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
      icon: IconsaxPlusLinear.setting_2,
      selectedIcon: IconsaxPlusBold.setting_2,
      label: 'settings'.tr,
    ),
  ];

  NavigationDestination _buildNavigationDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) =>
      NavigationDestination(
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: label,
      );

  Widget? _buildFloatingActionButton() {
    if (tabIndex == 3) return null;

    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton(
        onPressed: _showBottomSheet,
        child: const Icon(IconsaxPlusLinear.add),
      ),
    );
  }

  void _showBottomSheet() {
    final isLargeScreen = !ResponsiveUtils.isMobile(context);
    final colorScheme = Theme.of(context).colorScheme;

    final widget = tabIndex == 0
        ? TasksAction(text: 'create'.tr, edit: false)
        : TodosAction(text: 'create'.tr, edit: false, category: true);

    if (isLargeScreen) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(
                minWidth: 400,
                maxWidth: 600,
              ),
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
                child: widget,
              ),
            ),
          );
        },
      );
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) => widget,
      );
    }
  }
}
