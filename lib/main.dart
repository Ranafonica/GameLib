import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/screens/home_page.dart';
import 'package:proyecto3/screens/favorites_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SharedPreferencesService.init(); // Inicializar la instancia estática
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
  int _selectedIndex = 0;

  // Lista de pantallas para la navegación
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      HomePage(prefsService: widget.prefsService),
      FavoritesScreen(prefsService: widget.prefsService),
    ];
  }

  // Cambiar pantalla según el índice seleccionado
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAWG Game Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Scaffold(
        body: _screens[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite),
              label: 'Favoritos',
            ),
          ],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
