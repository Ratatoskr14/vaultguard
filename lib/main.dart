import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'pages/login_page.dart';
import 'pages/vault_page.dart';
import 'pages/settings_page.dart';

void main() {
  runApp(const VaultGuardApp());
}

class VaultGuardApp extends StatelessWidget {
  const VaultGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaultGuard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: AppColors.primary,
        scaffoldBackgroundColor: AppColors.background,
        inputDecorationTheme: const InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF1E1E1E),
          border: OutlineInputBorder(),
        ),
      ),
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (ctx) => const LoginPage(),
        VaultPage.routeName: (ctx) => const VaultPage(),
        SettingsPage.routeName: (ctx) => const SettingsPage(),
      },
    );
  }
}
