// lib/pages/settings_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/biometric_service.dart';
import '../constants/colors.dart';
import '../db/credential_db.dart';

class SettingsPage extends StatefulWidget {
  static const routeName = '/settings';
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Firebase & Google Sign-In
  final _auth = FirebaseAuth.instance;
  final _googleSignIn = GoogleSignIn();
  final _firestore = FirebaseFirestore.instance;
  User? _user;

  // Existing settings
  bool _driveBackupEnabled = true;
  int _backupFrequencyDays = 7;
  bool _biometricsEnabled = false;
  late SharedPreferences _prefs;
  final _bioService = BiometricService();

  @override
  void initState() {
    super.initState();
    _loadSettings();
    // Listen to auth state changes
    _user = _auth.currentUser;
    _auth.userChanges().listen((u) {
      setState(() => _user = u);
      if (u != null) _createOrUpdateUserRecord(u);
    });
  }

  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _driveBackupEnabled = _prefs.getBool('drive_backup_enabled') ?? true;
      _backupFrequencyDays = _prefs.getInt('backup_frequency_days') ?? 7;
      _biometricsEnabled = _prefs.getBool('biometrics_enabled') ?? false;
    });
  }

  Future<void> _onDriveBackupChanged(bool v) async {
    await _prefs.setBool('drive_backup_enabled', v);
    setState(() => _driveBackupEnabled = v);
  }

  Future<void> _onBackupFrequencyChanged(int? v) async {
    if (v != null) {
      await _prefs.setInt('backup_frequency_days', v);
      setState(() => _backupFrequencyDays = v);
    }
  }

  Future<void> _onBiometricsChanged(bool v) async {
    if (v) {
      final can = await _bioService.canUseBiometrics();
      if (!can) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Biometric authentication not available')),
        );
        return;
      }
    }
    await _prefs.setBool('biometrics_enabled', v);
    setState(() => _biometricsEnabled = v);
  }

  // Google Sign-In and Firestore user setup
  Future<void> _signInWithGoogle() async {
    try {
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // user canceled

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCred = await _auth.signInWithCredential(credential);
      setState(() => _user = userCred.user);
      // Show success toast
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Signed in as ${_user!.displayName ?? _user!.email}',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-in failed: $e')),
      );
    }
  }

  Future<void> _signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      setState(() => _user = null);
      // Show sign-out toast
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Signed out successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign-out failed: $e')),
      );
    }
  }

  Future<void> _createOrUpdateUserRecord(User u) async {
    final doc = _firestore.collection('users').doc(u.uid);
    await doc.set({
      'displayName': u.displayName ?? '',
      'email': u.email ?? '',
      'photoURL': u.photoURL ?? '',
      'lastLogin': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Account Card
          Card(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              leading: _user?.photoURL != null
                  ? CircleAvatar(
                backgroundImage: NetworkImage(_user!.photoURL!),
                radius: 20,
              )
                  : Icon(Icons.account_circle, size: 40, color: AppColors.accent),
              title: Text(
                _user != null
                    ? _user!.displayName ?? _user!.email!
                    : 'Sign in with Google',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: _user != null ? FontWeight.normal : FontWeight.bold,
                ),
              ),
              subtitle: _user != null
                  ? Text(_user!.email!, style: TextStyle(color: AppColors.textSecondary))
                  : null,
              trailing: _user != null
                  ? IconButton(
                icon: Icon(Icons.logout, color: AppColors.accent),
                onPressed: _signOut,
              )
                  : null,
              onTap: _user == null ? _signInWithGoogle : null,
            ),
          ),

          const SizedBox(height: 16),

          // Data Backup Card
          Card(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Data Backup',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      )),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Google Drive Backup'),
                    value: _driveBackupEnabled,
                    onChanged: _onDriveBackupChanged,
                    activeColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text('Backup Frequency:', style: TextStyle(color: AppColors.textPrimary)),
                      const Spacer(),
                      DropdownButton<int>(
                        value: _backupFrequencyDays,
                        dropdownColor: AppColors.surface,
                        style: TextStyle(color: AppColors.textPrimary),
                        items: [3, 7, 14, 30]
                            .map((d) => DropdownMenuItem(
                          value: d,
                          child: Text('$d days'),
                        ))
                            .toList(),
                        onChanged: _driveBackupEnabled ? _onBackupFrequencyChanged : null,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Security Card
          Card(
            color: AppColors.card,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Security',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      )),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Use Fingerprint (Biometrics)'),
                    value: _biometricsEnabled,
                    onChanged: _onBiometricsChanged,
                    activeColor: AppColors.accent,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Danger Zone Card (fully red)
          Card(
            color: Colors.redAccent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              leading: const Icon(Icons.delete_forever, color: Colors.white),
              title: const Text('Clear Vault', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onTap: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    backgroundColor: AppColors.surface,
                    title: const Text('Confirm Clear Vault'),
                    content: const Text('Delete all your stored credentials?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Delete'),
                      ),
                    ],
                  ),
                ) ?? false;

                if (confirm) {
                  await CredentialDbHelper().clearAll();
                  Navigator.pop(context, true);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
