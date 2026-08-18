import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/config/todo_card_layout_config.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/features/settings/presentation/widgets/settings_list_dialog_shell.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';

/// Todo card metadata visibility and order.
class SettingsTodoCardSection extends ConsumerStatefulWidget {
  /// Creates a [SettingsTodoCardSection].
  const SettingsTodoCardSection({super.key});

  @override
  ConsumerState<SettingsTodoCardSection> createState() =>
      _SettingsTodoCardSectionState();
}

class _SettingsTodoCardSectionState
    extends SettingsSectionConsumerState<SettingsTodoCardSection> {
  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: 'todoCardLayout',
      icon: IconsaxPlusBold.note_2,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.setting_4),
          title: 'todoCardLayout',
          subtitleText: 'todoCardLayoutHint'.tr,
          onTap: _openLayoutDialog,
        ),
      ],
    );
  }

  Future<void> _openLayoutDialog() async {
    final current = TodoCardLayoutConfig.decode(
      ref.read(liveSettingsProvider).todoCardLayout,
    );
    if (!mounted) return;
    await NavigationHelper.showAppDialog<void>(
      context: context,
      child: _TodoCardLayoutDialog(
        initialEntries: List.of(current),
        onSave: (entries) {
          actions.saveSettingsOptimistic(
            mutate: (s) =>
                s.todoCardLayout = TodoCardLayoutConfig.encode(entries),
          );
        },
      ),
    );
  }
}

class _TodoCardLayoutDialog extends StatefulWidget {
  const _TodoCardLayoutDialog({
    required this.initialEntries,
    required this.onSave,
  });

  final List<TodoCardLayoutEntry> initialEntries;
  final ValueChanged<List<TodoCardLayoutEntry>> onSave;

  @override
  State<_TodoCardLayoutDialog> createState() => _TodoCardLayoutDialogState();
}

class _TodoCardLayoutDialogState extends State<_TodoCardLayoutDialog> {
  static const EdgeInsets _listHorizontalPadding = EdgeInsets.symmetric(
    horizontal: AppConstants.spacingM,
  );

  static const double _maxListHeightFactor = 0.42;

  late List<TodoCardLayoutEntry> _entries;

  @override
  void initState() {
    super.initState();
    _entries = List.of(widget.initialEntries);
  }

  void _persist() => widget.onSave(_entries);

  void _reset() {
    setState(() {
      _entries = List.of(TodoCardLayoutConfig.defaultLayout);
    });
    _persist();
  }

  void _toggle(int index, bool visible) {
    setState(() {
      _entries[index] = _entries[index].copyWith(visible: visible);
    });
    _persist();
  }

  @override
  Widget build(BuildContext context) {
    final maxListHeight =
        MediaQuery.of(context).size.height * _maxListHeightFactor;

    return SettingsListDialogShell(
      shrinkWrapBody: true,
      header: SettingsListDialogHeader(
        title: 'todoCardLayout'.tr,
        icon: IconsaxPlusBold.note_2,
      ),
      body: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxListHeight),
        child: ReorderableListView.builder(
          shrinkWrap: true,
          padding: _listHorizontalPadding,
          itemCount: _entries.length,
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              final item = _entries.removeAt(oldIndex);
              _entries.insert(newIndex, item);
            });
            _persist();
          },
          itemBuilder: (context, index) {
            final entry = _entries[index];
            return ListTile(
              key: ValueKey(entry.id),
              contentPadding: _listHorizontalPadding,
              leading: ReorderableDragStartListener(
                index: index,
                child: Icon(
                  IconsaxPlusLinear.menu,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              title: Text(_labelFor(entry.id)),
              trailing: Switch(
                value: entry.visible,
                onChanged: (value) => _toggle(index, value),
              ),
            );
          },
        ),
      ),
      footer: SettingsListDialogActionsFooter(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SettingsListDialogTonalButton(
              labelKey: 'todoCardLayoutReset',
              onPressed: _reset,
            ),
            const SizedBox(width: AppConstants.spacingS),
            SettingsListDialogTonalButton(
              labelKey: 'close',
              onPressed: () => NavigationHelper.back(context),
            ),
          ],
        ),
      ),
    );
  }

  String _labelFor(TodoCardFieldId id) {
    return _fieldLabelKeys[id]!.tr;
  }

  static const Map<TodoCardFieldId, String> _fieldLabelKeys = {
    TodoCardFieldId.description: 'todoCardFieldDescription',
    TodoCardFieldId.category: 'todoCardFieldCategory',
    TodoCardFieldId.created: 'todoCardFieldCreated',
    TodoCardFieldId.deadline: 'todoCardFieldDeadline',
    TodoCardFieldId.priority: 'todoCardFieldPriority',
    TodoCardFieldId.tags: 'todoCardFieldTags',
    TodoCardFieldId.completed: 'todoCardFieldCompleted',
  };
}
