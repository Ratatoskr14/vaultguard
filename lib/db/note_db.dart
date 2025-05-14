import 'dart:async';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';

class NoteDbHelper {
  static final NoteDbHelper _instance = NoteDbHelper._internal();
  factory NoteDbHelper() => _instance;
  NoteDbHelper._internal();

  static Database? _db;
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path  = join(dbPath, 'vaultguard_notes.db');
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  FutureOr<void> _onCreate(Database db, int version) async {
    // v2 schema with attachment TEXT
    await db.execute('''
      CREATE TABLE wifi_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        ssid TEXT,
        password TEXT,
        attachment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE passport_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        passport_number TEXT,
        name TEXT,
        nationality TEXT,
        date_of_birth TEXT,
        expiry_date TEXT,
        attachment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE driver_license_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        license_number TEXT,
        name TEXT,
        date_of_birth TEXT,
        expiry_date TEXT,
        attachment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE membership_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        club_name TEXT,
        membership_id TEXT,
        start_date TEXT,
        end_date TEXT,
        attachment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE security_questions(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        credential_id INTEGER,
        question TEXT,
        answer TEXT,
        hint TEXT,
        attachment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE software_license_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        license_key TEXT,
        purchase_date TEXT,
        expiry_date TEXT,
        attachment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE emergency_contacts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT,
        phone TEXT,
        relation TEXT,
        notes TEXT,
        attachment TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE generic_notes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT,
        description TEXT,
        attachment TEXT
      )
    ''');
  }

  FutureOr<void> _onUpgrade(Database db, int oldV, int newV) async {
    if (oldV < 2) {
      // add attachment column to existing tables
      const tables = [
        'wifi_notes',
        'passport_notes',
        'driver_license_notes',
        'membership_notes',
        'security_questions',
        'software_license_notes',
        'emergency_contacts',
        'generic_notes'
      ];
      for (final t in tables) {
        await db.execute('ALTER TABLE $t ADD COLUMN attachment TEXT');
      }
    }
  }

