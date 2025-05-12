import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/credential.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';

class CredentialCard extends StatefulWidget {
  final Credential credential;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const CredentialCard({
    super.key,
    required this.credential,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  State<CredentialCard> createState() => _CredentialCardState();
}

class _CredentialCardState extends State<CredentialCard> {
  bool _obscured = true;

  @override
  Widget build(BuildContext context) {
    final cred = widget.credential;
    return Card(
      color: AppColors.surface,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(cred.title, style: AppFonts.heading),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(cred.username, style: AppFonts.body),
            const SizedBox(height: 4),
            Text(_obscured ? '••••••••' : cred.password, style: AppFonts.body),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _obscured = !_obscured),
            ),
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: () {
                Clipboard.setData(ClipboardData(text: cred.password));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password copied')),
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
                      title: const Text('Delete Credential'),
                      content: const Text('Are you sure you want to delete this credential?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                        TextButton(onPressed: () {
                          Navigator.pop(context);
                          widget.onDelete();
                        }, child: const Text('Delete')),
                      ],
                    ),
                  );
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                const PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}