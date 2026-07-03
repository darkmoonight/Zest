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
