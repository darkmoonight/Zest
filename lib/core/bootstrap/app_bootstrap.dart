import 'package:isar_community/isar.dart';
import 'package:zest/data/models/db.dart';

/// Holds the opened Isar database and initial settings from bootstrap.
class AppBootstrap {
  /// Creates a bootstrap container with the opened [isar] and [settings].
  const AppBootstrap({required this.isar, required this.settings});

  /// Opened Isar database from startup.
  final Isar isar;

  /// Settings row loaded during bootstrap.
  final Settings settings;
}
