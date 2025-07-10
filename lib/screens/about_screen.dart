import 'package:flutter/material.dart';
import 'package:proyecto3/services/shared_preferences_services.dart';
import 'package:package_info_plus/package_info_plus.dart';

class AboutScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const AboutScreen({super.key, required this.prefsService});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _appVersion = 'Versión ${packageInfo.version}';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'RAWG Game Explorer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(_appVersion),
            const SizedBox(height: 20),
            const Text(
              'Esta aplicación utiliza la API de RAWG para mostrar información sobre videojuegos.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Desarrollado por: [Tu Nombre]',
              style: TextStyle(fontSize: 16),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}