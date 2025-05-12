// lib/pages/vault_page.dart

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../db/credential_db.dart';
import '../models/credential.dart';
import '../widgets/credential_card.dart';
import 'add_edit_credential_page.dart';
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
  final _dbHelper = CredentialDbHelper();
  late Future<List<Credential>> _credentialList;
  Category _selectedCategory = Category.all;
  final GlobalKey _fabKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _refreshList();
  }

  void _refreshList() {
    _credentialList = _dbHelper.getCredentials();
  }

  Future<void> _deleteCredential(int id) async {
    await _dbHelper.deleteCredential(id);
    setState(_refreshList);
  }

  Future<void> _editCredential(Credential cred) async {
    final updated = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => AddEditCredentialPage(credential: cred),
      ),
    );
    if (updated == true) setState(_refreshList);
  }

  Future<void> _addCredential() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => const AddEditCredentialPage(),
      ),
    );
    if (created == true) setState(_refreshList);
  }

  void _showAddMenu() {
    final renderBox = _fabKey.currentContext!.findRenderObject() as RenderBox;
    final offset = renderBox.localToGlobal(Offset.zero);
    showMenu<AddOption>(
      context: context,
      position: RelativeRect.fromLTRB(
        offset.dx,
        offset.dy - 150,
        offset.dx + renderBox.size.width,
        offset.dy,
      ),
      items: [
        const PopupMenuItem(
          value: AddOption.password,
          child: Text('Password'),
        ),
        const PopupMenuItem(
          value: AddOption.note,
          child: Text('Note'),
        ),
        const PopupMenuItem(
          value: AddOption.card,
          child: Text('Card'),
        ),
      ],
    ).then((opt) {
      switch (opt) {
        case AddOption.password:
          _addCredential();
          break;
        case AddOption.note:
        // TODO: push to add/edit note page
          break;
        case AddOption.card:
        // TODO: push to add/edit card page
          break;
        default:
          break;
      }
    });
  }

  Widget _buildCategoryButtons() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: Category.values.map((cat) {
            final label = {
              Category.all: 'All',
              Category.passwords: 'Passwords',
              Category.notes: 'Notes',
              Category.cards: 'Cards',
            }[cat]!;
            final selected = _selectedCategory == cat;
            return Padding(
              padding: const EdgeInsets.only(left: 16),
              child: ChoiceChip(
                label: Text(label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    )),
                selected: selected,
                onSelected: (_) =>
                    setState(() => _selectedCategory = cat),
                backgroundColor: AppColors.card,
                selectedColor: AppColors.accent,
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedCategory != Category.passwords &&
        _selectedCategory != Category.all) {
      final emptyText = _selectedCategory == Category.notes
          ? 'No notes yet.'
          : 'No cards yet.';
      return Center(
        child: Text(
          emptyText,
          style: TextStyle(color: AppColors.textSecondary),
        ),
      );
    }

    return FutureBuilder<List<Credential>>(
      future: _credentialList,
      builder: (ctx, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snap.hasError) {
          return Center(
            child: Text(
              'Error: ${snap.error}',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        final creds = snap.data ?? [];
        if (creds.isEmpty) {
          return Center(
            child: Text(
              'No credentials saved.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: creds.length,
          itemBuilder: (ctx, i) {
            final cred = creds[i];
            return CredentialCard(
              credential: cred,
              onEdit: () => _editCredential(cred),
              onDelete: () => _deleteCredential(cred.id),
            );
          },
        );
      },
    );
  }

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
              final cleared = await Navigator.push<bool>(
                context,
                MaterialPageRoute<bool>(
                  builder: (_) => const SettingsPage(),
                ),
              );
              if (cleared == true) {
                setState(_refreshList);
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
