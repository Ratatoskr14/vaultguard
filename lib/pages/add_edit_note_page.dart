// lib/pages/add_edit_note_page.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constants/colors.dart';
import '../db/credential_db.dart';
import '../db/note_db.dart';
import '../models/credential.dart';
import '../models/note.dart';

class AddEditNotePage extends StatefulWidget {
  final NoteType type;
  final Note? note;
  const AddEditNotePage({
    Key? key,
    required this.type,
    this.note,
  }) : super(key: key);

  @override
  State<AddEditNotePage> createState() => _AddEditNotePageState();
}

class _AddEditNotePageState extends State<AddEditNotePage> {
  final _formKey = GlobalKey<FormState>();
  final _db       = NoteDbHelper();
  final _picker   = ImagePicker();

  late NoteType _currentType;
  List<Credential> _creds = [];
  List<String>     _attachments = [];

  int? _linkedCredentialId;

  // Controllers
  late TextEditingController
  _ssidCtrl, _wifiPwdCtrl,
      _numberCtrl, _nameCtrl, _nationalityCtrl, _dobCtrl, _expiryCtrl,
      _clubCtrl, _memberIdCtrl, _startCtrl, _endCtrl,
      _questionCtrl, _answerCtrl, _hintCtrl,
      _licenseTitleCtrl, _licenseKeyCtrl, _purchaseCtrl, _licenseExpiryCtrl,
      _contactNameCtrl, _phoneCtrl, _relationCtrl, _notesCtrl,
      _titleCtrl, _descCtrl;

  @override
  void initState() {
    super.initState();
    _currentType = widget.type;

    // init controllers
    _ssidCtrl         = TextEditingController();
    _wifiPwdCtrl      = TextEditingController();
    _numberCtrl       = TextEditingController();
    _nameCtrl         = TextEditingController();
    _nationalityCtrl  = TextEditingController();
    _dobCtrl          = TextEditingController();
    _expiryCtrl       = TextEditingController();
    _clubCtrl         = TextEditingController();
    _memberIdCtrl     = TextEditingController();
    _startCtrl        = TextEditingController();
    _endCtrl          = TextEditingController();
    _questionCtrl     = TextEditingController();
    _answerCtrl       = TextEditingController();
    _hintCtrl         = TextEditingController();
    _licenseTitleCtrl = TextEditingController();
    _licenseKeyCtrl   = TextEditingController();
    _purchaseCtrl     = TextEditingController();
    _licenseExpiryCtrl= TextEditingController();
    _contactNameCtrl  = TextEditingController();
    _phoneCtrl        = TextEditingController();
    _relationCtrl     = TextEditingController();
    _notesCtrl        = TextEditingController();
    _titleCtrl        = TextEditingController();
    _descCtrl         = TextEditingController();

    // load credentials for security questions
    CredentialDbHelper().getCredentials().then((list) {
      setState(() => _creds = list);
    });

    // if editing, load values and attachments
    if (widget.note != null) _loadExisting();
  }