  // -- Wi-Fi Notes CRUD --
  Future<List<WifiNote>> getWifiNotes() async {
    final db = await database;
    final rows = await db.query('wifi_notes', orderBy: 'id DESC');
    return rows.map((r) => WifiNote.fromMap(r)).toList();
  }
  Future<int> insertWifi(WifiNote n) async {
    final db = await database;
    return db.insert('wifi_notes', n.toMap());
  }
  Future<int> updateWifi(WifiNote n) async {
    final db = await database;
    return db.update('wifi_notes', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }
  Future<int> deleteWifi(int id) async {
    final db = await database;
    return db.delete('wifi_notes', where: 'id = ?', whereArgs: [id]);
  }

  // -- Passport Notes CRUD --
  Future<List<PassportNote>> getPassportNotes() async {
    final db = await database;
    final rows = await db.query('passport_notes', orderBy: 'id DESC');
    return rows.map((r) => PassportNote.fromMap(r)).toList();
  }
  Future<int> insertPassport(PassportNote n) async {
    final db = await database;
    return db.insert('passport_notes', n.toMap());
  }
  Future<int> updatePassport(PassportNote n) async {
    final db = await database;
    return db.update('passport_notes', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }
  Future<int> deletePassport(int id) async {
    final db = await database;
    return db.delete('passport_notes', where: 'id = ?', whereArgs: [id]);
  }

  // -- Driver License Notes CRUD --
  Future<List<DriverLicenseNote>> getDriverLicenses() async {
    final db = await database;
    final rows = await db.query('driver_license_notes', orderBy: 'id DESC');
    return rows.map((r) => DriverLicenseNote.fromMap(r)).toList();
  }
  Future<int> insertDriverLicense(DriverLicenseNote n) async {
    final db = await database;
    return db.insert('driver_license_notes', n.toMap());
  }
  Future<int> updateDriverLicense(DriverLicenseNote n) async {
    final db = await database;
    return db.update('driver_license_notes', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }
  Future<int> deleteDriverLicense(int id) async {
    final db = await database;
    return db.delete('driver_license_notes', where: 'id = ?', whereArgs: [id]);
  }

  // -- Membership Notes CRUD --
  Future<List<MembershipNote>> getMemberships() async {
    final db = await database;
    final rows = await db.query('membership_notes', orderBy: 'id DESC');
    return rows.map((r) => MembershipNote.fromMap(r)).toList();
  }
  Future<int> insertMembership(MembershipNote n) async {
    final db = await database;
    return db.insert('membership_notes', n.toMap());
  }
  Future<int> updateMembership(MembershipNote n) async {
    final db = await database;
    return db.update('membership_notes', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }
  Future<int> deleteMembership(int id) async {
    final db = await database;
    return db.delete('membership_notes', where: 'id = ?', whereArgs: [id]);
  }

  // -- Security Questions CRUD --
  Future<List<SecurityQuestionNote>> getSecurityQuestions() async {
    final db = await database;
    final rows = await db.query('security_questions', orderBy: 'id DESC');
    return rows.map((r) => SecurityQuestionNote.fromMap(r)).toList();
  }
  Future<int> insertSecurityQuestion(SecurityQuestionNote n) async {
    final db = await database;
    return db.insert('security_questions', n.toMap());
  }
  Future<int> updateSecurityQuestion(SecurityQuestionNote n) async {
    final db = await database;
    return db.update('security_questions', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }
  Future<int> deleteSecurityQuestion(int id) async {
    final db = await database;
    return db.delete('security_questions', where: 'id = ?', whereArgs: [id]);
  }

  // -- Software License Notes CRUD --
  Future<List<SoftwareLicenseNote>> getSoftwareLicenses() async {
    final db = await database;
    final rows = await db.query('software_license_notes', orderBy: 'id DESC');
    return rows.map((r) => SoftwareLicenseNote.fromMap(r)).toList();
  }
  Future<int> insertSoftwareLicense(SoftwareLicenseNote n) async {
    final db = await database;
    return db.insert('software_license_notes', n.toMap());
  }
  Future<int> updateSoftwareLicense(SoftwareLicenseNote n) async {
    final db = await database;
    return db.update('software_license_notes', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }
  Future<int> deleteSoftwareLicense(int id) async {
    final db = await database;
    return db.delete('software_license_notes', where: 'id = ?', whereArgs: [id]);
  }

  // -- Emergency Contact Notes CRUD --
  Future<List<EmergencyContactNote>> getEmergencyContacts() async {
    final db = await database;
    final rows = await db.query('emergency_contacts', orderBy: 'id DESC');
    return rows.map((r) => EmergencyContactNote.fromMap(r)).toList();
  }
  Future<int> insertEmergencyContact(EmergencyContactNote n) async {
    final db = await database;
    return db.insert('emergency_contacts', n.toMap());
  }
  Future<int> updateEmergencyContact(EmergencyContactNote n) async {
    final db = await database;
    return db.update('emergency_contacts', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }
  Future<int> deleteEmergencyContact(int id) async {
    final db = await database;
    return db.delete('emergency_contacts', where: 'id = ?', whereArgs: [id]);
  }

  // -- Generic Notes CRUD --
  Future<List<GenericNote>> getGenericNotes() async {
    final db = await database;
    final rows = await db.query('generic_notes', orderBy: 'id DESC');
    return rows.map((r) => GenericNote.fromMap(r)).toList();
  }
  Future<int> insertGeneric(GenericNote n) async {
    final db = await database;
    final data = Map<String, dynamic>.from(n.toMap())..remove('id');
    return db.insert('generic_notes', data);
  }
  Future<int> updateGeneric(GenericNote n) async {
    final db = await database;
    return db.update('generic_notes', n.toMap(), where: 'id = ?', whereArgs: [n.id]);
  }
  Future<int> deleteGeneric(int id) async {
    final db = await database;
    return db.delete('generic_notes', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await database;
    await db.delete('wifi_notes');
    await db.delete('passport_notes');
    await db.delete('driver_license_notes');
    await db.delete('membership_notes');
    await db.delete('security_questions');
    await db.delete('software_license_notes');
    await db.delete('emergency_contacts');
    await db.delete('generic_notes');
  }
}
