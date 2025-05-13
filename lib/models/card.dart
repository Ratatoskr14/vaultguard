import 'dart:convert';

enum CardType { payment, id, driverLicense, gift, misc }

/// Base class
abstract class CardBase {
  final int id;
  final CardType type;
  final List<String> attachmentPaths;

  CardBase({
    required this.id,
    required this.type,
    required this.attachmentPaths,
  });
}

/// Decode legacy or JSON list
List<String> _parseAttach(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    return List<String>.from(jsonDecode(raw));
  } catch (_) {
    return [raw];
  }
}

/// Payment / debit card
class PaymentCard extends CardBase {
  final String cardholderName, cardNumber, expiryDate, cvv;

  PaymentCard({
    required int id,
    required this.cardholderName,
    required this.cardNumber,
    required this.expiryDate,
    required this.cvv,
    required List<String> attachmentPaths,
  }) : super(id: id, type: CardType.payment, attachmentPaths: attachmentPaths);

  factory PaymentCard.fromMap(Map<String, dynamic> m) => PaymentCard(
    id: m['id'] as int,
    cardholderName: m['cardholder_name'] as String,
    cardNumber: m['card_number'] as String,
    expiryDate: m['expiry_date'] as String,
    cvv: m['cvv'] as String,
    attachmentPaths: _parseAttach(m['attachment'] as String?),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'cardholder_name': cardholderName,
    'card_number': cardNumber,
    'expiry_date': expiryDate,
    'cvv': cvv,
    'attachment': jsonEncode(attachmentPaths),
  };
}

/// ID card (Aadhaar, PAN, etc.)
class IDCard extends CardBase {
  final String cardType, idNumber, name, issuingAuthority, expiryDate;

  IDCard({
    required int id,
    required this.cardType,
    required this.idNumber,
    required this.name,
    required this.issuingAuthority,
    required this.expiryDate,
    required List<String> attachmentPaths,
  }) : super(id: id, type: CardType.id, attachmentPaths: attachmentPaths);

  factory IDCard.fromMap(Map<String, dynamic> m) => IDCard(
    id: m['id'] as int,
    cardType: m['card_type'] as String,
    idNumber: m['id_number'] as String,
    name: m['name'] as String,
    issuingAuthority: m['issuing_authority'] as String,
    expiryDate: m['expiry_date'] as String,
    attachmentPaths: _parseAttach(m['attachment'] as String?),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'card_type': cardType,
    'id_number': idNumber,
    'name': name,
    'issuing_authority': issuingAuthority,
    'expiry_date': expiryDate,
    'attachment': jsonEncode(attachmentPaths),
  };
}

/// Driver’s License (card)
class DriverLicenseCard extends CardBase {
  final String licenseNumber, name, dob, expiryDate, issuingState;

  DriverLicenseCard({
    required int id,
    required this.licenseNumber,
    required this.name,
    required this.dob,
    required this.expiryDate,
    required this.issuingState,
    required List<String> attachmentPaths,
  }) : super(id: id, type: CardType.driverLicense, attachmentPaths: attachmentPaths);

  factory DriverLicenseCard.fromMap(Map<String, dynamic> m) => DriverLicenseCard(
    id: m['id'] as int,
    licenseNumber: m['license_number'] as String,
    name: m['name'] as String,
    dob: m['date_of_birth'] as String,
    expiryDate: m['expiry_date'] as String,
    issuingState: m['issuing_state'] as String,
    attachmentPaths: _parseAttach(m['attachment'] as String?),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'license_number': licenseNumber,
    'name': name,
    'date_of_birth': dob,
    'expiry_date': expiryDate,
    'issuing_state': issuingState,
    'attachment': jsonEncode(attachmentPaths),
  };
}

/// Gift card
class GiftCard extends CardBase {
  final String cardName, cardNumber, expiryDate;

  GiftCard({
    required int id,
    required this.cardName,
    required this.cardNumber,
    required this.expiryDate,
    required List<String> attachmentPaths,
  }) : super(id: id, type: CardType.gift, attachmentPaths: attachmentPaths);

  factory GiftCard.fromMap(Map<String, dynamic> m) => GiftCard(
    id: m['id'] as int,
    cardName: m['card_name'] as String,
    cardNumber: m['card_number'] as String,
    expiryDate: m['expiry_date'] as String,
    attachmentPaths: _parseAttach(m['attachment'] as String?),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'card_name': cardName,
    'card_number': cardNumber,
    'expiry_date': expiryDate,
    'attachment': jsonEncode(attachmentPaths),
  };
}

/// Miscellaneous card
class MiscCard extends CardBase {
  final String title, details;

  MiscCard({
    required int id,
    required this.title,
    required this.details,
    required List<String> attachmentPaths,
  }) : super(id: id, type: CardType.misc, attachmentPaths: attachmentPaths);

  factory MiscCard.fromMap(Map<String, dynamic> m) => MiscCard(
    id: m['id'] as int,
    title: m['title'] as String,
    details: m['details'] as String,
    attachmentPaths: _parseAttach(m['attachment'] as String?),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'details': details,
    'attachment': jsonEncode(attachmentPaths),
  };
}
