// lib/db/credential_db.dart

import 'package:sqflite/sqflite.dart';
import '../models/credential.dart';
import '../services/encryption_service.dart';
import 'vault_db.dart';

class CredentialDbHelper {
  static final CredentialDbHelper _instance = CredentialDbHelper._internal();
  factory CredentialDbHelper() => _instance;
  CredentialDbHelper._internal();

  final _encryption = EncryptionService();
  Future<Database> get _db async => await VaultDatabase().database;

  Future<List<Credential>> getCredentials() async {
    final db   = await _db;
    final maps = await db.query('credentials', orderBy: 'id DESC');
    return maps.map((m) {
      String pwd;
      try {
        pwd = _encryption.decrypt(m['password'] as String);
      } catch (_) {
        pwd = '<decryption error>';
      }
      return Credential(
        id:       m['id'] as int,
        title:    m['title'] as String,
        username: m['username'] as String,
        password: pwd,
      );
    }).toList();
  }

  Future<int> insertCredential(Credential c) async {
    final db = await _db;
    return db.insert('credentials', {
      'title':    c.title,
      'username': c.username,
      'password': _encryption.encrypt(c.password),
    });
  }

  Future<int> updateCredential(Credential c) async {
    final db = await _db;
    return db.update(
      'credentials',
      {
        'title':    c.title,
        'username': c.username,
        'password': _encryption.encrypt(c.password),
      },
      where: 'id = ?',
      whereArgs: [c.id],
    );
  }

  Future<int> deleteCredential(int id) async {
    final db = await _db;
    return db.delete('credentials', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _db;
    await db.delete('credentials');
    // if you want to wipe notes as well:
    // await db.delete('wifi_notes');
    // await db.delete('passport_notes');
    // await db.delete('driver_license_notes');
    // await db.delete('membership_notes');
    // await db.delete('security_questions');
    // await db.delete('software_license_notes');
    // await db.delete('emergency_contacts');
    // await db.delete('generic_notes');
  }
}
