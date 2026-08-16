import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zest/app.dart';
import 'package:zest/core/bootstrap/app_initializer.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/utils/default_category.dart';

/// Entry point: bootstraps dependencies and runs [ZestApp].
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final bootstrap = await AppInitializer.initialize();
  // Auto-backup runs once via [AppLifecycleCoordinator] on first frame.
  runApp(
    ProviderScope(
      overrides: [bootstrapProvider.overrideWithValue(bootstrap)],
      child: ZestApp(bootstrap: bootstrap),
    ),
  );
  Future.microtask(
    () => seedDefaultCategoryOnce(bootstrap.isar, bootstrap.settings),
  );
}
