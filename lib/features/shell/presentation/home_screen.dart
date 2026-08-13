import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/navigation/home_tabs.dart';
import 'package:zest/core/di/providers.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/features/settings/presentation/view/settings.dart';
import 'package:zest/features/statistics/presentation/view/statistics.dart';
import 'package:zest/features/tasks/presentation/view/all_tasks.dart';
import 'package:zest/features/tasks/presentation/widgets/tasks_action.dart';
import 'package:zest/features/todos/presentation/view/all_todos.dart';
import 'package:zest/features/todos/presentation/view/calendar_todos.dart';
import 'package:zest/features/todos/presentation/widgets/todos_action.dart';
import 'package:zest/i18n/tr.dart';

/// Widget that home screen.
class HomeScreen extends ConsumerStatefulWidget {
  /// Creates a [HomeScreen].
  const HomeScreen({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<HomeScreen> createState() => HomeScreenState();
}

/// Widget that home screen state.
class HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  /// The fab animation controller.
  late final AnimationController _fabAnimationController;

  /// The fab scale animation.
  late final Animation<double> _fabScaleAnimation;

  /// Tab index.
  int _tabIndex = 0;

  static const List<Widget> _pages = [
    AllTasks(),
    AllTodos(),
    CalendarTodos(),
    StatisticsPage(),
    SettingsPage(),
  ];

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _initializeTabIndex();
    _setupFabAnimation();
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  /// Setup fab animation.
  void _setupFabAnimation() {
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: AppConstants.shortAnimation,
    );

    _fabScaleAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    );

    _fabAnimationController.forward();
  }

  /// Initialize tab index.
  void _initializeTabIndex() {
    final settings = ref.read(settingsProvider);
    _tabIndex = homeTabIndexForDefaultScreen(settings.defaultScreen);
  }

  /// Change tab index.
  void changeTabIndex(int index) {
    if (_tabIndex != index) {
      setState(() => _tabIndex = index);
      ref.read(homeTabIndexProvider.notifier).setIndex(index);
    }
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final fabVisible = ref.watch(fabNotifierProvider).isVisible;

    ref.listen(fabNotifierProvider.select((s) => s.isVisible), (prev, next) {
      if (!mounted) return;
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (next) {
          _fabAnimationController.forward();
        } else {
          _fabAnimationController.reverse();
        }
      });
    });

    final isMobile = ResponsiveUtils.isMobile(context);
    final isDesktop = ResponsiveUtils.isDesktop(context);

    final content = IndexedStack(index: _tabIndex, children: _pages);

    final body = isMobile
        ? content
        : Row(
            children: [
              _buildNavigationRail(context, isDesktop),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(child: content),
            ],
          );

    return Scaffold(
      body: body,
      bottomNavigationBar: isMobile ? _buildBottomNavigationBar() : null,
      floatingActionButton: _buildFloatingActionButton(fabVisible),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Builds the navigation rail widget.
  Widget _buildNavigationRail(BuildContext context, bool isExtended) {
    final colorScheme = Theme.of(context).colorScheme;
    final padding = ResponsiveUtils.getResponsivePadding(context);

    return NavigationRail(
      selectedIndex: _tabIndex,
      extended: isExtended,
      groupAlignment: -1.0,
      onDestinationSelected: changeTabIndex,
      labelType: isExtended
          ? NavigationRailLabelType.none
          : NavigationRailLabelType.all,
      leading: Padding(
        padding: EdgeInsets.symmetric(vertical: padding * 1.5),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.spacingM),
          decoration: BoxDecoration(
            color: colorScheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            IconsaxPlusBold.user,
            size: AppConstants.iconSizeLarge,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ),
      destinations: [
        _buildRailDestination(
          IconsaxPlusLinear.folder_2,
          IconsaxPlusBold.folder_2,
          tabScreenKeys[0].tr,
        ),
        _buildRailDestination(
          IconsaxPlusLinear.task_square,
          IconsaxPlusBold.task_square,
          tabScreenKeys[1].tr,
        ),
        _buildRailDestination(
          IconsaxPlusLinear.calendar,
          IconsaxPlusBold.calendar,
          tabScreenKeys[2].tr,
        ),
        _buildRailDestination(
          IconsaxPlusLinear.chart_21,
          IconsaxPlusBold.chart_2,
          tabScreenKeys[3].tr,
        ),
        _buildRailDestination(
          IconsaxPlusLinear.setting_2,
          IconsaxPlusBold.setting_2,
          'settings'.tr,
        ),
      ],
    );
  }

  /// Builds the rail destination widget.
  NavigationRailDestination _buildRailDestination(
    IconData icon,
    IconData selectedIcon,
    String label,
  ) {
    return NavigationRailDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: Text(label),
    );
  }

  /// Builds the bottom navigation bar widget.
  Widget _buildBottomNavigationBar() {
    return NavigationBar(
      onDestinationSelected: changeTabIndex,
      selectedIndex: _tabIndex,
      destinations: _buildNavigationDestinations(),
    );
  }

  /// Navigation destination.
  List<NavigationDestination> _buildNavigationDestinations() {
    return [
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.folder_2,
        selectedIcon: IconsaxPlusBold.folder_2,
        label: tabScreenKeys[0].tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.task_square,
        selectedIcon: IconsaxPlusBold.task_square,
        label: tabScreenKeys[1].tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.calendar,
        selectedIcon: IconsaxPlusBold.calendar,
        label: tabScreenKeys[2].tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.chart_21,
        selectedIcon: IconsaxPlusBold.chart_2,
        label: tabScreenKeys[3].tr,
      ),
      _buildNavigationDestination(
        icon: IconsaxPlusLinear.setting_2,
        selectedIcon: IconsaxPlusBold.setting_2,
        label: 'settings'.tr,
      ),
    ];
  }

  /// Builds the navigation destination widget.
  NavigationDestination _buildNavigationDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
  }) {
    return NavigationDestination(
      icon: Icon(icon),
      selectedIcon: Icon(selectedIcon),
      label: label,
    );
  }

  /// Builds the floating action button widget.
  Widget? _buildFloatingActionButton(bool fabVisible) {
    const settingsTabIndex = 4;

    if (_tabIndex == statisticsTabIndex ||
        _tabIndex == settingsTabIndex ||
        !fabVisible) {
      return null;
    }

    return ScaleTransition(
      scale: _fabScaleAnimation,
      child: FloatingActionButton(
        onPressed: _showCreateSheet,
        child: const Icon(IconsaxPlusLinear.add),
      ),
    );
  }

  /// Show create sheet or dialog depending on form factor.
  void _showCreateSheet() {
    NavigationHelper.showFormModal(
      context: context,
      child: _tabIndex == 0
          ? TasksAction(text: 'create'.tr, edit: false)
          : TodosAction(text: 'create'.tr, edit: false, category: true),
    );
  }
}
