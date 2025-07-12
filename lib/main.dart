import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/screens/home_page.dart';
import 'package:proyecto3/screens/favorites_screen.dart';
import 'package:proyecto3/screens/about_screen.dart';
import 'package:proyecto3/themes/theme.dart';
import 'package:proyecto3/themes/util.dart';
import 'package:proyecto3/Services/connection_service.dart';
import 'package:proyecto3/screens/platform_selection_screen.dart';

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
  bool _isOnline = true;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
    _initConnectionListener();
  }

  void _initConnectionListener() {
    ConnectionService.onConnectionChanged.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });

        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(
              isOnline ? 'Conexión restablecida' : 'Estás en modo offline',
            ),
            backgroundColor: isOnline ? Colors.green : Colors.orange,
          ),
        );
      }
    });
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await widget.prefsService.getThemeMode();
    setState(() {
      _themeMode = themeMode;
      _isLoading = false;
    });
  }

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
      scaffoldMessengerKey: _scaffoldMessengerKey,
      title: 'GameLib',
      theme: materialTheme.light(),
      darkTheme: materialTheme.dark(),
      themeMode: _themeMode,
      home: MainNavigationScreen(
        prefsService: widget.prefsService,
        onThemeChanged: updateThemeMode,
        isOnline: _isOnline,
      ),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;
  final void Function(ThemeMode) onThemeChanged;
  final bool isOnline;

  const MainNavigationScreen({
    super.key,
    required this.prefsService,
    required this.onThemeChanged,
    required this.isOnline,
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
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required ColorScheme colorScheme,
    required double sizeFactor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 50 * sizeFactor,
                height: 50 * sizeFactor,
                decoration: BoxDecoration(
                  color:
                      isSelected
                          ? colorScheme.primary.withOpacity(0.2)
                          : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border:
                      isSelected
                          ? Border.all(color: colorScheme.primary, width: 2)
                          : null,
                ),
                child: Icon(
                  icon,
                  size: 28 * sizeFactor,
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color:
                      isSelected
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GameLib'),
        backgroundColor: colorScheme.primary.withOpacity(0.8),
        foregroundColor: colorScheme.onPrimary,
        actions: [
          // Ícono de estado de conexión
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Icon(
              widget.isOnline ? Icons.wifi : Icons.wifi_off,
              color: widget.isOnline ? Colors.green : Colors.orange,
            ),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (String value) {
              if (value == 'about') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => AboutScreen(prefsService: widget.prefsService),
                  ),
                );
              } else if (value == 'preferences') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PlatformSelectionScreen(
                          prefsService: widget.prefsService,
                          isInitialSetup: false,
                          onThemeChanged: widget.onThemeChanged,
                        ),
                  ),
                );
              }
            },
            itemBuilder:
                (BuildContext context) => <PopupMenuEntry<String>>[
                  const PopupMenuItem<String>(
                    value: 'about',
                    child: Text('Acerca de'),
                  ),
                  const PopupMenuItem<String>(
                    value: 'preferences',
                    child: Text('Preferencias'),
                  ),
                ],
          ),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 5),
        child: Container(
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: colorScheme.surfaceContainerHighest,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home,
                label: 'Inicio',
                index: 0,
                isSelected: _selectedIndex == 0,
                colorScheme: colorScheme,
                sizeFactor: 0.9,
              ),
              _buildNavItem(
                context: context,
                icon: Icons.favorite,
                label: 'Favoritos',
                index: 1,
                isSelected: _selectedIndex == 1,
                colorScheme: colorScheme,
                sizeFactor: 0.9,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
