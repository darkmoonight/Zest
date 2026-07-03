import 'package:isar_community/isar.dart';
import 'package:zest/data/models/db.dart';

/// Holds the opened Isar database and initial settings from bootstrap.
class AppBootstrap {
  const AppBootstrap({required this.isar, required this.settings});

  /// Opened Isar database from startup.
  final Isar isar;

  /// Settings row loaded during bootstrap.
  final Settings settings;

  static AppBootstrap? _instance;

  /// Registers the bootstrap container for services that run outside Riverpod.
  static void register(AppBootstrap bootstrap) {
    _instance = bootstrap;
  }

  /// Returns the registered bootstrap container.
  static AppBootstrap get requireInstance {
    final instance = _instance;
    if (instance == null) {
      throw StateError('AppBootstrap has not been registered');
    }
    return instance;
  }

  /// Returns the registered [Isar] instance, if any.
  static Isar? get maybeIsar => _instance?.isar;
}
