import 'package:flutter/material.dart';
import 'package:proyecto3/main.dart';
import 'package:proyecto3/screens/game_list_screen.dart';
import '../constants/filters.dart';
import '../Services/shared_preferences_services.dart';

class PlatformSelectionScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;
  final bool isInitialSetup;

  const PlatformSelectionScreen({
    super.key,
    required this.prefsService,
    this.isInitialSetup = true,
  });

  @override
  State<PlatformSelectionScreen> createState() =>
      _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  List<int> selectedPlatforms = [];

  @override
  void initState() {
    super.initState();
    // Cargar plataformas seleccionadas desde SharedPreferences
    _loadSelectedPlatforms();
  }

  // Cargar plataformas seleccionadas
  Future<void> _loadSelectedPlatforms() async {
    final platforms = await widget.prefsService.getSelectedPlatforms();
    if (platforms != null) {
      setState(() {
        selectedPlatforms = platforms;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          widget.isInitialSetup
              ? null
              : AppBar(title: const Text('Seleccionar Plataformas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.isInitialSetup)
              const Text(
                '¿Qué plataformas usas?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            if (widget.isInitialSetup) const SizedBox(height: 32),
            ...platforms.map((platform) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedPlatforms.contains(platform.id)
                            ? Theme.of(context).primaryColor
                            : Colors.grey[200],
                    foregroundColor:
                        selectedPlatforms.contains(platform.id)
                            ? Colors.white
                            : Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    setState(() {
                      if (selectedPlatforms.contains(platform.id)) {
                        selectedPlatforms.remove(platform.id);
                      } else {
                        selectedPlatforms.add(platform.id);
                      }
                    });
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(platform.icon),
                      const SizedBox(width: 10),
                      Text(platform.name),
                      if (selectedPlatforms.contains(platform.id))
                        const Padding(
                          padding: EdgeInsets.only(left: 10),
                          child: Icon(Icons.check, size: 20),
                        ),
                    ],
                  ),
                ),
              );
            }).toList(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  selectedPlatforms.isEmpty
                      ? null
                      : () async {
                        await widget.prefsService.setSelectedPlatforms(
                          selectedPlatforms,
                        );
                        if (widget.isInitialSetup) {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder:
                                  (_) => GameListScreen(
                                    prefsService: widget.prefsService,
                                  ),
                            ),
                          );
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
              child: Text(widget.isInitialSetup ? 'Continuar' : 'Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
//Actualizacion 