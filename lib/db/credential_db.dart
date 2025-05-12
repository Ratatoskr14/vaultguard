import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/credential.dart';
import '../services/encryption_service.dart';

class CredentialDbHelper {
  static final CredentialDbHelper _instance = CredentialDbHelper._internal();
  factory CredentialDbHelper() => _instance;
  CredentialDbHelper._internal();

  static Database? _db;
  final _encryption = EncryptionService();

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'vaultguard.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE credentials(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT,
            username TEXT,
            password TEXT
          )
        ''');
      },
    );
  }

  /// Fetches all credentials, decrypting each.
  /// If decryption fails (due to key mismatch or corrupted data),
  /// the password shows as '<decryption error>' instead of crashing.
  // lib/db/credential_db.dart

  Future<List<Credential>> getCredentials() async {
    final db   = await database;
    final maps = await db.query('credentials', orderBy: 'id DESC');
    final List<Credential> creds = [];

    for (final map in maps) {
      String decrypted;
      try {
        decrypted = _encryption.decrypt(map['password'] as String);
      } catch (e) {
        // fallback so we don’t crash — maybe key changed or data is bad
        decrypted = '<decryption error>';
      }
      creds.add(Credential(
        id:       map['id'] as int,
        title:    map['title'] as String,
        username: map['username'] as String,
        password: decrypted,
      ));
    }

    return creds;
  }

  Future<int> insertCredential(Credential cred) async {
    final db = await database;
    final encrypted = _encryption.encrypt(cred.password);
    return await db.insert('credentials', {
      'title': cred.title,
      'username': cred.username,
      'password': encrypted,
    });
  }

  Future<int> updateCredential(Credential cred) async {
    final db = await database;
    final encrypted = _encryption.encrypt(cred.password);
    return await db.update(
      'credentials',
      {'title': cred.title, 'username': cred.username, 'password': encrypted},
      where: 'id = ?',
      whereArgs: [cred.id],
    );
  }

  Future<int> deleteCredential(int id) async {
    final db = await database;
    return await db.delete('credentials', where: 'id = ?', whereArgs: [id]);
  }

  /// Wipes all stored credentials
  Future<void> clearAll() async {
    final db = await database;
    await db.delete('credentials');
  }
}