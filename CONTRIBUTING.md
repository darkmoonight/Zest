# Contribution Guidelines

Thank you for considering contributing to Zest! Please review these guidelines before opening a pull request.

## Code of Conduct

This project is governed by our [Code of Conduct](CODE_OF_CONDUCT.md).

## How to Contribute

1. Fork the repository and clone it locally.
2. Create a new branch for your feature or bug fix.
3. Make your changes and commit them.
4. Push your changes to your fork on GitHub.
5. Open a pull request with a clear title and description.

## Translations

Zest uses [Slang](https://pub.dev/packages/slang) with JSON files in `assets/i18n/`.

1. Add or update keys in `assets/i18n/en-US.i18n.json`.
2. Mirror the key in all other locale files under `assets/i18n/`.
3. Run `dart run slang` to regenerate `lib/i18n/strings*.g.dart`.
4. Run `dart run slang analyze` (or `./scripts/check_i18n.sh`) to verify key parity.

Do not use `slang analyze --full` for CI checks: numeric keys `"12"` / `"24"` (time format labels) break the full analyzer. Plain `slang analyze` is the supported parity check.

## Create / edit forms

Use `NavigationHelper.showFormModal` for TasksAction / TodosAction / TodosTransfer (and similar create/edit sheets). Do not call raw `showModalBottomSheet` for those forms — on tablet/desktop the helper presents a centered dialog with `maxModalWidth`.

## material_ui compatibility

The app targets `package:material_ui` (Flutter 3.47+). A deprecated `MaterialUiCompatibilityBridge` remains in `lib/app.dart` because legacy packages still import `package:flutter/material.dart` (`flex_color_picker`, `google_fonts`, `sleek_circular_slider`, and related). Dynamic color uses `MaterialUiDynamicColorBuilder` (seed from `DynamicColorPlugin`) so Flutter `ColorScheme` conversion is not on the theme hot path. Text themes still bridge via `textThemeToFlutter` / `textThemeFromFlutter` for Google Fonts.

Remove the compatibility bridge only after those packages migrate to `material_ui` or are replaced.

## Architecture layers

| Layer | Path | Rules |
|-------|------|--------|
| Domain | `lib/domain/` | Entities, enums, repository/side-effect ports, usecases. No `isar_community`, no `data/models/db.dart`, no `material_ui`, no `features/`. |
| Data | `lib/data/` | Isar collections (`db.dart`), mappers, repository implementations. |
| Features | `lib/features/` | UI + Riverpod notifiers. Import domain entities/enums; do not import `db.dart`. |
| Core | `lib/core/` | Bootstrap, adapters (CalDAV, notifications, device calendar, backup), DI. May touch Isar at the edge via mappers. |

- Prefer `categoryId` / `parentId` on domain `Todo` over Isar links in UI/application code.
- Mutate live preferences through `liveSettingsProvider` + `writeLiveSettings`; read UI snapshots from `settingsProvider` (`AppSettings`).
- Usecases depend on ports in `lib/domain/ports/` and `lib/domain/repositories/`. Concrete adapters (`NotificationService`, `CalDavSyncService`, `DeviceCalendarSyncService`, repositories) live in `lib/core/` / `lib/data/` and are wired in DI (`provider_refs.dart`).
- Production API uses Category naming (`CategoryService`, `categoriesNotifierProvider`, `lib/features/categories/`). Isar collection/property/link names stay `Tasks` / `taskColor` / `task` (schema lock); only mappers/repos touch those.

## Coding Standards

- Follow existing patterns: Riverpod notifiers, feature folders, Rain-style settings sections.
- Run `flutter analyze` before submitting.
- Match surrounding code style and naming.

## Testing

Add tests in `test/` when fixing bugs or adding testable logic. Run:

```bash
flutter test
```

## Documentation

- Add `///` dartdoc to public and private classes, methods, and fields (Rain style).
- Persisted defaults and picker lists belong in [`lib/core/constants/app_constants.dart`](lib/core/constants/app_constants.dart).
- Date/time formatting uses [`lib/core/utils/date_time_format_helper.dart`](lib/core/utils/date_time_format_helper.dart).
- Settings enum pickers are defined in [`lib/core/config/setting_enum_pickers.dart`](lib/core/config/setting_enum_pickers.dart).

Update `README.md` when changing architecture, i18n workflow, or notifications.

## License

By contributing, you agree that your contributions will be licensed under the project's [MIT License](LICENSE).
