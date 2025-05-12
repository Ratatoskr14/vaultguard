// lib/pages/vault_page.dart

import 'package:flutter/material.dart';
import '../constants/colors.dart';
import '../db/credential_db.dart';
import '../models/credential.dart';
import '../widgets/credential_card.dart';
import 'add_edit_credential_page.dart';
import 'settings_page.dart';

class VaultPage extends StatefulWidget {
  static const routeName = '/vault';
  const VaultPage({super.key});

  @override
  State<VaultPage> createState() => _VaultPageState();
}

class _VaultPageState extends State<VaultPage> {
  final _dbHelper = CredentialDbHelper();
  late Future<List<Credential>> _credentialList;

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
    if (updated == true) {
      setState(_refreshList);
    }
  }

  Future<void> _addCredential() async {
    final created = await Navigator.push<bool>(
      context,
      MaterialPageRoute<bool>(
        builder: (_) => const AddEditCredentialPage(),
      ),
    );
    if (created == true) {
      setState(_refreshList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
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
      body: FutureBuilder<List<Credential>>(
        future: _credentialList,
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final creds = snap.data ?? [];
          if (creds.isEmpty) {
            return const Center(child: Text('No credentials saved.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: creds.length,
            itemBuilder: (ctx, i) {
              final cred = creds[i];
              return CredentialCard(
                credential: cred,
                onEdit:   () => _editCredential(cred),
                onDelete: () => _deleteCredential(cred.id),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.accent,
        onPressed: _addCredential,
        child: const Icon(Icons.add),
      ),
    );
  }
}