  void _loadExisting() {
    final n = widget.note!;
    _currentType = n.type;
    // now using attachmentPaths field on each Note subclass
    _attachments    = List<String>.from(n.attachmentPaths);

    switch (n.type) {
      case NoteType.wifi:
        final w = n as WifiNote;
        _ssidCtrl.text    = w.ssid;
        _wifiPwdCtrl.text = w.password;
        break;
      case NoteType.passport:
        final p = n as PassportNote;
        _numberCtrl.text      = p.passportNumber;
        _nameCtrl.text        = p.name;
        _nationalityCtrl.text = p.nationality;
        _dobCtrl.text         = p.dateOfBirth;
        _expiryCtrl.text      = p.expiryDate;
        break;
      case NoteType.driverLicense:
        final d = n as DriverLicenseNote;
        _numberCtrl.text = d.licenseNumber;
        _nameCtrl.text   = d.name;
        _dobCtrl.text    = d.dateOfBirth;
        _expiryCtrl.text = d.expiryDate;
        break;
      case NoteType.membership:
        final m = n as MembershipNote;
        _clubCtrl.text       = m.clubName;
        _memberIdCtrl.text   = m.membershipId;
        _startCtrl.text      = m.startDate;
        _endCtrl.text        = m.endDate;
        break;
      case NoteType.securityQuestion:
        final s = n as SecurityQuestionNote;
        _linkedCredentialId = s.credentialId;
        _questionCtrl.text  = s.question;
        _answerCtrl.text    = s.answer;
        _hintCtrl.text      = s.hint ?? '';
        break;
      case NoteType.softwareLicense:
        final s = n as SoftwareLicenseNote;
        _licenseTitleCtrl.text  = s.title;
        _licenseKeyCtrl.text    = s.licenseKey;
        _purchaseCtrl.text      = s.purchaseDate;
        _licenseExpiryCtrl.text = s.expiryDate ?? '';
        break;
      case NoteType.emergencyContact:
        final e = n as EmergencyContactNote;
        _contactNameCtrl.text = e.name;
        _phoneCtrl.text       = e.phone;
        _relationCtrl.text    = e.relation;
        _notesCtrl.text       = e.notes ?? '';
        break;
      case NoteType.generic:
        final g = n as GenericNote;
        _titleCtrl.text = g.title;
        _descCtrl.text  = g.description;
        break;
    }
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage();
    if (files != null) {
      setState(() {
        _attachments.addAll(files.map((f) => f.path));
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final attachJson = jsonEncode(_attachments);

    switch (_currentType) {
      case NoteType.wifi:
        final w = WifiNote(
          id:              widget.note?.id ?? 0,
          ssid:            _ssidCtrl.text.trim(),
          password:        _wifiPwdCtrl.text,
          attachmentPaths: _attachments,
        );
        widget.note == null
            ? await _db.insertWifi(w)
            : await _db.updateWifi(w);
        break;

      case NoteType.passport:
        final p = PassportNote(
          id:              widget.note?.id ?? 0,
          passportNumber:  _numberCtrl.text.trim(),
          name:            _nameCtrl.text.trim(),
          nationality:     _nationalityCtrl.text.trim(),
          dateOfBirth:     _dobCtrl.text.trim(),
          expiryDate:      _expiryCtrl.text.trim(),
          attachmentPaths: _attachments,
        );
        widget.note == null
            ? await _db.insertPassport(p)
            : await _db.updatePassport(p);
        break;

      case NoteType.driverLicense:
        final d = DriverLicenseNote(
          id:              widget.note?.id ?? 0,
          licenseNumber:   _numberCtrl.text.trim(),
          name:            _nameCtrl.text.trim(),
          dateOfBirth:     _dobCtrl.text.trim(),
          expiryDate:      _expiryCtrl.text.trim(),
          attachmentPaths: _attachments,
        );
        widget.note == null
            ? await _db.insertDriverLicense(d)
            : await _db.updateDriverLicense(d);
        break;

      case NoteType.membership:
        final m = MembershipNote(
          id:              widget.note?.id ?? 0,
          clubName:        _clubCtrl.text.trim(),
          membershipId:    _memberIdCtrl.text.trim(),
          startDate:       _startCtrl.text.trim(),
          endDate:         _endCtrl.text.trim(),
          attachmentPaths: _attachments,
        );
        widget.note == null
            ? await _db.insertMembership(m)
            : await _db.updateMembership(m);
        break;

      case NoteType.securityQuestion:
        final s = SecurityQuestionNote(
          id:              widget.note?.id ?? 0,
          credentialId:    _linkedCredentialId!,
          question:        _questionCtrl.text.trim(),
          answer:          _answerCtrl.text.trim(),
          hint:            _hintCtrl.text.trim(),
          attachmentPaths: _attachments,
        );
        widget.note == null
            ? await _db.insertSecurityQuestion(s)
            : await _db.updateSecurityQuestion(s);
        break;

      case NoteType.softwareLicense:
        final s = SoftwareLicenseNote(
          id:              widget.note?.id ?? 0,
          title:           _licenseTitleCtrl.text.trim(),
          licenseKey:      _licenseKeyCtrl.text.trim(),
          purchaseDate:    _purchaseCtrl.text.trim(),
          expiryDate:      _licenseExpiryCtrl.text.trim().isEmpty
              ? null
              : _licenseExpiryCtrl.text.trim(),
          attachmentPaths: _attachments,
        );
        widget.note == null
            ? await _db.insertSoftwareLicense(s)
            : await _db.updateSoftwareLicense(s);
        break;

      case NoteType.emergencyContact:
        final e = EmergencyContactNote(
          id:              widget.note?.id ?? 0,
          name:            _contactNameCtrl.text.trim(),
          phone:           _phoneCtrl.text.trim(),
          relation:        _relationCtrl.text.trim(),
          notes:           _notesCtrl.text.trim(),
          attachmentPaths: _attachments,
        );
        widget.note == null
            ? await _db.insertEmergencyContact(e)
            : await _db.updateEmergencyContact(e);
        break;

      case NoteType.generic:
        final g = GenericNote(
          id:              widget.note?.id ?? 0,
          title:           _titleCtrl.text.trim(),
          description:     _descCtrl.text.trim(),
          attachmentPaths: _attachments,
        );
        widget.note == null
            ? await _db.insertGeneric(g)
            : await _db.updateGeneric(g);
        break;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.note != null;
    final titleText = isEdit
        ? 'Edit ${describeEnum(_currentType).replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}').trim()}'
        : 'Add  ${describeEnum(_currentType).replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}').trim()}';

    return Scaffold(
      appBar: AppBar(
        title: Text(titleText),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!isEdit) ...[
                DropdownButtonFormField<NoteType>(
                  value: _currentType,
                  decoration: const InputDecoration(labelText: 'Note Type'),
                  items: NoteType.values.map((t) {
                    final label = describeEnum(t)
                        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
                        .trim();
                    return DropdownMenuItem(value: t, child: Text(label));
                  }).toList(),
                  onChanged: (t) {
                    if (t != null) setState(() => _currentType = t);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // wifi
              if (_currentType == NoteType.wifi) ...[
                TextFormField(
                  controller: _ssidCtrl,
                  decoration: const InputDecoration(labelText: 'SSID'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _wifiPwdCtrl,
                  decoration: const InputDecoration(labelText: 'Password'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
              ],

              // passport
              if (_currentType == NoteType.passport) ...[
                TextFormField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(labelText: 'Passport Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextFormField(controller: _nationalityCtrl, decoration: const InputDecoration(labelText: 'Nationality')),
                const SizedBox(height: 12),
                TextFormField(controller: _dobCtrl, decoration: const InputDecoration(labelText: 'Date of Birth')),
                const SizedBox(height: 12),
                TextFormField(controller: _expiryCtrl, decoration: const InputDecoration(labelText: 'Expiry Date')),
              ],

              // driver license
              if (_currentType == NoteType.driverLicense) ...[
                TextFormField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(labelText: 'License Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextFormField(controller: _dobCtrl, decoration: const InputDecoration(labelText: 'Date of Birth')),
                const SizedBox(height: 12),
                TextFormField(controller: _expiryCtrl, decoration: const InputDecoration(labelText: 'Expiry Date')),
              ],

              // membership
              if (_currentType == NoteType.membership) ...[
                TextFormField(controller: _clubCtrl, decoration: const InputDecoration(labelText: 'Club Name')),
                const SizedBox(height: 12),
                TextFormField(controller: _memberIdCtrl, decoration: const InputDecoration(labelText: 'Membership ID')),
                const SizedBox(height: 12),
                TextFormField(controller: _startCtrl, decoration: const InputDecoration(labelText: 'Start Date')),
                const SizedBox(height: 12),
                TextFormField(controller: _endCtrl, decoration: const InputDecoration(labelText: 'End Date')),
              ],

              // security question
              if (_currentType == NoteType.securityQuestion) ...[
                DropdownButtonFormField<int>(
                  decoration: const InputDecoration(labelText: 'Link Password'),
                  items: _creds.map((c) => DropdownMenuItem(value: c.id, child: Text(c.title))).toList(),
                  onChanged: (v) => _linkedCredentialId = v,
                  value: _linkedCredentialId,
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(controller: _questionCtrl, decoration: const InputDecoration(labelText: 'Question'), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _answerCtrl, decoration: const InputDecoration(labelText: 'Answer'), validator: (v) => v!.isEmpty ? 'Required' : null),
                const SizedBox(height: 12),
                TextFormField(controller: _hintCtrl, decoration: const InputDecoration(labelText: 'Hint')),
              ],

              // software license
              if (_currentType == NoteType.softwareLicense) ...[
                TextFormField(controller: _licenseTitleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                TextFormField(controller: _licenseKeyCtrl, decoration: const InputDecoration(labelText: 'License Key')),
                const SizedBox(height: 12),
                TextFormField(controller: _purchaseCtrl, decoration: const InputDecoration(labelText: 'Purchase Date')),
                const SizedBox(height: 12),
                TextFormField(controller: _licenseExpiryCtrl, decoration: const InputDecoration(labelText: 'Expiry Date')),
              ],

              // emergency contact
              if (_currentType == NoteType.emergencyContact) ...[
                TextFormField(controller: _contactNameCtrl, decoration: const InputDecoration(labelText: 'Name')),
                const SizedBox(height: 12),
                TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone')),
                const SizedBox(height: 12),
                TextFormField(controller: _relationCtrl, decoration: const InputDecoration(labelText: 'Relation')),
                const SizedBox(height: 12),
                TextFormField(controller: _notesCtrl, decoration: const InputDecoration(labelText: 'Notes')),
              ],

              // generic
              if (_currentType == NoteType.generic) ...[
                TextFormField(controller: _titleCtrl, decoration: const InputDecoration(labelText: 'Title')),
                const SizedBox(height: 12),
                TextFormField(controller: _descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 4),
              ],

              const SizedBox(height: 24),

              // Thumbnails
              if (_attachments.isNotEmpty)
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _attachments.map((path) {
                    return Stack(
                      children: [
                        Container(
                          width: 80, height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(8),
                            image: DecorationImage(
                              image: FileImage(File(path)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 2, right: 2,
                          child: GestureDetector(
                            onTap: () => setState(() => _attachments.remove(path)),
                            child: CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: const Icon(Icons.close, size: 14),
                            ),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),

              const SizedBox(height: 12),
              ElevatedButton.icon(
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach Images'),
                onPressed: _pickImages,
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEdit ? 'Update' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}