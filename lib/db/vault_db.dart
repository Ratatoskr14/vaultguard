// lib/db/vault_db.dart

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class VaultDatabase {
  static final VaultDatabase _instance = VaultDatabase._();
  factory VaultDatabase() => _instance;
  VaultDatabase._();

  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _init();
    return _db!;
  }

  Future<Database> _init() async {
    final dbPath = await getDatabasesPath();
    final path   = join(dbPath, 'vaultguard.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // Credentials table
    await db.execute('''
      CREATE TABLE credentials(
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        title    TEXT,
        username TEXT,
        password TEXT
      );
    ''');

    // All note tables
    await _createNoteTables(db);
  }

  Future _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      // New in v2: note tables
      await _createNoteTables(db);
    }
  }

  Future _createNoteTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS wifi_notes(
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        ssid       TEXT,
        password   TEXT,
        attachment TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS passport_notes(
        id              INTEGER PRIMARY KEY AUTOINCREMENT,
        passport_number TEXT,
        name            TEXT,
        nationality     TEXT,
        dob             TEXT,
        expiry          TEXT,
        attachment      TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS driver_license_notes(
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        license_number TEXT,
        name           TEXT,
        dob            TEXT,
        expiry         TEXT,
        attachment     TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS membership_notes(
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        club_name      TEXT,
        membership_id  TEXT,
        start_date     TEXT,
        end_date       TEXT,
        attachment     TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS security_questions(
        id             INTEGER PRIMARY KEY AUTOINCREMENT,
        credential_id  INTEGER,
        question       TEXT,
        answer         TEXT,
        hint           TEXT,
        FOREIGN KEY(credential_id) REFERENCES credentials(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS software_license_notes(
        id           INTEGER PRIMARY KEY AUTOINCREMENT,
        title        TEXT,
        license_key  TEXT,
        purchase_date TEXT,
        expiry_date   TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS emergency_contacts(
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        name     TEXT,
        phone    TEXT,
        relation TEXT,
        notes    TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS generic_notes(
        id          INTEGER PRIMARY KEY AUTOINCREMENT,
        title       TEXT,
        description TEXT,
        attachment  TEXT
      );
    ''');
  }
}
