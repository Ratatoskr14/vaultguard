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

  void _deleteCredential(int id) async {
    await _dbHelper.deleteCredential(id);
    setState(_refreshList);
  }

  void _editCredential(Credential credential) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddEditCredentialPage(credential: credential),
      ),
    );
    if (result == true) setState(_refreshList);
  }

  void _addCredential() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddEditCredentialPage()),
    );
    if (result == true) setState(_refreshList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vault'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Settings',
            onPressed: () => Navigator.pushNamed(context, SettingsPage.routeName),
          ),
        ],
      ),
      body: FutureBuilder<List<Credential>>(
        future: _credentialList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: \${snapshot.error}'));
          }
          final creds = snapshot.data ?? [];
          if (creds.isEmpty) return const Center(child: Text('No credentials saved.'));
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: creds.length,
            itemBuilder: (context, i) {
              final cred = creds[i];
              return CredentialCard(
                credential: cred,
                onDelete: () => _deleteCredential(cred.id),
                onEdit: () => _editCredential(cred),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCredential,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add),
      ),
    );
  }
}