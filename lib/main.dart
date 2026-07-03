import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/app.dart';
import 'package:zest/core/bootstrap/app_initializer.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/services/auto_backup_service.dart';

/// Entry point: bootstraps dependencies and runs [ZestApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppInitializer.initialize();
  Future.microtask(
    () => AutoBackupService.checkAndPerformAutoBackup(bootstrap.isar),
  );
  runApp(
    ProviderScope(
      overrides: [bootstrapProvider.overrideWithValue(bootstrap)],
      child: ZestApp(bootstrap: bootstrap),
    ),
  );
}
