import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Summary of a dependency package and its license paragraph count.
class PackageLicenseInfo {
  /// Creates a [PackageLicenseInfo].
  const PackageLicenseInfo({
    required this.packageName,
    required this.paragraphCount,
  });

  /// Dependency name as reported by [LicenseRegistry].
  final String packageName;

  /// Number of license paragraphs aggregated for this package.
  final int paragraphCount;
}

final Map<String, String> _packageLicenseTextCache = {};

/// Clears cached full license text loaded by [loadPackageLicenseText].
void clearPackageLicenseCaches() => _packageLicenseTextCache.clear();

/// Clears license caches; intended for tests only.
@visibleForTesting
void clearPackageLicenseCachesForTest() => clearPackageLicenseCaches();

/// Joins [LicenseParagraph] texts with blank lines between entries.
String licenseParagraphsText(Iterable<LicenseParagraph> paragraphs) =>
    paragraphs.map((paragraph) => paragraph.text).join('\n\n');

Future<void> _yieldToUi(int processed, {required int every}) async {
  if (processed % every == 0) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// Loads package names and paragraph counts from [LicenseRegistry].
Future<List<PackageLicenseInfo>> loadPackageLicenses() async {
  await Future<void>.delayed(Duration.zero);

  final paragraphCounts = <String, int>{};

  var processed = 0;

  await for (final entry in LicenseRegistry.licenses) {
    for (final package in entry.packages) {
      paragraphCounts[package] =
          (paragraphCounts[package] ?? 0) + entry.paragraphs.length;
    }
    processed++;
    await _yieldToUi(processed, every: 50);
  }

  return paragraphCounts.entries
      .map(
        (entry) => PackageLicenseInfo(
          packageName: entry.key,
          paragraphCount: entry.value,
        ),
      )
      .toList()
    ..sort(
      (a, b) =>
          a.packageName.toLowerCase().compareTo(b.packageName.toLowerCase()),
    );
}

/// Loads and caches the full license text for [packageName].
Future<String> loadPackageLicenseText(String packageName) async {
  final cached = _packageLicenseTextCache[packageName];
  if (cached != null) return cached;

  await Future<void>.delayed(Duration.zero);

  final buffer = StringBuffer();

  var processed = 0;

  await for (final entry in LicenseRegistry.licenses) {
    if (!entry.packages.contains(packageName)) continue;

    if (buffer.isNotEmpty) {
      buffer.write('\n\n');
    }
    buffer.write(licenseParagraphsText(entry.paragraphs));

    processed++;
    await _yieldToUi(processed, every: 25);
  }

  final text = buffer.toString();
  _packageLicenseTextCache[packageName] = text;
  return text;
}

/// Async provider that loads sorted [PackageLicenseInfo] for the licenses screen.
final packageLicensesProvider =
    FutureProvider.autoDispose<List<PackageLicenseInfo>>((ref) async {
      ref.onDispose(clearPackageLicenseCaches);
      await Future<void>.delayed(Duration.zero);
      return loadPackageLicenses();
    });
