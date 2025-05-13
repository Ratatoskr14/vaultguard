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
      version: 3,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future _onCreate(Database db, int version) async {
    // 1) Credentials
    await db.execute('''
      CREATE TABLE credentials(
        id       INTEGER PRIMARY KEY AUTOINCREMENT,
        title    TEXT,
        username TEXT,
        password TEXT
      );
    ''');

    // 2) Notes
    await _createNoteTables(db);

    // 3) Cards
    await _createCardTables(db);
  }

  Future _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      // v2: add note tables
      await _createNoteTables(db);
    }
    if (oldV < 3) {
      // v3: add card tables
      await _createCardTables(db);
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
        attachment     TEXT,
        FOREIGN KEY(credential_id) REFERENCES credentials(id) ON DELETE CASCADE
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS software_license_notes(
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        title         TEXT,
        license_key   TEXT,
        purchase_date TEXT,
        expiry_date   TEXT,
        attachment    TEXT
      );
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS emergency_contacts(
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        name       TEXT,
        phone      TEXT,
        relation   TEXT,
        notes      TEXT,
        attachment TEXT
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

  Future _createCardTables(Database db) async {
    // Payment cards
    await db.execute('''
      CREATE TABLE IF NOT EXISTS payment_cards(
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        cardholder_name  TEXT,
        card_number      TEXT,
        expiry_date      TEXT,
        cvv              TEXT,
        attachment       TEXT
      );
    ''');

    // ID cards
    await db.execute('''
      CREATE TABLE IF NOT EXISTS id_cards(
        id                INTEGER PRIMARY KEY AUTOINCREMENT,
        card_type         TEXT,
        id_number         TEXT,
        name              TEXT,
        issuing_authority TEXT,
        expiry_date       TEXT,
        attachment        TEXT
      );
    ''');

    // Driver’s license as card
    await db.execute('''
      CREATE TABLE IF NOT EXISTS driver_license_cards(
        id               INTEGER PRIMARY KEY AUTOINCREMENT,
        license_number   TEXT,
        name             TEXT,
        date_of_birth    TEXT,
        expiry_date      TEXT,
        issuing_state    TEXT,
        attachment       TEXT
      );
    ''');

    // Gift cards
    await db.execute('''
      CREATE TABLE IF NOT EXISTS gift_cards(
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        card_name     TEXT,
        card_number   TEXT,
        expiry_date   TEXT,
        attachment    TEXT
      );
    ''');

    // Miscellaneous cards
    await db.execute('''
      CREATE TABLE IF NOT EXISTS misc_cards(
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        title         TEXT,
        details       TEXT,
        attachment    TEXT
      );
    ''');
  }
}
