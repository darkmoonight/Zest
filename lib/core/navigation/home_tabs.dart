/// Bottom-navigation tab keys, indices, and default-screen resolution.
const List<String> tabScreenKeys = [
  'categories',
  'allTodos',
  'calendar',
  'statistics',
];

/// Index of the categories tab in the home [IndexedStack].
const int categoriesTabIndex = 0;

/// Index of the all-todos tab in the home [IndexedStack].
const int allTodosTabIndex = 1;

/// Index of the calendar tab in the home [IndexedStack].
const int calendarTabIndex = 2;

/// Index of the statistics tab in the home [IndexedStack].
const int statisticsTabIndex = 3;

/// Resolves a tab key to its index in [tabScreenKeys].
int tabIndexForKey(String key) => tabScreenKeys.indexOf(key);

/// Resolves a persisted default-screen key to a home tab index.
int homeTabIndexForDefaultScreen(String defaultScreen) {
  final key = defaultScreen.isNotEmpty && tabScreenKeys.contains(defaultScreen)
      ? defaultScreen
      : tabScreenKeys.first;
  return tabIndexForKey(key);
}
