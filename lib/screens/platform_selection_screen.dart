import 'package:flutter/material.dart';
import 'package:proyecto3/main.dart';
import 'package:proyecto3/screens/game_list_screen.dart';
import '../constants/filters.dart';
import '../Services/shared_preferences_services.dart';
import 'about_screen.dart';

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
    _loadSelectedPlatforms();
  }

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
              : AppBar(
                title: const Text('Seleccionar Plataformas'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.info_outline),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => AboutScreen(
                                prefsService: widget.prefsService,
                              ),
                        ),
                      );
                    },
                  ),
                ],
              ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Título solo para setup inicial
            if (widget.isInitialSetup) ...[
              const SizedBox(height: 20),
              const Text(
                '¿Qué plataformas usas?',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],

            // Textos descriptivos solo para preferencias
            if (!widget.isInitialSetup) ...[
              const SizedBox(height: 8),
              const Text(
                'Plataformas preferidas',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Selecciona las plataformas en las que juegas para personalizar tu experiencia:',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(height: 16),
            ],

            // Lista de plataformas
            ...platforms.map((platform) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
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

            // Botón de acción
            Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 24.0),
              child: ElevatedButton(
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
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: Text(
                  widget.isInitialSetup ? 'Continuar' : 'Guardar preferencias',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
