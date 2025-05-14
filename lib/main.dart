// lib/main.dart

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'constants/colors.dart';
import 'pages/login_page.dart';
import 'pages/vault_page.dart';
import 'pages/settings_page.dart';

Future<void> main() async {
  // Ensure Flutter bindings and Firebase are initialized before running the app
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const VaultGuardApp());
}

class VaultGuardApp extends StatelessWidget {
  const VaultGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    final baseDark = ThemeData.dark();
    return MaterialApp(
      title: 'VaultGuard',
      debugShowCheckedModeBanner: false,
      theme: baseDark.copyWith(
        // Update the ColorScheme to use our custom greys
        colorScheme: baseDark.colorScheme.copyWith(
          background:   AppColors.background,
          surface:      AppColors.surface,
          primary:      AppColors.accent,
          onBackground: AppColors.textPrimary,
          onSurface:    AppColors.textPrimary,
        ),
        scaffoldBackgroundColor: AppColors.background,
        cardColor:               AppColors.card,
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          foregroundColor: AppColors.textPrimary,
          elevation:       0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled:     true,
          fillColor:  AppColors.surface,
          border:     OutlineInputBorder(
            borderRadius: BorderRadius.circular(4),
            borderSide:   BorderSide.none,
          ),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppColors.accent),
            foregroundColor: MaterialStateProperty.all(AppColors.textPrimary),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(color: AppColors.textPrimary, fontSize: 20),
          bodyMedium: TextStyle(color: AppColors.textSecondary),
        ),
        popupMenuTheme: PopupMenuThemeData(
          color: AppColors.surface,
          textStyle: const TextStyle(color: AppColors.textPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS:     CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      initialRoute: LoginPage.routeName,
      routes: {
        LoginPage.routeName: (_) => const LoginPage(),
        VaultPage.routeName: (_) => const VaultPage(),
        SettingsPage.routeName: (_) => const SettingsPage(),
      },
    );
  }
}
