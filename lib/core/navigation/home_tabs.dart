/// Bottom-navigation tab keys, indices, and default-screen resolution.
const List<String> tabScreenKeys = [
  'categories',
  'allTodos',
  'calendar',
  'statistics',
];

/// Index of the calendar tab in the home [IndexedStack].
const int calendarTabIndex = 2;

/// Resolves a persisted default-screen key to a home tab index.
int homeTabIndexForDefaultScreen(String defaultScreen) {
  final key = defaultScreen.isNotEmpty && tabScreenKeys.contains(defaultScreen)
      ? defaultScreen
      : tabScreenKeys.first;
  return tabScreenKeys.indexOf(key);
}
