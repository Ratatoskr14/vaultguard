// lib/widgets/note_card.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/note.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';

class NoteCard extends StatefulWidget {
  final Note note;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const NoteCard({
    super.key,
    required this.note,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  bool _obscured = true;

  String get _displayValue {
    final n = widget.note;
    switch (n.type) {
      case NoteType.wifi:
        return (n as WifiNote).password;
      case NoteType.passport:
        return (n as PassportNote).passportNumber;
      case NoteType.driverLicense:
        return (n as DriverLicenseNote).licenseNumber;
      case NoteType.membership:
        return (n as MembershipNote).membershipId;
      case NoteType.securityQuestion:
        return (n as SecurityQuestionNote).answer;
      case NoteType.softwareLicense:
        return (n as SoftwareLicenseNote).licenseKey;
      case NoteType.emergencyContact:
        return (n as EmergencyContactNote).phone;
      case NoteType.generic:
        return (n as GenericNote).description;
    }
  }

  String get _titleText {
    final n = widget.note;
    switch (n.type) {
      case NoteType.wifi:
        return (n as WifiNote).ssid;
      case NoteType.passport:
        return (n as PassportNote).name;
      case NoteType.driverLicense:
        return (n as DriverLicenseNote).name;
      case NoteType.membership:
        return (n as MembershipNote).clubName;
      case NoteType.securityQuestion:
        return (n as SecurityQuestionNote).question;
      case NoteType.softwareLicense:
        return (n as SoftwareLicenseNote).title;
      case NoteType.emergencyContact:
        return (n as EmergencyContactNote).name;
      case NoteType.generic:
        return (n as GenericNote).title;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(_titleText, style: AppFonts.heading),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _obscured
                  ? '••••••••'
                  : _displayValue,
              style: AppFonts.body,
            ),
          ],
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          IconButton(
            icon:
            Icon(_obscured ? Icons.visibility : Icons.visibility_off),
            onPressed: () =>
                setState(() => _obscured = !_obscured),
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(
                  ClipboardData(text: _displayValue));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Copied to clipboard')),
              );
            },
          ),
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'edit') widget.onEdit();
              if (val == 'delete') {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Note'),
                    content: const Text(
                        'Are you sure you want to delete this note?'),
                    actions: [
                      TextButton(
                          onPressed: () =>
                              Navigator.pop(context),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            widget.onDelete();
                          },
                          child: const Text('Delete')),
                    ],
                  ),
                );
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: 'edit', child: Text('Edit')),
              PopupMenuItem(value: 'delete', child: Text('Delete')),
            ],
          ),
        ]),
      ),
    );
  }
}
