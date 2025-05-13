// lib/pages/add_edit_card_page.dart

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../constants/colors.dart';
import '../db/card_db.dart';
import '../models/card.dart';

/// Groups digits in 4s: "42424242" → "4242 4242"
class CardNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      buffer.write(digits[i]);
      final next = i + 1;
      if (next % 4 == 0 && next != digits.length && next < 16) {
        buffer.write(' ');
      }
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

/// Forces MM/YY and auto-inserts “/”
class ExpiryDateInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (digits.length > 4) digits = digits.substring(0, 4);
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

class AddEditCardPage extends StatefulWidget {
  final CardType type;
  final CardBase? card;
  const AddEditCardPage({
    Key? key,
    required this.type,
    this.card,
  }) : super(key: key);

  @override
  State<AddEditCardPage> createState() => _AddEditCardPageState();
}

class _AddEditCardPageState extends State<AddEditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _db       = CardDbHelper();
  final _picker   = ImagePicker();

  late CardType _currentType;
  List<String>  _attachments = [];

  // --- PaymentCard fields ---
  late TextEditingController _holderNameCtrl;
  late TextEditingController _cardNumberCtrl;
  late TextEditingController _expiryCtrl;
  late TextEditingController _cvvCtrl;
  bool _obscureCvv = true;

  // --- IDCard fields ---
  late TextEditingController _cardTypeCtrl;
  late TextEditingController _idNumberCtrl;
  late TextEditingController _nameCtrl;
  late TextEditingController _issuingAuthorityCtrl;
  late TextEditingController _expiry2Ctrl;

  // --- DriverLicenseCard fields ---
  late TextEditingController _licenseNumberCtrl;
  late TextEditingController _name2Ctrl;
  late TextEditingController _dobCtrl;
  late TextEditingController _expiry3Ctrl;
  late TextEditingController _issuingStateCtrl;

  // --- GiftCard fields ---
  late TextEditingController _giftNameCtrl;
  late TextEditingController _giftNumberCtrl;
  late TextEditingController _giftExpiryCtrl;

  // --- MiscCard fields ---
  late TextEditingController _miscTitleCtrl;
  late TextEditingController _miscDetailsCtrl;

  @override
  void initState() {
    super.initState();
    _currentType = widget.type;

    _holderNameCtrl       = TextEditingController();
    _cardNumberCtrl       = TextEditingController()..addListener(() => setState(() {}));
    _expiryCtrl           = TextEditingController();
    _cvvCtrl              = TextEditingController();

    _cardTypeCtrl         = TextEditingController();
    _idNumberCtrl         = TextEditingController();
    _nameCtrl             = TextEditingController();
    _issuingAuthorityCtrl = TextEditingController();
    _expiry2Ctrl          = TextEditingController();

    _licenseNumberCtrl    = TextEditingController();
    _name2Ctrl            = TextEditingController();
    _dobCtrl              = TextEditingController();
    _expiry3Ctrl          = TextEditingController();
    _issuingStateCtrl     = TextEditingController();

    _giftNameCtrl         = TextEditingController();
    _giftNumberCtrl       = TextEditingController();
    _giftExpiryCtrl       = TextEditingController();

    _miscTitleCtrl        = TextEditingController();
    _miscDetailsCtrl      = TextEditingController();

    if (widget.card != null) _loadExisting();
  }

  void _loadExisting() {
    final c = widget.card!;
    _currentType = c.type;
    _attachments = List.from(c.attachmentPaths);

    switch (c.type) {
      case CardType.payment:
        final p = c as PaymentCard;
        _holderNameCtrl.text = p.cardholderName;
        _cardNumberCtrl.text = p.cardNumber;
        _expiryCtrl.text     = p.expiryDate;
        _cvvCtrl.text        = p.cvv;
        break;
      case CardType.id:
        final i = c as IDCard;
        _cardTypeCtrl.text         = i.cardType;
        _idNumberCtrl.text         = i.idNumber;
        _nameCtrl.text             = i.name;
        _issuingAuthorityCtrl.text = i.issuingAuthority;
        _expiry2Ctrl.text          = i.expiryDate;
        break;
      case CardType.driverLicense:
        final d = c as DriverLicenseCard;
        _licenseNumberCtrl.text = d.licenseNumber;
        _name2Ctrl.text         = d.name;
        _dobCtrl.text           = d.dob;
        _expiry3Ctrl.text       = d.expiryDate;
        _issuingStateCtrl.text  = d.issuingState;
        break;
      case CardType.gift:
        final g = c as GiftCard;
        _giftNameCtrl.text   = g.cardName;
        _giftNumberCtrl.text = g.cardNumber;
        _giftExpiryCtrl.text = g.expiryDate;
        break;
      case CardType.misc:
        final m = c as MiscCard;
        _miscTitleCtrl.text   = m.title;
        _miscDetailsCtrl.text = m.details;
        break;
    }
  }

  Future<void> _pickImages() async {
    final files = await _picker.pickMultiImage();
    if (files != null) {
      setState(() => _attachments.addAll(files.map((f) => f.path)));
    }
  }

  String _detectNetwork(String text) {
    final num = text.replaceAll(' ', '');
    if (num.startsWith('4')) return 'visa';
    if (RegExp(r'^5[1-5]').hasMatch(num)) return 'mastercard';
    return '';
  }

  Widget? get _networkIcon {
    final net = _detectNetwork(_cardNumberCtrl.text);
    if (net == 'visa') {
      return Icon(FontAwesomeIcons.ccVisa, size: 28);
    } else if (net == 'mastercard') {
      return Icon(FontAwesomeIcons.ccMastercard, size: 28);
    }
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    switch (_currentType) {
      case CardType.payment:
        final p = PaymentCard(
          id:              widget.card?.id ?? 0,
          cardholderName:  _holderNameCtrl.text.trim(),
          cardNumber:      _cardNumberCtrl.text.trim(),
          expiryDate:      _expiryCtrl.text.trim(),
          cvv:             _cvvCtrl.text.trim(),
          attachmentPaths: _attachments,
        );
        widget.card == null
            ? await _db.insertPayment(p)
            : await _db.updatePayment(p);
        break;
      case CardType.id:
        final i = IDCard(
          id:               widget.card?.id ?? 0,
          cardType:         _cardTypeCtrl.text.trim(),
          idNumber:         _idNumberCtrl.text.trim(),
          name:             _nameCtrl.text.trim(),
          issuingAuthority: _issuingAuthorityCtrl.text.trim(),
          expiryDate:       _expiry2Ctrl.text.trim(),
          attachmentPaths:  _attachments,
        );
        widget.card == null
            ? await _db.insertID(i)
            : await _db.updateID(i);
        break;
      case CardType.driverLicense:
        final d = DriverLicenseCard(
          id:              widget.card?.id ?? 0,
          licenseNumber:   _licenseNumberCtrl.text.trim(),
          name:             _name2Ctrl.text.trim(),
          dob:               _dobCtrl.text.trim(),
          expiryDate:        _expiry3Ctrl.text.trim(),
          issuingState:      _issuingStateCtrl.text.trim(),
          attachmentPaths:   _attachments,
        );
        widget.card == null
            ? await _db.insertDriverLicense(d)
            : await _db.updateDriverLicense(d);
        break;
      case CardType.gift:
        final g = GiftCard(
          id:               widget.card?.id ?? 0,
          cardName:         _giftNameCtrl.text.trim(),
          cardNumber:       _giftNumberCtrl.text.trim(),
          expiryDate:       _giftExpiryCtrl.text.trim(),
          attachmentPaths:  _attachments,
        );
        widget.card == null
            ? await _db.insertGiftCard(g)
            : await _db.updateGiftCard(g);
        break;
      case CardType.misc:
        final m = MiscCard(
          id:               widget.card?.id ?? 0,
          title:            _miscTitleCtrl.text.trim(),
          details:          _miscDetailsCtrl.text.trim(),
          attachmentPaths:  _attachments,
        );
        widget.card == null
            ? await _db.insertMiscCard(m)
            : await _db.updateMiscCard(m);
        break;
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.card != null;
    final label = _currentType
        .toString()
        .split('.')
        .last
        .replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
        .trim();

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit $label' : 'Add $label'),
        backgroundColor: AppColors.surface,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!isEdit) ...[
                DropdownButtonFormField<CardType>(
                  value: _currentType,
                  decoration: const InputDecoration(labelText: 'Card Type'),
                  items: CardType.values.map((t) {
                    final txt = t.toString().split('.').last
                        .replaceAllMapped(
                        RegExp(r'([A-Z])'), (m) => ' ${m[0]}')
                        .trim();
                    return DropdownMenuItem(value: t, child: Text(txt));
                  }).toList(),
                  onChanged: (t) {
                    if (t != null) setState(() => _currentType = t);
                  },
                ),
                const SizedBox(height: 16),
              ],

              // ==== PAYMENT CARD ====
              if (_currentType == CardType.payment) ...[
                TextFormField(
                  controller: _holderNameCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Cardholder Name'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cardNumberCtrl,
                  decoration: InputDecoration(
                    labelText: 'Card Number',
                    suffixIcon: _networkIcon,
                    suffixIconConstraints:
                    const BoxConstraints(minWidth: 48, minHeight: 48),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(19),
                    CardNumberInputFormatter(),
                  ],
                  validator: (v) {
                    final num = v!.replaceAll(' ', '');
                    if (num.length != 16) return 'Enter 16 digits';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _expiryCtrl,
                  decoration: const InputDecoration(labelText: 'Expiry (MM/YY)'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(5),
                    ExpiryDateInputFormatter(),
                  ],
                  validator: (v) {
                    if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(v!))
                      return 'Invalid format';
                    final mm = int.tryParse(v.split('/')[0]) ?? 0;
                    if (mm < 1 || mm > 12) return 'Invalid month';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _cvvCtrl,
                  decoration: InputDecoration(
                    labelText: 'CVV',
                    suffixIcon: IconButton(
                      icon: Icon(
                          _obscureCvv ? Icons.visibility : Icons.visibility_off),
                      onPressed: () =>
                          setState(() => _obscureCvv = !_obscureCvv),
                    ),
                  ),
                  obscureText: _obscureCvv,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (v) => v!.length != 3 ? 'Enter 3 digits' : null,
                ),
              ],

              // ==== ID CARD ====
              if (_currentType == CardType.id) ...[
                TextFormField(
                  controller: _cardTypeCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Card Type (e.g. Aadhaar)'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _idNumberCtrl,
                  decoration: const InputDecoration(labelText: 'ID Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _issuingAuthorityCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Issuing Authority'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _expiry2Ctrl,
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                ),
              ],

              // ==== DRIVER LICENSE CARD ====
              if (_currentType == CardType.driverLicense) ...[
                TextFormField(
                  controller: _licenseNumberCtrl,
                  decoration:
                  const InputDecoration(labelText: 'License Number'),
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _name2Ctrl,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _dobCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Date of Birth'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _expiry3Ctrl,
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _issuingStateCtrl,
                  decoration:
                  const InputDecoration(labelText: 'Issuing State'),
                ),
              ],

              // ==== GIFT CARD ====
              if (_currentType == CardType.gift) ...[
                TextFormField(
                  controller: _giftNameCtrl,
                  decoration: const InputDecoration(labelText: 'Card Name'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _giftNumberCtrl,
                  decoration: const InputDecoration(labelText: 'Card Number'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _giftExpiryCtrl,
                  decoration: const InputDecoration(labelText: 'Expiry Date'),
                ),
              ],

              // ==== MISC CARD ====
              if (_currentType == CardType.misc) ...[
                TextFormField(
                  controller: _miscTitleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _miscDetailsCtrl,
                  decoration: const InputDecoration(labelText: 'Details'),
                  maxLines: 4,
                ),
              ],

              const SizedBox(height: 24),

              // Attachments thumbnails
              if (_attachments.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _attachments.map((path) {
                    return Stack(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
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
                          top: 2,
                          right: 2,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => _attachments.remove(path)),
                            child: const CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.black54,
                              child: Icon(Icons.close,
                                  size: 14, color: Colors.white),
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
