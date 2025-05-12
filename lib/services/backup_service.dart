import 'dart:io';

/// Handles local backup creation on device
class BackupService {
  Future<File> createBackup() async {
    // TODO: serialize DB, write to local file
    throw UnimplementedError();
  }

  /// Schedule backups at a given frequency (in days)
  void schedulePeriodicBackup(int days) {
    // TODO: integrate workmanager or android_alarm_manager
  }
}