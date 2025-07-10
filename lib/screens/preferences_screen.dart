import 'package:flutter/material.dart';
import 'package:proyecto3/services/shared_preferences_services.dart';

class PreferencesScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const PreferencesScreen({
    super.key,
    required this.prefsService,
  });

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _darkMode = false;
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final darkMode = await widget.prefsService.getDarkMode();
    final notifications = await widget.prefsService.getNotificationsEnabled();
    
    setState(() {
      _darkMode = darkMode;
      _notificationsEnabled = notifications;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Preferencias'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: const Text('Modo Oscuro'),
              value: _darkMode,
              onChanged: (value) async {
                await widget.prefsService.setDarkMode(value);
                setState(() => _darkMode = value);
              },
            ),
            SwitchListTile(
              title: const Text('Notificaciones'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                await widget.prefsService.setNotificationsEnabled(value);
                setState(() => _notificationsEnabled = value);
              },
            ),
          ],
        ),
      ),
    );
  }
}