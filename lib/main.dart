import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final prefsService = SharedPreferencesService(prefs);

  runApp(GameApp(prefsService: prefsService));
}

class GameApp extends StatelessWidget {
  final SharedPreferencesService prefsService;

  const GameApp({super.key, required this.prefsService});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RAWG Game Explorer',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(prefsService: prefsService),
    );
  }
}
