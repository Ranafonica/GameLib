import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/screens/home_page.dart';
import 'package:proyecto3/screens/favorites_screen.dart';
import 'package:proyecto3/screens/about_screen.dart';
import 'package:proyecto3/themes/theme.dart';
import 'package:proyecto3/themes/util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService.init();
  final prefs = await SharedPreferences.getInstance();
  final prefsService = SharedPreferencesService(prefs);

  runApp(GameApp(prefsService: prefsService));
}

class GameApp extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const GameApp({super.key, required this.prefsService});

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  late ThemeMode _themeMode;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  // Cargar el ThemeMode desde SharedPreferences
  Future<void> _loadThemeMode() async {
    final themeMode = await widget.prefsService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
      _isLoading = false;
    });
  }

  // Método para actualizar el ThemeMode
  void updateThemeMode(ThemeMode newThemeMode) {
    setState(() {
      _themeMode = newThemeMode;
    });
    widget.prefsService.setThemeMode(newThemeMode);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = createTextTheme(context, 'Roboto', 'Poppins');

    final materialTheme = MaterialTheme(textTheme);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return MaterialApp(
      title: 'GameLib',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: _themeMode,
      home: MainNavigationScreen(
        prefsService: widget.prefsService,
        onThemeChanged: updateThemeMode, // Pasar el callback
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;
  final void Function(ThemeMode) onThemeChanged;

  const MainNavigationScreen({
    super.key,
    required this.prefsService,
    required this.onThemeChanged,
  });

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(prefsService: widget.prefsService),
      FavoritesScreen(prefsService: widget.prefsService),
      AboutScreen(prefsService: widget.prefsService),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GameLib'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info_outline),
            label: 'Acerca de',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: colorScheme.surface,
        selectedItemColor: colorScheme.primary,
        unselectedItemColor: colorScheme.onSurfaceVariant,
      ),
    );
  }
}
