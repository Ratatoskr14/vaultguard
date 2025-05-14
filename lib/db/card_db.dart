import 'package:sqflite/sqflite.dart';
import 'vault_db.dart';
import '../models/card.dart';

class CardDbHelper {
  static final CardDbHelper _instance = CardDbHelper._internal();
  factory CardDbHelper() => _instance;
  CardDbHelper._internal();

  Future<Database> get _db async => (await VaultDatabase().database);

  // -- Payment cards CRUD --
  Future<List<PaymentCard>> getPaymentCards() async {
    final db = await _db;
    final rows = await db.query('payment_cards', orderBy: 'id DESC');
    return rows.map((r) => PaymentCard.fromMap(r)).toList();
  }
  Future<int> insertPayment(PaymentCard c) async {
    final db = await _db;
    return db.insert('payment_cards', c.toMap());
  }
  Future<int> updatePayment(PaymentCard c) async {
    final db = await _db;
    return db.update('payment_cards', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }
  Future<int> deletePayment(int id) async {
    final db = await _db;
    return db.delete('payment_cards', where: 'id = ?', whereArgs: [id]);
  }

  // -- ID cards CRUD --
  Future<List<IDCard>> getIDCards() async {
    final db = await _db;
    final rows = await db.query('id_cards', orderBy: 'id DESC');
    return rows.map((r) => IDCard.fromMap(r)).toList();
  }
  Future<int> insertID(IDCard c) async {
    final db = await _db;
    return db.insert('id_cards', c.toMap());
  }
  Future<int> updateID(IDCard c) async {
    final db = await _db;
    return db.update('id_cards', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }
  Future<int> deleteID(int id) async {
    final db = await _db;
    return db.delete('id_cards', where: 'id = ?', whereArgs: [id]);
  }

  // -- Driver License cards CRUD --
  Future<List<DriverLicenseCard>> getDriverLicenseCards() async {
    final db = await _db;
    final rows = await db.query('driver_license_cards', orderBy: 'id DESC');
    return rows.map((r) => DriverLicenseCard.fromMap(r)).toList();
  }
  Future<int> insertDriverLicense(DriverLicenseCard c) async {
    final db = await _db;
    return db.insert('driver_license_cards', c.toMap());
  }
  Future<int> updateDriverLicense(DriverLicenseCard c) async {
    final db = await _db;
    return db.update('driver_license_cards', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }
  Future<int> deleteDriverLicenseCard(int id) async {
    final db = await _db;
    return db.delete('driver_license_cards', where: 'id = ?', whereArgs: [id]);
  }

  // -- Gift cards CRUD --
  Future<List<GiftCard>> getGiftCards() async {
    final db = await _db;
    final rows = await db.query('gift_cards', orderBy: 'id DESC');
    return rows.map((r) => GiftCard.fromMap(r)).toList();
  }
  Future<int> insertGiftCard(GiftCard c) async {
    final db = await _db;
    return db.insert('gift_cards', c.toMap());
  }
  Future<int> updateGiftCard(GiftCard c) async {
    final db = await _db;
    return db.update('gift_cards', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }
  Future<int> deleteGiftCard(int id) async {
    final db = await _db;
    return db.delete('gift_cards', where: 'id = ?', whereArgs: [id]);
  }

  // -- Misc cards CRUD --
  Future<List<MiscCard>> getMiscCards() async {
    final db = await _db;
    final rows = await db.query('misc_cards', orderBy: 'id DESC');
    return rows.map((r) => MiscCard.fromMap(r)).toList();
  }
  Future<int> insertMiscCard(MiscCard c) async {
    final db = await _db;
    return db.insert('misc_cards', c.toMap());
  }
  Future<int> updateMiscCard(MiscCard c) async {
    final db = await _db;
    return db.update('misc_cards', c.toMap(),
        where: 'id = ?', whereArgs: [c.id]);
  }
  Future<int> deleteMiscCard(int id) async {
    final db = await _db;
    return db.delete('misc_cards', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await _db;
    await db.delete('payment_cards');
    await db.delete('id_cards');
    await db.delete('driver_license_cards');
    await db.delete('gift_cards');
    await db.delete('misc_cards');
  }
}
