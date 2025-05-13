import 'dart:convert';

/// All the note categories.
enum NoteType {
  wifi,
  passport,
  driverLicense,
  membership,
  securityQuestion,
  softwareLicense,
  emergencyContact,
  generic
}

/// Base class for every note.
abstract class Note {
  final int id;
  final NoteType type;
  final List<String> attachmentPaths;

  Note({
    required this.id,
    required this.type,
    required this.attachmentPaths,
  });
}

/// Helper to parse the JSON-string (or older single-path) into a List<String>.
List<String> _parseAttachments(String? raw) {
  if (raw == null || raw.isEmpty) return [];
  try {
    final decoded = jsonDecode(raw);
    return List<String>.from(decoded);
  } catch (_) {
    // fallback for legacy single-path
    return [raw];
  }
}

/// Wi-Fi note: SSID + password
class WifiNote extends Note {
  final String ssid;
  final String password;

  WifiNote({
    required int id,
    required this.ssid,
    required this.password,
    required List<String> attachmentPaths,
  }) : super(id: id, type: NoteType.wifi, attachmentPaths: attachmentPaths);

  factory WifiNote.fromMap(Map<String, dynamic> m) {
    return WifiNote(
      id: m['id'] as int,
      ssid: m['ssid'] as String,
      password: m['password'] as String,
      attachmentPaths: _parseAttachments(m['attachment'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ssid': ssid,
      'password': password,
      'attachment': jsonEncode(attachmentPaths),
    };
  }
}

/// Passport details
class PassportNote extends Note {
  final String passportNumber;
  final String name;
  final String nationality;
  final String dateOfBirth;
  final String expiryDate;

  PassportNote({
    required int id,
    required this.passportNumber,
    required this.name,
    required this.nationality,
    required this.dateOfBirth,
    required this.expiryDate,
    required List<String> attachmentPaths,
  }) : super(id: id, type: NoteType.passport, attachmentPaths: attachmentPaths);

  factory PassportNote.fromMap(Map<String, dynamic> m) {
    return PassportNote(
      id: m['id'] as int,
      passportNumber: m['passport_number'] as String,
      name: m['name'] as String,
      nationality: m['nationality'] as String,
      dateOfBirth: m['dob'] as String,
      expiryDate: m['expiry'] as String,
      attachmentPaths: _parseAttachments(m['attachment'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'passport_number': passportNumber,
      'name': name,
      'nationality': nationality,
      'dob': dateOfBirth,
      'expiry': expiryDate,
      'attachment': jsonEncode(attachmentPaths),
    };
  }
}

/// Driver’s license details
class DriverLicenseNote extends Note {
  final String licenseNumber;
  final String name;
  final String dateOfBirth;
  final String expiryDate;

  DriverLicenseNote({
    required int id,
    required this.licenseNumber,
    required this.name,
    required this.dateOfBirth,
    required this.expiryDate,
    required List<String> attachmentPaths,
  }) : super(id: id, type: NoteType.driverLicense, attachmentPaths: attachmentPaths);

  factory DriverLicenseNote.fromMap(Map<String, dynamic> m) {
    return DriverLicenseNote(
      id: m['id'] as int,
      licenseNumber: m['license_number'] as String,
      name: m['name'] as String,
      dateOfBirth: m['dob'] as String,
      expiryDate: m['expiry'] as String,
      attachmentPaths: _parseAttachments(m['attachment'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'license_number': licenseNumber,
      'name': name,
      'dob': dateOfBirth,
      'expiry': expiryDate,
      'attachment': jsonEncode(attachmentPaths),
    };
  }
}

/// Membership card details
class MembershipNote extends Note {
  final String clubName;
  final String membershipId;
  final String startDate;
  final String endDate;

  MembershipNote({
    required int id,
    required this.clubName,
    required this.membershipId,
    required this.startDate,
    required this.endDate,
    required List<String> attachmentPaths,
  }) : super(id: id, type: NoteType.membership, attachmentPaths: attachmentPaths);

  factory MembershipNote.fromMap(Map<String, dynamic> m) {
    return MembershipNote(
      id: m['id'] as int,
      clubName: m['club_name'] as String,
      membershipId: m['membership_id'] as String,
      startDate: m['start_date'] as String,
      endDate: m['end_date'] as String,
      attachmentPaths: _parseAttachments(m['attachment'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'club_name': clubName,
      'membership_id': membershipId,
      'start_date': startDate,
      'end_date': endDate,
      'attachment': jsonEncode(attachmentPaths),
    };
  }
}

/// Security question linked to a credential
class SecurityQuestionNote extends Note {
  final int credentialId;
  final String question, answer;
  final String? hint;

  SecurityQuestionNote({
    required int id,
    required this.credentialId,
    required this.question,
    required this.answer,
    this.hint,
    required List<String> attachmentPaths,
  }) : super(id: id, type: NoteType.securityQuestion, attachmentPaths: attachmentPaths);

  factory SecurityQuestionNote.fromMap(Map<String, dynamic> m) => SecurityQuestionNote(
    id: m['id'] as int,
    credentialId: m['credential_id'] as int,
    question: m['question'] as String,
    answer: m['answer'] as String,
    hint: m['hint'] as String?,
    attachmentPaths: _parseAttachments(m['attachment'] as String?),
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'credential_id': credentialId,
    'question': question,
    'answer': answer,
    'hint': hint,
    'attachment': jsonEncode(attachmentPaths),
  };
}

/// Software license details
class SoftwareLicenseNote extends Note {
  final String title;
  final String licenseKey;
  final String purchaseDate;
  final String? expiryDate;

  SoftwareLicenseNote({
    required int id,
    required this.title,
    required this.licenseKey,
    required this.purchaseDate,
    this.expiryDate,
    required List<String> attachmentPaths,
  }) : super(id: id, type: NoteType.softwareLicense, attachmentPaths: attachmentPaths);

  factory SoftwareLicenseNote.fromMap(Map<String, dynamic> m) {
    return SoftwareLicenseNote(
      id: m['id'] as int,
      title: m['title'] as String,
      licenseKey: m['license_key'] as String,
      purchaseDate: m['purchase_date'] as String,
      expiryDate: m['expiry_date'] as String?,
      attachmentPaths: _parseAttachments(m['attachment'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'license_key': licenseKey,
      'purchase_date': purchaseDate,
      'expiry_date': expiryDate,
      'attachment': jsonEncode(attachmentPaths),
    };
  }
}

/// Emergency contact details
class EmergencyContactNote extends Note {
  final String name;
  final String phone;
  final String relation;
  final String? notes;

  EmergencyContactNote({
    required int id,
    required this.name,
    required this.phone,
    required this.relation,
    this.notes,
    required List<String> attachmentPaths,
  }) : super(id: id, type: NoteType.emergencyContact, attachmentPaths: attachmentPaths);

  factory EmergencyContactNote.fromMap(Map<String, dynamic> m) {
    return EmergencyContactNote(
      id: m['id'] as int,
      name: m['name'] as String,
      phone: m['phone'] as String,
      relation: m['relation'] as String,
      notes: m['notes'] as String?,
      attachmentPaths: _parseAttachments(m['attachment'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'relation': relation,
      'notes': notes,
      'attachment': jsonEncode(attachmentPaths),
    };
  }
}

/// Generic free-form note
class GenericNote extends Note {
  final String title;
  final String description;

  GenericNote({
    required int id,
    required this.title,
    required this.description,
    required List<String> attachmentPaths,
  }) : super(id: id, type: NoteType.generic, attachmentPaths: attachmentPaths);

  factory GenericNote.fromMap(Map<String, dynamic> m) {
    return GenericNote(
      id: m['id'] as int,
      title: m['title'] as String,
      description: m['description'] as String,
      attachmentPaths: _parseAttachments(m['attachment'] as String?),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'attachment': jsonEncode(attachmentPaths),
    };
  }
}
