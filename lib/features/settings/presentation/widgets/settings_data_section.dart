import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/config/setting_enum_pickers.dart';
import 'package:zest/core/di/list_reload.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/isar_service.dart';
import 'package:zest/core/utils/show_snack_bar.dart';
import 'package:zest/core/widgets/confirmation_dialog.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/settings/presentation/widgets/settings_selection.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section_state.dart';
import 'package:zest/features/settings/presentation/widgets/settings_switch_tile.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';

/// Backup, restore, auto-backup, and data clearing settings.
class SettingsDataSection extends ConsumerStatefulWidget {
  /// Creates a [SettingsDataSection].
  const SettingsDataSection({super.key});

  @override
  /// Creates the state for this widget.
  ConsumerState<SettingsDataSection> createState() =>
      _SettingsDataSectionState();
}

/// State for [SettingsDataSection] backup tiles.
class _SettingsDataSectionState
    extends SettingsSectionConsumerState<SettingsDataSection> {
  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final backupSettings = ref.watch(
      settingsProvider.select(
        (s) => (
          s.autoBackupEnabled,
          s.autoBackupPath,
          s.autoBackupFrequency,
          s.maxAutoBackups,
        ),
      ),
    );
    final eraseSettings = ref.watch(
      settingsProvider.select(
        (s) => (s.autoEraseCompletedEnabled, s.autoEraseCompletedFrequency),
      ),
    );
    final settings = ref.read(settingsProvider);
    final isar = ref.read(isarProvider);
    final isarService = IsarService(isar, context);

    return SettingsSection(
      title: 'dataManagement',
      icon: IconsaxPlusBold.cloud,
      children: [
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.cloud_plus),
          title: 'backup',
          onTap: isarService.createBackup,
        ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.cloud_add),
          title: 'restore',
          onTap: isarService.restoreDB,
        ),
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.refresh_circle),
          title: 'autoBackup',
          value: backupSettings.$1,
          onChanged: (value) {
            actions.saveSettingsOptimistic(
              mutate: (s) => s.autoBackupEnabled = value,
              afterSave: value ? _createAutoBackupNow : null,
            );
          },
        ),
        if (backupSettings.$1) ...[
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.folder),
            title: 'autoBackupPath',
            value: formatAutoBackupPathDisplay(settings),
            onTap: () => _selectAutoBackupPath(),
          ),
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.calendar_tick),
            title: 'autoBackupFrequency',
            value: _getFrequencyText(backupSettings.$3),
            onTap: () => _showAutoBackupFrequencyDialog(settings),
          ),
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.d_square),
            title: 'maxAutoBackups',
            value: '${backupSettings.$4}',
            onTap: () => _showMaxBackupsDialog(settings),
          ),
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.d_rotate),
            title: 'createAutoBackupNow',
            onTap: _createAutoBackupNow,
          ),
        ],
        SettingsSwitchTile(
          leading: const Icon(IconsaxPlusLinear.trash),
          title: 'autoEraseCompleted',
          value: eraseSettings.$1,
          onChanged: (value) {
            actions.saveSettingsOptimistic(
              mutate: (s) => s.autoEraseCompletedEnabled = value,
            );
          },
        ),
        if (eraseSettings.$1)
          SettingsTile(
            leading: const Icon(IconsaxPlusLinear.calendar_1),
            title: 'autoEraseCompletedFrequency',
            value: _getEraseFrequencyText(eraseSettings.$2),
            onTap: () => _showAutoEraseFrequencyDialog(settings),
          ),
        SettingsTile(
          leading: const Icon(IconsaxPlusLinear.cloud_minus),
          title: 'deleteAllBD',
          onTap: () => _showDeleteAllDBDialog(),
        ),
      ],
    );
  }

  /// Show auto backup frequency dialog.
  void _showAutoBackupFrequencyDialog(Settings settings) {
    showSettingsSelection<AutoBackupFrequency>(
      context: context,
      title: 'autoBackupFrequency',
      icon: IconsaxPlusBold.calendar_tick,
      items: AutoBackupFrequency.values,
      currentValue: settings.autoBackupFrequency,
      itemBuilder: (frequency) => _getFrequencyText(frequency),
      onSelected: (value) async {
        actions.saveSettingsOptimistic(
          mutate: (s) => s.autoBackupFrequency = value,
        );
      },
    );
  }

  /// Show auto-erase frequency dialog.
  void _showAutoEraseFrequencyDialog(Settings settings) {
    showSettingsSelection<AutoEraseCompletedFrequency>(
      context: context,
      title: 'autoEraseCompletedFrequency',
      icon: IconsaxPlusBold.calendar_1,
      items: AutoEraseCompletedFrequency.values,
      currentValue: settings.autoEraseCompletedFrequency,
      itemBuilder: _getEraseFrequencyText,
      onSelected: (value) async {
        actions.saveSettingsOptimistic(
          mutate: (s) => s.autoEraseCompletedFrequency = value,
        );
      },
    );
  }

  /// Show max backups dialog.
  void _showMaxBackupsDialog(Settings settings) {
    final picker = settingMaxAutoBackupsPicker;
    showSettingsSelection<int>(
      context: context,
      title: picker.titleKey,
      icon: picker.icon,
      items: picker.items,
      currentValue: picker.read(settings),
      itemBuilder: (count) => '$count',
      onSelected: (value) async {
        actions.saveSettingsOptimistic(mutate: (s) => picker.write(s, value));
      },
    );
  }

  /// Opens the directory picker and saves the chosen auto-backup path.
  Future<void> _selectAutoBackupPath() async {
    try {
      final path = await IsarService(
        ref.read(isarProvider),
        context,
      ).pickAutoBackupDirectory();
      if (path == null) return;

      actions.saveSettingsOptimistic(
        mutate: (s) => s.autoBackupPath = path,
        afterSave: () async {
          if (!mounted) return;
          showSnackBar('autoBackupPathSet'.tr);
          await _createAutoBackupNow();
        },
      );
    } catch (e) {
      debugPrint('Error selecting auto backup path: $e');
      if (!mounted) return;
      showSnackBar('error'.tr, isError: true);
    }
  }

  /// Creates an on-demand auto-backup and shows a snackbar result.
  Future<void> _createAutoBackupNow() async {
    try {
      showSnackBar('creatingAutoBackup'.tr, isInfo: true);

      final success = await actions.createAutoBackupNow();

      if (!mounted) return;
      if (success) {
        showSnackBar('autoBackupCreated'.tr);
      } else {
        showSnackBar('error'.tr, isError: true);
      }
    } catch (e) {
      debugPrint('Error creating auto backup: $e');
      if (!mounted) return;
      showSnackBar('error'.tr, isError: true);
    }
  }

  /// Localized label for [frequency].
  String _getFrequencyText(AutoBackupFrequency frequency) => frequency.name.tr;

  /// Localized label for completed-item erase [frequency].
  String _getEraseFrequencyText(AutoEraseCompletedFrequency frequency) =>
      frequency.name.tr;

  /// Confirms and clears all tasks and items from the database.
  void _showDeleteAllDBDialog() {
    showConfirmationDialog(
      context: context,
      title: 'deleteAllBDTitle',
      message: 'deleteAllBDQuery',
      icon: IconsaxPlusBold.trash,
      isDestructive: true,
      confirmText: 'delete',
      onConfirm: () async {
        final isar = ref.read(isarProvider);
        await isar.writeTxn(() async {
          await isar.todos.clear();
          await isar.tasks.clear();
        });
        await reloadTodosAndTasks(ref);
        showSnackBar('deleteAll'.tr);
      },
    );
  }
}
