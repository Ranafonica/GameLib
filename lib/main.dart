import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto3/services/shared_preferences_services.dart';
import 'package:proyecto3/screens/home_page.dart';
import 'package:proyecto3/screens/favorites_screen.dart';
import 'package:proyecto3/screens/preferences_screen.dart';
import 'package:proyecto3/screens/about_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService.init();
  final prefs = await SharedPreferences.getInstance();
  final prefsService = SharedPreferencesService(prefs);

  final darkMode = await prefsService.getDarkMode();

  runApp(GameApp(
    prefsService: prefsService,
    initialDarkMode: darkMode,
  ));
}

class GameApp extends StatefulWidget {
  final SharedPreferencesService prefsService;
  final bool initialDarkMode;

  const GameApp({
    super.key,
    required this.prefsService,
    required this.initialDarkMode,
  });

  @override
  State<GameApp> createState() => _GameAppState();
}

class _GameAppState extends State<GameApp> {
  int _selectedIndex = 0;
  late bool _darkMode;
  late List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _darkMode = widget.initialDarkMode;
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = [
      HomePage(prefsService: widget.prefsService),
      FavoritesScreen(prefsService: widget.prefsService),
    ];
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  void _updateTheme(bool isDarkMode) async {
    await widget.prefsService.setDarkMode(isDarkMode);
    setState(() => _darkMode = isDarkMode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAWG Game Explorer',
      debugShowCheckedModeBanner: false,
      theme: _buildThemeData(_darkMode),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: _buildBottomNavigationBar(),
        drawer: _buildAppDrawer(),
      ),
    );
  }

  ThemeData _buildThemeData(bool isDarkMode) {
    return (isDarkMode ? ThemeData.dark() : ThemeData.light()).copyWith(
      colorScheme: ColorScheme(
        primary: Colors.blue,
        secondary: Colors.blueAccent,
        surface: isDarkMode ? Colors.grey[800]! : Colors.white,
        background: isDarkMode ? Colors.grey[900]! : Colors.grey[100]!,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: isDarkMode ? Colors.white : Colors.black,
        onBackground: isDarkMode ? Colors.white : Colors.black,
        onError: Colors.white,
        brightness: isDarkMode ? Brightness.dark : Brightness.light,
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Favoritos'),
      ],
      currentIndex: _selectedIndex,
      onTap: _onItemTapped,
    );
  }

  Widget _buildAppDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Text(
              'RAWG Explorer',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.settings, 
                color: Theme.of(context).colorScheme.onSurface),
            title: Text('Preferencias',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PreferencesScreen(
                    prefsService: widget.prefsService,
                  ),
                ),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.info,
                color: Theme.of(context).colorScheme.onSurface),
            title: Text('Acerca de',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface)),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AboutScreen(prefsService: widget.prefsService),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}