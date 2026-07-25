/// Shared constants for local backups.
library;

/// Filename prefix for automatic backup archives (`auto_backup_zest_db_…`).
const String kAutoBackupFilePrefix = 'auto_backup_zest_db_';

/// Filename prefix for manual backups (`backup_zest_db_…`).
const String kManualBackupFilePrefix = 'backup_zest_db_';

/// Method channel name for Android SAF directory / file operations.
const String kBackupDirectoryPickerChannel = 'directory_picker';

/// Platform-channel method that opens the Android SAF directory picker.
const String kBackupPickDirectoryMethod = 'pickDirectory';

/// Platform-channel method that writes a file into an SAF tree URI.
const String kBackupWriteFileMethod = 'writeFile';

/// Whether [path] is an Android Storage Access Framework `content://` URI.
bool isAndroidContentUri(String? path) =>
    path != null && path.isNotEmpty && path.startsWith('content://');
