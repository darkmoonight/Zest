import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:iconsax_plus/iconsax_plus.dart';
import 'package:zest/core/constants/app_constants.dart';
import 'package:zest/core/di/provider_refs.dart';
import 'package:zest/core/utils/navigation_helper.dart';
import 'package:zest/core/utils/responsive_utils.dart';
import 'package:zest/core/widgets/defer_until_route_transition.dart';
import 'package:zest/features/settings/application/package_licenses.dart';
import 'package:zest/features/settings/presentation/widgets/app_license_page_shimmer.dart';
import 'package:zest/features/settings/presentation/widgets/settings_card_shape.dart';
import 'package:zest/features/settings/presentation/widgets/settings_list_dialog_shell.dart';
import 'package:zest/features/settings/presentation/widgets/settings_secondary_app_bar.dart';
import 'package:zest/features/settings/presentation/widgets/settings_section.dart';
import 'package:zest/features/settings/presentation/widgets/settings_tile.dart';
import 'package:zest/i18n/tr.dart';

/// Settings screen listing open-source dependency licenses.
class AppLicensePage extends ConsumerWidget {
  /// Creates a [AppLicensePage].
  const AppLicensePage({super.key});

  /// Show license detail.
  void _showLicenseDetail(BuildContext context, PackageLicenseInfo license) {
    NavigationHelper.showAppDialog<void>(
      context: context,
      child: _LicenseDetailDialog(license: license),
    );
  }

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context, WidgetRef ref) {
    final licensesAsync = ref.watch(packageLicensesProvider);
    final appVersion = ref
        .watch(appVersionProvider)
        .maybeWhen(data: (version) => version, orElse: () => null);

    return Scaffold(
      appBar: SettingsSecondaryAppBar(title: 'license'.tr),
      body: licensesAsync.when(
        loading: () => const AppLicensePageShimmer(),
        error: (_, _) => const AppLicensePageShimmer(),
        data: (licenses) => DeferUntilRouteTransition(
          placeholder: const AppLicensePageShimmer(),
          child: _LicensePackageList(
            licenses: licenses,
            appVersion: appVersion,
            onLicenseTap: (license) => _showLicenseDetail(context, license),
          ),
        ),
      ),
    );
  }
}

class _LicensePackageList extends StatelessWidget {
  /// Creates a [_LicensePackageList].
  const _LicensePackageList({
    required this.licenses,
    required this.appVersion,
    required this.onLicenseTap,
  });

  /// The licenses.
  final List<PackageLicenseInfo> licenses;

  /// The app version.
  final String? appVersion;

  /// The on license tap.
  final ValueChanged<PackageLicenseInfo> onLicenseTap;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.spacingL,
        vertical: AppConstants.spacingM,
      ),
      children: [
        _LicenseAppHeader(
          appVersion: appVersion,
          packageCount: licenses.length,
        ),
        SettingsSection(
          title: 'licenseDependencies',
          icon: IconsaxPlusBold.document_text,
          children: [
            for (final license in licenses)
              SettingsTile(
                leading: const Icon(IconsaxPlusLinear.document),
                titleText: license.packageName,
                value: license.paragraphCount == 1
                    ? '1'
                    : '${license.paragraphCount}',
                onTap: () => onLicenseTap(license),
              ),
          ],
        ),
      ],
    );
  }
}

class _LicenseDetailDialog extends StatelessWidget {
  /// Creates a [_LicenseDetailDialog].
  const _LicenseDetailDialog({required this.license});

  /// The license.
  final PackageLicenseInfo license;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsListDialogShell(
      maxHeightFraction: 0.85,
      header: SettingsListDialogHeader(
        title: license.packageName,
        icon: IconsaxPlusLinear.document_text,
      ),
      body: FutureBuilder<String>(
        future: loadPackageLicenseText(license.packageName),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Padding(
              padding: EdgeInsets.all(AppConstants.spacingXXL),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final text = snapshot.data;
          if (text == null || text.isEmpty) {
            return Padding(
              padding: const EdgeInsets.all(AppConstants.spacingXXL),
              child: Text(
                'error_occurred'.tr,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: colorScheme.onSurfaceVariant),
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppConstants.spacingXXL,
              0,
              AppConstants.spacingXXL,
              AppConstants.spacingL,
            ),
            child: SelectableText(
              text,
              style: _licenseBodyStyle(context, colorScheme),
            ),
          );
        },
      ),
      footer: const SettingsListDialogDismissAction(),
    );
  }
}

/// License body style.
TextStyle _licenseBodyStyle(BuildContext context, ColorScheme colorScheme) =>
    Theme.of(context).textTheme.bodyMedium!.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
      height: 1.5,
    );

class _LicenseAppHeader extends ConsumerWidget {
  /// Creates a [_LicenseAppHeader].
  const _LicenseAppHeader({
    required this.appVersion,
    required this.packageCount,
  });

  /// The app version.
  final String? appVersion;

  /// The package count.
  final int packageCount;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppConstants.spacingL),
      child: Card(
        margin: EdgeInsets.zero,
        shape: SettingsCardShape.cardShape(
          amoledTheme: settings.amoledTheme,
          colorScheme: colorScheme,
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingXL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppConstants.borderRadiusLarge,
                    ),
                    child: Image.asset(
                      'assets/icons/icon.png',
                      width: 64,
                      height: 64,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const Gap(AppConstants.spacingL),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Zest',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: colorScheme.onSurface,
                                fontSize: ResponsiveUtils.getResponsiveFontSize(
                                  context,
                                  20,
                                ),
                                height: 1.2,
                              ),
                        ),
                        if (appVersion != null) ...[
                          const Gap(AppConstants.spacingS),
                          _AppVersionChip(version: appVersion!),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              const Gap(AppConstants.spacingL),
              Text(
                'licenseAppSummary'.tr,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: ResponsiveUtils.getResponsiveFontSize(context, 14),
                  height: 1.4,
                ),
              ),
              const Gap(AppConstants.spacingS),
              Row(
                children: [
                  Icon(
                    IconsaxPlusLinear.box,
                    size: AppConstants.iconSizeSmall,
                    color: colorScheme.primary,
                  ),
                  const Gap(AppConstants.spacingXS),
                  Text(
                    '$packageCount ${'licensePackages'.tr}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: ResponsiveUtils.getResponsiveFontSize(
                        context,
                        13,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AppVersionChip extends StatelessWidget {
  /// Creates a [_AppVersionChip].
  const _AppVersionChip({required this.version});

  /// The version.
  final String version;

  @override
  /// Builds the widget subtree.
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spacingM,
            vertical: AppConstants.spacingXS,
          ),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusSmall),
          ),
          child: Text(
            'v$version',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: ResponsiveUtils.getResponsiveFontSize(context, 12),
              height: 1.0,
            ),
            textHeightBehavior: const TextHeightBehavior(
              applyHeightToFirstAscent: false,
              applyHeightToLastDescent: false,
            ),
          ),
        ),
      ],
    );
  }
}
