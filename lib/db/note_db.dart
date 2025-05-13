import 'dart:async';
import 'package:sqflite/sqflite.dart';
import '../models/note.dart';
import 'vault_db.dart';

class NoteDbHelper {
  static final NoteDbHelper _instance = NoteDbHelper._internal();
  factory NoteDbHelper() => _instance;
  NoteDbHelper._internal();

  Future<Database> get _db async => (await VaultDatabase().database);

  // Wi-Fi notes
  Future<List<WifiNote>> getWifiNotes() async {
    final db = await _db;
    final rows = await db.query('wifi_notes', orderBy: 'id DESC');
    return rows.map((r) => WifiNote.fromMap(r)).toList();
  }

  Future<int> insertWifi(WifiNote n) async {
    final db = await _db;
    return db.insert('wifi_notes', n.toMap());
  }

  Future<int> updateWifi(WifiNote n) async {
    final db = await _db;
    return db.update('wifi_notes', n.toMap(),
        where: 'id = ?', whereArgs: [n.id]);
  }

  Future<int> deleteWifi(int id) async {
    final db = await _db;
    return db.delete('wifi_notes', where: 'id = ?', whereArgs: [id]);
  }

  // Passport notes
  Future<List<PassportNote>> getPassportNotes() async {
    final db = await _db;
    final rows = await db.query('passport_notes', orderBy: 'id DESC');
    return rows.map((r) => PassportNote.fromMap(r)).toList();
  }

  Future<int> insertPassport(PassportNote n) async {
    final db = await _db;
    return db.insert('passport_notes', n.toMap());
  }

  Future<int> updatePassport(PassportNote n) async {
    final db = await _db;
    return db.update('passport_notes', n.toMap(),
        where: 'id = ?', whereArgs: [n.id]);
  }

  Future<int> deletePassport(int id) async {
    final db = await _db;
    return db.delete('passport_notes', where: 'id = ?', whereArgs: [id]);
  }

  // Driver’s license notes
  Future<List<DriverLicenseNote>> getDriverLicenses() async {
    final db = await _db;
    final rows = await db.query('driver_license_notes', orderBy: 'id DESC');
    return rows.map((r) => DriverLicenseNote.fromMap(r)).toList();
  }

  Future<int> insertDriverLicense(DriverLicenseNote n) async {
    final db = await _db;
    return db.insert('driver_license_notes', n.toMap());
  }

  Future<int> updateDriverLicense(DriverLicenseNote n) async {
    final db = await _db;
    return db.update('driver_license_notes', n.toMap(),
        where: 'id = ?', whereArgs: [n.id]);
  }

  Future<int> deleteDriverLicense(int id) async {
    final db = await _db;
    return db.delete('driver_license_notes', where: 'id = ?', whereArgs: [id]);
  }

  // Membership notes
  Future<List<MembershipNote>> getMemberships() async {
    final db = await _db;
    final rows = await db.query('membership_notes', orderBy: 'id DESC');
    return rows.map((r) => MembershipNote.fromMap(r)).toList();
  }

  Future<int> insertMembership(MembershipNote n) async {
    final db = await _db;
    return db.insert('membership_notes', n.toMap());
  }

  Future<int> updateMembership(MembershipNote n) async {
    final db = await _db;
    return db.update('membership_notes', n.toMap(),
        where: 'id = ?', whereArgs: [n.id]);
  }

  Future<int> deleteMembership(int id) async {
    final db = await _db;
    return db.delete('membership_notes', where: 'id = ?', whereArgs: [id]);
  }

  // Security questions
  Future<List<SecurityQuestionNote>> getSecurityQuestions() async {
    final db = await _db;
    final rows = await db.query('security_questions', orderBy: 'id DESC');
    return rows.map((r) => SecurityQuestionNote.fromMap(r)).toList();
  }

  Future<int> insertSecurityQuestion(SecurityQuestionNote n) async {
    final db = await _db;
    return db.insert('security_questions', n.toMap());
  }

  Future<int> updateSecurityQuestion(SecurityQuestionNote n) async {
    final db = await _db;
    return db.update('security_questions', n.toMap(),
        where: 'id = ?', whereArgs: [n.id]);
  }

  Future<int> deleteSecurityQuestion(int id) async {
    final db = await _db;
    return db.delete('security_questions', where: 'id = ?', whereArgs: [id]);
  }

  // Software license notes
  Future<List<SoftwareLicenseNote>> getSoftwareLicenses() async {
    final db = await _db;
    final rows = await db.query('software_license_notes', orderBy: 'id DESC');
    return rows.map((r) => SoftwareLicenseNote.fromMap(r)).toList();
  }

  Future<int> insertSoftwareLicense(SoftwareLicenseNote n) async {
    final db = await _db;
    return db.insert('software_license_notes', n.toMap());
  }

  Future<int> updateSoftwareLicense(SoftwareLicenseNote n) async {
    final db = await _db;
    return db.update('software_license_notes', n.toMap(),
        where: 'id = ?', whereArgs: [n.id]);
  }

  Future<int> deleteSoftwareLicense(int id) async {
    final db = await _db;
    return db.delete('software_license_notes', where: 'id = ?', whereArgs: [id]);
  }

  // Emergency contacts
  Future<List<EmergencyContactNote>> getEmergencyContacts() async {
    final db = await _db;
    final rows = await db.query('emergency_contacts', orderBy: 'id DESC');
    return rows.map((r) => EmergencyContactNote.fromMap(r)).toList();
  }

  Future<int> insertEmergencyContact(EmergencyContactNote n) async {
    final db = await _db;
    return db.insert('emergency_contacts', n.toMap());
  }

  Future<int> updateEmergencyContact(EmergencyContactNote n) async {
    final db = await _db;
    return db.update('emergency_contacts', n.toMap(),
        where: 'id = ?', whereArgs: [n.id]);
  }

  Future<int> deleteEmergencyContact(int id) async {
    final db = await _db;
    return db.delete('emergency_contacts', where: 'id = ?', whereArgs: [id]);
  }

  // Generic notes
  Future<List<GenericNote>> getGenericNotes() async {
    final db = await _db;
    final rows = await db.query('generic_notes', orderBy: 'id DESC');
    return rows.map((r) => GenericNote.fromMap(r)).toList();
  }

  Future<int> insertGeneric(GenericNote n) async {
    final db = await _db;
    return db.insert('generic_notes', n.toMap());
  }

  Future<int> updateGeneric(GenericNote n) async {
    final db = await _db;
    return db.update('generic_notes', n.toMap(),
        where: 'id = ?', whereArgs: [n.id]);
  }

  Future<int> deleteGeneric(int id) async {
    final db = await _db;
    return db.delete('generic_notes', where: 'id = ?', whereArgs: [id]);
  }
}
