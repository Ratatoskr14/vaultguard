import 'package:flutter/material.dart';
import 'package:vaultguard_v2/constants/colors.dart';

/// TextStyle and font family constants
class AppFonts {
  static const String primaryFont = 'Roboto';

  static const TextStyle heading = TextStyle(
    fontFamily: primaryFont,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontFamily: primaryFont,
    fontSize: 16,
    color: AppColors.textSecondary,
  );
}