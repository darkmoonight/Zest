import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Stores the CalDAV password outside Isar / the settings sidecar.
class CalDavCredentialsStore {
  /// Creates a store backed by [storage] or platform secure storage.
  CalDavCredentialsStore({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  /// In-memory store for tests (no platform plugins).
  CalDavCredentialsStore.memory() : _storage = null;

  static const _passwordKey = 'caldav_password';

  final FlutterSecureStorage? _storage;
  String? _memoryPassword;

  /// Persists [password], replacing any previous value.
  Future<void> savePassword(String password) async {
    _memoryPassword = password;
    await _storage?.write(key: _passwordKey, value: password);
  }

  /// Returns the saved password, or null when unset.
  Future<String?> readPassword() async {
    if (_storage == null) return _memoryPassword;
    return _storage.read(key: _passwordKey);
  }

  /// Removes the saved password.
  Future<void> clear() async {
    _memoryPassword = null;
    await _storage?.delete(key: _passwordKey);
  }
}
