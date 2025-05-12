// lib/pages/login_page.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/biometric_service.dart';
import '../constants/auth.dart';
import '../constants/colors.dart';
import 'vault_page.dart';

class LoginPage extends StatefulWidget {
  static const routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late final BiometricService _biometricService;
  bool _biometricEnabled  = false;
  bool _isAuthenticating  = false;

  @override
  void initState() {
    super.initState();
    _biometricService = BiometricService();
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    final prefs  = await SharedPreferences.getInstance();
    final enabled = prefs.getBool('biometrics_enabled') ?? false;
    setState(() => _biometricEnabled = enabled);
    if (enabled) _authenticate();
  }

  Future<void> _authenticate() async {
    setState(() => _isAuthenticating = true);
    final success = await _biometricService.authenticate();
    setState(() => _isAuthenticating = false);
    if (success && mounted) {
      Navigator.pushReplacementNamed(context, VaultPage.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric authentication failed')),
      );
    }
  }

  void _tryLogin() {
    if (_emailCtrl.text.trim() == AuthConstants.adminEmail &&
        _passwordCtrl.text.trim() == AuthConstants.adminPassword) {
      Navigator.pushReplacementNamed(context, VaultPage.routeName);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Invalid email or password')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('VaultGuard Login')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_biometricEnabled) ...[
              if (_isAuthenticating) const CircularProgressIndicator(),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.fingerprint, size: 32),
                label: const Text('Login with Fingerprint'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                ),
                onPressed: _isAuthenticating ? null : _authenticate,
              ),
              const SizedBox(height: 16),
              TextButton(
                child: const Text('Use Password Instead'),
                onPressed: () => setState(() => _biometricEnabled = false),
              ),
            ],
            if (!_biometricEnabled) ...[
              TextField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _tryLogin,
                  child: const Text('Sign In'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
