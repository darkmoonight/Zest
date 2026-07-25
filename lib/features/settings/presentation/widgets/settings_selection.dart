import 'package:flutter/material.dart';
import 'package:zest/core/services/backup_constants.dart';
import 'package:zest/data/models/db.dart';
import 'package:zest/features/settings/presentation/widgets/selection_dialog.dart';
import 'package:zest/i18n/tr.dart';

/// Human-readable label for the configured auto-backup path.
String formatAutoBackupPathDisplay(Settings settings) {
  final path = settings.autoBackupPath;

  if (path == null || path.isEmpty) {
    return 'defaultPath'.tr;
  }

  final decodedPath = Uri.decodeComponent(
    path,
  ).replaceAll('%3A', ':').replaceAll('%2F', '/');

  if (isAndroidContentUri(decodedPath)) {
    return 'customPath'.tr;
  }

  final parts = decodedPath.split('/').where((p) => p.isNotEmpty).toList();
  return parts.isNotEmpty ? parts.last : 'customPath'.tr;
}

/// Presents a settings-style single-choice dialog.
Future<void> showSettingsSelection<T>({
  required BuildContext context,
  required String title,
  required IconData icon,
  required List<T> items,
  required T currentValue,
  required String Function(T item) itemBuilder,
  required Future<void> Function(T value) onSelected,
}) {
  return showSelectionDialog<T>(
    context: context,
    title: title.tr,
    icon: icon,
    items: items,
    currentValue: currentValue,
    itemBuilder: itemBuilder,
    onSelected: onSelected,
  );
}
