// lib/services/backup_service.dart

import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../db/vault_db.dart';
import 'drive_service.dart';
import 'encryption_service.dart';

class BackupService {
  /// Creates a timestamped, encrypted backup in /storage/emulated/0/VaultGuard/Backup
  Future<File> createBackup() async {
    // 1) Locate the on-device database file
    final dbPath = await getDatabasesPath();
    final source = join(dbPath, 'vaultguard.db');

    // 2) Read file bytes & base64 encode
    final rawBytes = await File(source).readAsBytes();
    final base64Data = base64Encode(rawBytes);

    // 3) Encrypt the encoded data
    final encryptedContent = EncryptionService().encrypt(base64Data);

    // 4) Write to public external storage under /VaultGuard/Backup
    final backupDir = Directory('/storage/emulated/0/VaultGuard/Backup');
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }

    // 5) Create timestamped filename
    final timestamp = DateTime.now()
        .toIso8601String()
        .replaceAll(RegExp(r'[:.]'), '-');
    final fileName = 'vaultguard_backup_${timestamp}.db.enc';
    final outFile = File(join(backupDir.path, fileName));

    // 6) Write encrypted content to the file
    await outFile.writeAsString(encryptedContent, flush: true);
    return outFile;
  }

  /// Restores a backup file at [backupPath] into the app database
  Future<void> restoreBackup(String backupPath) async {
    // Read & decrypt the backup
    final encryptedContent = await File(backupPath).readAsString();
    final base64Data = EncryptionService().decrypt(encryptedContent);
    final rawBytes = base64Decode(base64Data);

    // Determine target database path
    final dbPath = await getDatabasesPath();
    final target = join(dbPath, 'vaultguard.db');

    // Close any open database connection
    try {
      final db = await VaultDatabase().database;
      await db.close();
    } catch (_) {
      // ignore if already closed
    }

    // Overwrite the database file
    final file = File(target);
    await file.writeAsBytes(rawBytes, flush: true);
  }
}
