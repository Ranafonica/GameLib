import 'package:flutter/material.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  final SharedPreferencesService prefsService;

  const AboutScreen({super.key, required this.prefsService});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Acerca de'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage('assets/app_icon.png'), // Asegúrate de tener este asset
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                'GameLib',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Versión 1.0.0',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              'Descripción',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aplicación para explorar videojuegos utilizando la API de RAWG.io. '
              'Puedes buscar juegos, ver detalles, filtrar por plataformas y guardar tus favoritos.',
            ),
            const SizedBox(height: 20),
            const Text(
              'Desarrollado por',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Martin Bascuñan y Benjamín Paz'),
            const SizedBox(height: 20),
            const Text(
              'Tecnologías utilizadas',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Flutter, Dart, RAWG API, SharedPreferences'),
            const SizedBox(height: 20),
            const Text(
              'Enlaces',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildLinkTile(
              context,
              icon: Icons.public,
              title: 'RAWG API',
              url: 'https://rawg.io/apidocs',
            ),
            _buildLinkTile(
              context,
              icon: Icons.code,
              title: 'Repositorio del proyecto',
              url: 'https://github.com/Ranafonica/GameLib',
            ),
            _buildLinkTile(
              context,
              icon: Icons.bug_report,
              title: 'Reportar un problema',
              url: 'https://github.com/tu_usuario/tu_repositorio/issues',
            ),
            const SizedBox(height: 30),
            Center(
              child: Text(
                '© ${DateTime.now().year} IDVRV Utal',
                style: const TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkTile(BuildContext context, {
    required IconData icon,
    required String title,
    required String url,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () => _launchUrl(context, url),
    );
  }

  Future<void> _launchUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication, // Abre en navegador externo
      )) {
        _showErrorSnackbar(context, 'No se pudo abrir $url');
      }
    } catch (e) {
      _showErrorSnackbar(context, 'Error al abrir el enlace: ${e.toString()}');
    }
  }

  void _showErrorSnackbar(BuildContext context, String message) {
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}