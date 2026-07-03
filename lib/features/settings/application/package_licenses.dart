import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Class representing package license info.
class PackageLicenseInfo {
  /// Creates a [PackageLicenseInfo].
  const PackageLicenseInfo({
    required this.packageName,
    required this.paragraphCount,
  });

  /// The package name.
  final String packageName;

  /// The paragraph count.
  final int paragraphCount;
}

final Map<String, String> _packageLicenseTextCache = {};

/// Clear package license caches.
void clearPackageLicenseCaches() => _packageLicenseTextCache.clear();

@visibleForTesting
/// Clear package license caches for test.
void clearPackageLicenseCachesForTest() => clearPackageLicenseCaches();

/// License paragraphs text.
String licenseParagraphsText(Iterable<LicenseParagraph> paragraphs) =>
    paragraphs.map((paragraph) => paragraph.text).join('\n\n');

/// Void.
Future<void> _yieldToUi(int processed, {required int every}) async {
  if (processed % every == 0) {
    await Future<void>.delayed(Duration.zero);
  }
}

/// Package license info.
Future<List<PackageLicenseInfo>> loadPackageLicenses() async {
  await Future<void>.delayed(Duration.zero);

  /// Paragraph counts.
  final paragraphCounts = <String, int>{};

  /// Processed.
  var processed = 0;

  /// For.
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

/// String.
Future<String> loadPackageLicenseText(String packageName) async {
  /// Cached.
  final cached = _packageLicenseTextCache[packageName];
  if (cached != null) return cached;

  await Future<void>.delayed(Duration.zero);

  /// Buffer.
  final buffer = StringBuffer();

  /// Processed.
  var processed = 0;

  /// For.
  await for (final entry in LicenseRegistry.licenses) {
    if (!entry.packages.contains(packageName)) continue;

    if (buffer.isNotEmpty) {
      buffer.write('\n\n');
    }
    buffer.write(licenseParagraphsText(entry.paragraphs));

    processed++;
    await _yieldToUi(processed, every: 25);
  }

  /// Text.
  final text = buffer.toString();
  _packageLicenseTextCache[packageName] = text;
  return text;
}

/// Package licenses provider.
final packageLicensesProvider =
    FutureProvider.autoDispose<List<PackageLicenseInfo>>((ref) async {
      ref.onDispose(clearPackageLicenseCaches);
      await Future<void>.delayed(Duration.zero);
      return loadPackageLicenses();
    });
