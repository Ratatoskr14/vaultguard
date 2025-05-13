import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/card.dart';
import '../constants/colors.dart';
import '../constants/fonts.dart';

class CardCard extends StatefulWidget {
  final CardBase card;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const CardCard({
    Key? key,
    required this.card,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  State<CardCard> createState() => _CardCardState();
}

class _CardCardState extends State<CardCard> {
  bool _obscured = true;

  String get _title {
    final c = widget.card;
    switch (c.type) {
      case CardType.payment:
        return (c as PaymentCard).cardholderName;
      case CardType.id:
        return (c as IDCard).cardType;
      case CardType.driverLicense:
        return (c as DriverLicenseCard).name;
      case CardType.gift:
        return (c as GiftCard).cardName;
      case CardType.misc:
        return (c as MiscCard).title;
    }
  }

  String get _value {
    final c = widget.card;
    switch (c.type) {
      case CardType.payment:
        return (c as PaymentCard).cardNumber;
      case CardType.id:
        return (c as IDCard).idNumber;
      case CardType.driverLicense:
        return (c as DriverLicenseCard).licenseNumber;
      case CardType.gift:
        return (c as GiftCard).cardNumber;
      case CardType.misc:
        return (c as MiscCard).details;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.card,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(_title, style: AppFonts.heading),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _obscured ? '••••••••' : _value,
              style: AppFonts.body,
            ),
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
                Clipboard.setData(ClipboardData(text: _value));
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
                      title: const Text('Delete Card'),
                      content: const Text('Are you sure you want to delete this card?'),
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
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
