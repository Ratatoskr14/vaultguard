import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/biometric_service.dart';
import '../constants/colors.dart';
import '../db/credential_db.dart'; // make sure this is imported

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _driveBackupEnabled = true;
  int _backupFrequencyDays = 7;
  bool _biometricsEnabled = false;
  late final SharedPreferences _prefs;
  final _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _driveBackupEnabled    = _prefs.getBool('drive_backup_enabled') ?? true;
      _backupFrequencyDays   = _prefs.getInt('backup_frequency_days') ?? 7;
      _biometricsEnabled     = _prefs.getBool('biometrics_enabled') ?? false;
    });
  }

  Future<void> _onDriveBackupChanged(bool val) async {
    await _prefs.setBool('drive_backup_enabled', val);
    setState(() => _driveBackupEnabled = val);
  }

  Future<void> _onBackupFrequencyChanged(int? val) async {
    if (val != null) {
      await _prefs.setInt('backup_frequency_days', val);
      setState(() => _backupFrequencyDays = val);
    }
  }

  Future<void> _onBiometricsChanged(bool val) async {
    if (val) {
      final can = await _biometricService.canUseBiometrics();
      if (!can) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication not available')),
        );
        return;
      }
    }
    await _prefs.setBool('biometrics_enabled', val);
    setState(() => _biometricsEnabled = val);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SwitchListTile(
            title: const Text('Google Drive Backup'),
            value: _driveBackupEnabled,
            onChanged: _onDriveBackupChanged,
          ),
          const SizedBox(height: 16),
          const Text('Backup Frequency (days)', style: TextStyle(color: Colors.white)),
          DropdownButton<int>(
            value: _backupFrequencyDays,
            items: [3, 7, 14, 30]
                .map((d) => DropdownMenuItem(value: d, child: Text('$d days')))
                .toList(),
            onChanged: _onBackupFrequencyChanged,
          ),
          const Divider(height: 32, color: Colors.grey),
          SwitchListTile(
            title: const Text('Use Fingerprint (Biometrics)'),
            value: _biometricsEnabled,
            onChanged: _onBiometricsChanged,
          ),
          ListTile(
            leading: Icon(Icons.delete_forever, color: Colors.redAccent),
            title: Text('Clear Vault', style: TextStyle(color: Colors.redAccent)),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Confirm Clear Vault'),
                  content: Text('Delete *all* your stored credentials?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(context, true),  child: Text('Delete')),
                  ],
                ),
              ) ?? false;

              if (confirm) {
                await CredentialDbHelper().clearAll();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Vault has been cleared')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}