// lib/pages/add_edit_credential_page.dart

import 'dart:math';
import 'package:flutter/material.dart';
import '../models/credential.dart';
import '../db/credential_db.dart';
import '../constants/colors.dart';

class AddEditCredentialPage extends StatefulWidget {
  final Credential? credential;
  const AddEditCredentialPage({super.key, this.credential});

  @override
  State<AddEditCredentialPage> createState() => _AddEditCredentialPageState();
}

class _AddEditCredentialPageState extends State<AddEditCredentialPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _usernameCtrl;
  late TextEditingController _passwordCtrl;
  bool _obscurePassword = true;
  final _dbHelper = CredentialDbHelper();

  @override
  void initState() {
    super.initState();
    _titleCtrl    = TextEditingController(text: widget.credential?.title ?? '');
    _usernameCtrl = TextEditingController(text: widget.credential?.username ?? '');
    _passwordCtrl = TextEditingController(text: widget.credential?.password ?? '');
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final cred = Credential(
      id:       widget.credential?.id ?? 0,
      title:    _titleCtrl.text.trim(),
      username: _usernameCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
    if (widget.credential == null) {
      await _dbHelper.insertCredential(cred);
    } else {
      await _dbHelper.updateCredential(cred);
    }
    Navigator.pop(context, true);
  }

  void _openGenerator() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => PasswordGeneratorSheet(
        onGenerated: (pwd) => _passwordCtrl.text = pwd,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.credential != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Credential' : 'Add Credential'),
        backgroundColor: AppColors.primary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter title' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _usernameCtrl,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => v == null || v.isEmpty ? 'Enter username' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() => _obscurePassword = !_obscurePassword);
                          },
                          tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                        ),
                        IconButton(
                          icon: const Icon(Icons.autorenew),
                          onPressed: _openGenerator,
                          tooltip: 'Generate Password',
                        ),
                      ],
                    ),
                  ),
                  validator: (v) => v == null || v.isEmpty ? 'Enter password' : null,
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
              child: Text(isEditing ? 'Update' : 'Save'),
            ),
          ),
        ]),
      ),
    );
  }
}

class PasswordGeneratorSheet extends StatefulWidget {
  final void Function(String) onGenerated;
  const PasswordGeneratorSheet({super.key, required this.onGenerated});

  @override
  State<PasswordGeneratorSheet> createState() => _PasswordGeneratorSheetState();
}

class _PasswordGeneratorSheetState extends State<PasswordGeneratorSheet> {
  int _length = 16;
  bool _includeLower   = true;
  bool _includeUpper   = true;
  bool _includeNumbers = true;
  bool _includeSymbols = true;
  bool _easyToRead     = false;
  bool _easyToSay      = false;
  String _generated    = '';

  static const _lower     = 'abcdefghijklmnopqrstuvwxyz';
  static const _upper     = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  static const _numbers   = '0123456789';
  static const _symbols   = '!@#\$%^&*()-_=+[]{}|;:,.<>?';
  static const _ambiguous = 'il1Lo0O';

  @override
  void initState() {
    super.initState();
    _regenerate();
  }

  void _regenerate() {
    if (_easyToSay) {
      _generated = _generatePronounceable(_length);
    } else {
      var pool = StringBuffer();
      if (_includeLower)   pool.write(_lower);
      if (_includeUpper)   pool.write(_upper);
      if (_includeNumbers) pool.write(_numbers);
      if (_includeSymbols) pool.write(_symbols);

      var chars = pool.toString();
      if (_easyToRead) {
        chars = chars.replaceAll(
          RegExp('[' + RegExp.escape(_ambiguous) + ']'),
          '',
        );
      }

      if (chars.isEmpty) {
        _generated = '';
      } else {
        final rng = Random.secure();
        _generated = List.generate(
          _length,
              (_) => chars[rng.nextInt(chars.length)],
        ).join();
      }
    }
    setState(() {});
  }

  String _generatePronounceable(int length) {
    const vowels = 'aeiou';
    const consonants = 'bcdfghjklmnpqrstvwxyz';
    final rng = Random.secure();
    final sb = StringBuffer();
    bool pickConsonant = true;
    for (var i = 0; i < length; i++) {
      sb.write(
          pickConsonant
              ? consonants[rng.nextInt(consonants.length)]
              : vowels[rng.nextInt(vowels.length)]
      );
      pickConsonant = !pickConsonant;
    }
    return sb.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 16, left: 16, right: 16,
      ),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Generate Password',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SelectableText(
          _generated,
          style: const TextStyle(fontSize: 16, color: Colors.white),
        ),
        Slider(
          min: 8,
          max: 64,
          divisions: 56,
          label: 'Length: $_length',
          value: _length.toDouble(),
          onChanged: (v) {
            _length = v.round();
            _regenerate();
          },
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: [
          FilterChip(
            label: const Text('Lowercase'),
            selected: _includeLower,
            onSelected: _easyToSay ? null : (v) {
              _includeLower = v;
              _regenerate();
            },
          ),
          FilterChip(
            label: const Text('Uppercase'),
            selected: _includeUpper,
            onSelected: _easyToSay ? null : (v) {
              _includeUpper = v;
              _regenerate();
            },
          ),
          FilterChip(
            label: const Text('Numbers'),
            selected: _includeNumbers,
            onSelected: _easyToSay ? null : (v) {
              _includeNumbers = v;
              _regenerate();
            },
          ),
          FilterChip(
            label: const Text('Symbols'),
            selected: _includeSymbols,
            onSelected: _easyToSay ? null : (v) {
              _includeSymbols = v;
              _regenerate();
            },
          ),
        ]),
        const Divider(color: Colors.grey, height: 32),
        SwitchListTile(
          title: const Text('Easy to Read'),
          subtitle: Text('Remove ambiguous chars (${_ambiguous.split('').join(', ')})'),
          value: _easyToRead,
          onChanged: (v) {
            _easyToRead = v;
            if (v && _easyToSay) _easyToSay = false;
            _regenerate();
          },
          activeColor: AppColors.primary,
        ),
        SwitchListTile(
          title: const Text('Easy to Say'),
          subtitle: const Text('Pronounceable password (letters only)'),
          value: _easyToSay,
          onChanged: (v) {
            _easyToSay = v;
            if (v) {
              _includeNumbers = false;
              _includeSymbols = false;
            }
            _regenerate();
          },
          activeColor: AppColors.accent,
        ),
        const SizedBox(height: 16),
        Row(children: [
          ElevatedButton(onPressed: _regenerate, child: const Text('Regenerate')),
          const SizedBox(width: 16),
          ElevatedButton(
            onPressed: () {
              if (_generated.isNotEmpty) {
                widget.onGenerated(_generated);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: const Text('Use Password'),
          ),
        ]),
        const SizedBox(height: 16),
      ]),
    );
  }
}
