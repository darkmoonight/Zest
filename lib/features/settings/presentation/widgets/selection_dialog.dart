import 'dart:async';

import 'package:flutter/material.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/features/settings/presentation/widgets/settings_list_dialog_shell.dart';
import 'package:zest/i18n/tr.dart';

Future<T?> showSelectionDialog<T>({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<T> items,
  required T currentValue,
  required String Function(T) itemBuilder,
  required FutureOr<void> Function(T) onSelected,

  /// Enable search.
  bool enableSearch = false,

  /// Function.
  Widget? Function(T)? leadingBuilder,
}) async {
  return NavigationHelper.showAppDialog<T>(
    context: context,
    child: SelectionDialog<T>(
      title: title,
      icon: icon,
      items: items,
      currentValue: currentValue,
      itemBuilder: itemBuilder,
      onSelected: onSelected,
      enableSearch: enableSearch,
      leadingBuilder: leadingBuilder,
    ),
  );
}

/// Widget that selection dialog.
class SelectionDialog<T> extends StatefulWidget {
  /// Creates a [SelectionDialog].
  const SelectionDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
    required this.currentValue,
    required this.itemBuilder,
    required this.onSelected,
    required this.enableSearch,
    this.leadingBuilder,
  });

  /// The title.
  final String title;

  /// The icon.
  final IconData icon;

  /// The items.
  final List<T> items;

  /// The current value.
  final T currentValue;

  /// The item builder.
  final String Function(T) itemBuilder;

  /// The on selected.
  final FutureOr<void> Function(T) onSelected;

  /// The enable search.
  final bool enableSearch;

  /// The leading builder.
  final Widget? Function(T)? leadingBuilder;

  @override
  /// T.
  State<SelectionDialog<T>> createState() => _SelectionDialogState<T>();
}

/// Widget that selection dialog state.
class _SelectionDialogState<T> extends State<SelectionDialog<T>> {
  /// The filtered items.
  late List<T> _filteredItems;

  /// Search controller.
  final _searchController = TextEditingController();

  @override
  /// Initializes state when the widget is first inserted.
  void initState() {
    super.initState();
    _filteredItems = widget.items;
  }

  @override
  /// Releases resources when the widget is removed.
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Filter items.
  void _filterItems(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items.where((item) {
          final itemText = widget.itemBuilder(item).toLowerCase();
          return itemText.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final maxListHeight = MediaQuery.of(context).size.height * 0.45;

    return SettingsListDialogShell(
      header: SettingsListDialogHeader(title: widget.title, icon: widget.icon),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.enableSearch) _buildSearchField(context, colorScheme),
          if (_filteredItems.isEmpty)
            _buildEmptyState(context, colorScheme)
          else
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxListHeight),
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.only(bottom: AppConstants.spacingS),
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return SettingsDialogListTile(
                    title: widget.itemBuilder(item),
                    isSelected: item == widget.currentValue,
                    leading: widget.leadingBuilder?.call(item),
                    onTap: () async {
                      await widget.onSelected(item);
                      if (!context.mounted) return;
                      NavigationHelper.back(context, result: item);
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  /// Builds the search field widget.
  Widget _buildSearchField(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spacingXXL,
        0,
        AppConstants.spacingXXL,
        AppConstants.spacingL,
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _filterItems,
        decoration: InputDecoration(
          hintText: 'search'.tr,
          hintStyle: TextStyle(
            color: colorScheme.onSurfaceVariant,
            fontSize: ResponsiveUtils.getResponsiveFontSize(context, 13),
          ),
          prefixIcon: Icon(
            IconsaxPlusLinear.search_normal_1,
            color: colorScheme.onSurfaceVariant,
            size: 18,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    IconsaxPlusLinear.close_circle,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _filterItems('');
                  },
                )
              : null,
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              AppConstants.borderRadiusMedium,
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// Builds the empty state widget.
  Widget _buildEmptyState(BuildContext context, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spacingXXL),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            IconsaxPlusLinear.search_status,
            size: 64,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(height: AppConstants.spacingL),
          Text(
            'noResults'.tr,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
