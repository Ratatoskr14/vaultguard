// NEW: user-facing theme modes
enum AppThemeMode { system, light, dark }

// NEW: ThemeData definitions
class AppThemes {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.light),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
    useMaterial3: true,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent, brightness: Brightness.dark),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1F1F1F),
      foregroundColor: Colors.white,
    ),
    useMaterial3: true,
  );
}

// NEW: controller to manage & persist theme choice
class ThemeModeController extends ChangeNotifier {
  static const _prefKey = 'app_theme_mode';
  ThemeMode _mode = ThemeMode.system;

  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    switch (raw) {
      case 'light':
        _mode = ThemeMode.light;
        break;
      case 'dark':
        _mode = ThemeMode.dark;
        break;
      default:
        _mode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> set(AppThemeMode appMode) async {
    switch (appMode) {
      case AppThemeMode.system:
        _mode = ThemeMode.system;
        break;
      case AppThemeMode.light:
        _mode = ThemeMode.light;
        break;
      case AppThemeMode.dark:
        _mode = ThemeMode.dark;
        break;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefKey,
      _mode == ThemeMode.light
          ? 'light'
          : _mode == ThemeMode.dark
          ? 'dark'
          : 'system',
    );
    notifyListeners();
  }
}