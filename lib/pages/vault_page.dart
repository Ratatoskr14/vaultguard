// lib/pages/vault_page.dart

import 'package:flutter/material.dart';
import '../constants/colors.dart';

// existing
import '../db/credential_db.dart';
import '../db/note_db.dart';
import '../models/credential.dart';
import '../models/note.dart';
import '../widgets/credential_card.dart';
import '../widgets/note_card.dart';
import 'add_edit_credential_page.dart';
import 'add_edit_note_page.dart';

// new for cards
import '../db/card_db.dart';
import '../models/card.dart';
import '../widgets/card_card.dart';
import 'add_edit_card_page.dart';

import 'settings_page.dart';

enum Category { all, passwords, notes, cards }
enum AddOption { password, note, card }

class VaultPage extends StatefulWidget {
  static const routeName = '/vault';
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  // existing DB helpers
  final _credDb = CredentialDbHelper();
  final _noteDb = NoteDbHelper();
  // new card helper
  final _cardDb = CardDbHelper();

  late Future<List<Credential>> _credentialList;
  late Future<List<Note>>       _noteList;
  late Future<List<CardBase>>   _cardList;

  Category _selectedCategory = Category.all;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _credentialList = _credDb.getCredentials();
    _noteList = Future.wait<List<Note>>([
      _noteDb.getWifiNotes(),
      _noteDb.getPassportNotes(),
      _noteDb.getDriverLicenses(),
      _noteDb.getMemberships(),
      _noteDb.getSecurityQuestions(),
      _noteDb.getSoftwareLicenses(),
      _noteDb.getEmergencyContacts(),
      _noteDb.getGenericNotes(),
    ]).then((lists) => lists.expand((l) => l).toList());
    _cardList = Future.wait<List<CardBase>>([
      _cardDb.getPaymentCards(),
      _cardDb.getIDCards(),
      _cardDb.getDriverLicenseCards(),
      _cardDb.getGiftCards(),
      _cardDb.getMiscCards(),
    ]).then((lists) => lists.expand((l) => l).toList());
  }

  // Credentials
  Future<void> _onDeleteCredential(int id) async {
    await _credDb.deleteCredential(id);
    setState(_loadData);
  }
  Future<void> _onEditCredential(Credential c) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => AddEditCredentialPage(credential: c),
      ),
    );
    if (ok == true) setState(_loadData);
  }

  // Notes
  Future<void> _onDeleteNote(Note n) async {
    switch (n.type) {
      case NoteType.wifi:            await _noteDb.deleteWifi(n.id); break;
      case NoteType.passport:        await _noteDb.deletePassport(n.id); break;
      case NoteType.driverLicense:   await _noteDb.deleteDriverLicense(n.id); break;
      case NoteType.membership:      await _noteDb.deleteMembership(n.id); break;
      case NoteType.securityQuestion:await _noteDb.deleteSecurityQuestion(n.id); break;
      case NoteType.softwareLicense: await _noteDb.deleteSoftwareLicense(n.id); break;
      case NoteType.emergencyContact:await _noteDb.deleteEmergencyContact(n.id); break;
      case NoteType.generic:         await _noteDb.deleteGeneric(n.id); break;
    }
    setState(_loadData);
  }
  Future<void> _onEditNote(Note n) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => AddEditNotePage(type: n.type, note: n),
      ),
    );
    if (ok == true) setState(_loadData);
  }

  // Cards
  Future<void> _onDeleteCard(CardBase c) async {
    switch (c.type) {
      case CardType.payment:       await _cardDb.deletePayment(c.id); break;
      case CardType.id:            await _cardDb.deleteID(c.id); break;
      case CardType.driverLicense: await _cardDb.deleteDriverLicenseCard(c.id); break;
      case CardType.gift:          await _cardDb.deleteGiftCard(c.id); break;
      case CardType.misc:          await _cardDb.deleteMiscCard(c.id); break;
    }
    setState(_loadData);
  }
  Future<void> _onEditCard(CardBase c) async {
    final ok = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => AddEditCardPage(type: c.type, card: c),
      ),
    );
    if (ok == true) setState(_loadData);
  }

  void _showAddMenu() {
    final renderBox = _fabKey.currentContext!.findRenderObject() as RenderBox;
    final pos = renderBox.localToGlobal(Offset.zero);
    showMenu<AddOption>(
      context: context,
      position: RelativeRect.fromLTRB(
          pos.dx, pos.dy - 150, pos.dx + renderBox.size.width, pos.dy
      ),
      items: const [
        PopupMenuItem(value: AddOption.password, child: Text('Password')),
        PopupMenuItem(value: AddOption.note,     child: Text('Note')),
        PopupMenuItem(value: AddOption.card,     child: Text('Card')),
      ],
    ).then((opt) {
      if (opt == AddOption.password) {
        Navigator.push<bool>(
          context,
          MaterialPageRoute<bool>(
            builder: (_) => const AddEditCredentialPage(),
          ),
        ).then((ok) {
          if (ok == true) setState(_loadData);
        });
      } else if (opt == AddOption.note) {
        Navigator.push<bool>(
          context,
          MaterialPageRoute<bool>(
            builder: (_) => AddEditNotePage(type: NoteType.generic),
          ),
        ).then((ok) {
          if (ok == true) setState(_loadData);
        });
      } else if (opt == AddOption.card) {
        // default to creating a Payment card; user can switch type in the page
        Navigator.push<bool>(
          context,
          MaterialPageRoute<bool>(
            builder: (_) => AddEditCardPage(type: CardType.payment),
          ),
        ).then((ok) {
          if (ok == true) setState(_loadData);
        });
      }
    });
  }

  // Builders
  Widget _buildCredentialList() => FutureBuilder<List<Credential>>(
    future: _credentialList,
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snap.hasError) {
        return Center(child: Text('Error: ${snap.error}',
            style: TextStyle(color: AppColors.textSecondary)));
      }
      final creds = snap.data ?? [];
      if (creds.isEmpty) {
        return Center(child: Text('No passwords.',
            style: TextStyle(color: AppColors.textSecondary)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: creds.length,
        itemBuilder: (ctx, i) => CredentialCard(
          credential: creds[i],
          onEdit:   () => _onEditCredential(creds[i]),
          onDelete: () => _onDeleteCredential(creds[i].id),
        ),
      );
    },
  );

  Widget _buildNoteList() => FutureBuilder<List<Note>>(
    future: _noteList,
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snap.hasError) {
        return Center(child: Text('Error: ${snap.error}',
            style: TextStyle(color: AppColors.textSecondary)));
      }
      final notes = snap.data ?? [];
      if (notes.isEmpty) {
        return Center(child: Text('No notes.',
            style: TextStyle(color: AppColors.textSecondary)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notes.length,
        itemBuilder: (ctx, i) => NoteCard(
          note:     notes[i],
          onEdit:   () => _onEditNote(notes[i]),
          onDelete: () => _onDeleteNote(notes[i]),
        ),
      );
    },
  );

  Widget _buildCardList() => FutureBuilder<List<CardBase>>(
    future: _cardList,
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snap.hasError) {
        return Center(child: Text('Error: ${snap.error}',
            style: TextStyle(color: AppColors.textSecondary)));
      }
      final cards = snap.data ?? [];
      if (cards.isEmpty) {
        return Center(child: Text('No cards yet.',
            style: TextStyle(color: AppColors.textSecondary)));
      }
      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cards.length,
        itemBuilder: (ctx, i) => CardCard(
          card:     cards[i],
          onEdit:   () => _onEditCard(cards[i]),
          onDelete: () => _onDeleteCard(cards[i]),
        ),
      );
    },
  );

  Widget _buildAllList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Passwords', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
        const SizedBox(height: 8),
        SizedBox(height: 200, child: _buildCredentialList()),
        const SizedBox(height: 24),
        Text('Notes', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
        const SizedBox(height: 8),
        SizedBox(height: 200, child: _buildNoteList()),
        const SizedBox(height: 24),
        Text('Cards', style: TextStyle(color: AppColors.textPrimary, fontSize: 18)),
        const SizedBox(height: 8),
        SizedBox(height: 200, child: _buildCardList()),
      ],
    );
  }

  Widget _buildBody() {
    switch (_selectedCategory) {
      case Category.passwords: return _buildCredentialList();
      case Category.notes:     return _buildNoteList();
      case Category.cards:     return _buildCardList();
      case Category.all:       return _buildAllList();
    }
  }

  Widget _buildCategoryButtons() => Container(
    color: AppColors.surface,
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: Category.values.map((cat) {
          final label = {
            Category.all:       'All',
            Category.passwords: 'Passwords',
            Category.notes:     'Notes',
            Category.cards:     'Cards',
          }[cat]!;
          final selected = _selectedCategory == cat;
          return Padding(
            padding: const EdgeInsets.only(left: 16),
            child: ChoiceChip(
              label: Text(label, style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.textPrimary : AppColors.textSecondary,
              )),
              selected: selected,
              onSelected: (_) => setState(() {
                _selectedCategory = cat;
                _loadData();
              }),
              backgroundColor: AppColors.card,
              selectedColor: AppColors.accent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
          );
        }).toList(),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        backgroundColor: AppColors.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(builder: (_) => const SettingsPage()),
              );
              if (ok == true) {
                setState(_loadData);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Vault cleared')),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildCategoryButtons(),
          const SizedBox(height: 8),
          Expanded(child: _buildBody()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        key: _fabKey,
        backgroundColor: AppColors.accent,
        onPressed: _showAddMenu,
        child: const Icon(Icons.add),
      ),
    );
  }
}
