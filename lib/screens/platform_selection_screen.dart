import 'package:flutter/material.dart';
import 'package:proyecto3/main.dart';
import 'package:proyecto3/screens/game_list_screen.dart';
import '../constants/filters.dart';
import '../Services/shared_preferences_services.dart';
import 'about_screen.dart';

class PlatformSelectionScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;
  final bool isInitialSetup;
  final void Function(ThemeMode)?
  onThemeChanged; // Callback para cambiar el tema

  const PlatformSelectionScreen({
    super.key,
    required this.prefsService,
    this.isInitialSetup = true,
    this.onThemeChanged,
  });

  @override
  State<PlatformSelectionScreen> createState() =>
      _PlatformSelectionScreenState();
}

class _PlatformSelectionScreenState extends State<PlatformSelectionScreen> {
  List<int> selectedPlatforms = [];
  ThemeMode _selectedThemeMode =
      ThemeMode.system; // Tema seleccionado inicialmente

  @override
  void initState() {
    super.initState();
    _loadSelectedPlatforms();
    _loadThemeMode();
  }

  Future<void> _loadSelectedPlatforms() async {
    final platforms = await widget.prefsService.getSelectedPlatforms();
    if (platforms != null) {
      setState(() {
        selectedPlatforms = platforms;
      });
    }
  }

  Future<void> _loadThemeMode() async {
    final themeMode = await widget.prefsService.getThemeMode();
    setState(() {
      _selectedThemeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme; // Acceder al ColorScheme

    return Scaffold(
      backgroundColor: colorScheme.surface, // Fondo del Scaffold
      appBar:
          widget.isInitialSetup
              ? null
              : AppBar(
                title: const Text('Seleccionar Plataformas'),
                backgroundColor: colorScheme.primary, // Fondo de la AppBar
                foregroundColor:
                    colorScheme.onPrimary, // Color del texto/iconos
                actions: [
                  IconButton(
                    icon: Icon(
                      Icons.info_outline,
                      color: colorScheme.onPrimary,
                    ),
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
              Text(
                '¿Qué plataformas usas?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Color del título
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
            ],

            // Textos descriptivos solo para preferencias
            if (!widget.isInitialSetup) ...[
              const SizedBox(height: 8),
              Text(
                'Plataformas preferidas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface, // Color del título
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Selecciona las plataformas en las que juegas para personalizar tu experiencia:',
                style: TextStyle(
                  color:
                      colorScheme
                          .onSurfaceVariant, // Color del texto secundario
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Selector de tema
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modo de tema',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  DropdownButton<ThemeMode>(
                    value: _selectedThemeMode,
                    onChanged: (ThemeMode? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedThemeMode = newValue;
                        });
                        widget.onThemeChanged?.call(
                          newValue,
                        ); // Actualizar el tema
                        widget.prefsService.setThemeMode(
                          newValue,
                        ); // Guardar preferencia
                      }
                    },
                    items: const [
                      DropdownMenuItem(
                        value: ThemeMode.system,
                        child: Text('Sistema'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.light,
                        child: Text('Claro'),
                      ),
                      DropdownMenuItem(
                        value: ThemeMode.dark,
                        child: Text('Oscuro'),
                      ),
                    ],
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ), // Color del texto del dropdown
                    dropdownColor:
                        colorScheme.surfaceContainer, // Fondo del dropdown
                    iconEnabledColor:
                        colorScheme.primary, // Color del ícono del dropdown
                  ),
                ],
              ),
            ),

            // Lista de plataformas
            ...platforms.map((platform) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        selectedPlatforms.contains(platform.id)
                            ? colorScheme
                                .primary // Fondo para plataforma seleccionada
                            : colorScheme
                                .surfaceContainerLow, // Fondo para no seleccionada
                    foregroundColor:
                        selectedPlatforms.contains(platform.id)
                            ? colorScheme
                                .onPrimary // Color del texto/iconos para seleccionada
                            : colorScheme
                                .onSurface, // Color del texto/iconos para no seleccionada
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
                      Icon(
                        platform.icon,
                        color:
                            selectedPlatforms.contains(platform.id)
                                ? colorScheme.onPrimary
                                : colorScheme.onSurface,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        platform.name,
                        style: TextStyle(
                          color:
                              selectedPlatforms.contains(platform.id)
                                  ? colorScheme.onPrimary
                                  : colorScheme.onSurface,
                        ),
                      ),
                      if (selectedPlatforms.contains(platform.id))
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Icon(
                            Icons.check,
                            size: 20,
                            color: colorScheme.onPrimary,
                          ),
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
                  backgroundColor: colorScheme.primary, // Fondo del botón
                  foregroundColor: colorScheme.onPrimary, // Color del texto
                  disabledBackgroundColor:
                      colorScheme
                          .surfaceContainerHigh, // Fondo cuando deshabilitado
                  disabledForegroundColor:
                      colorScheme
                          .onSurfaceVariant, // Texto cuando deshabilitado
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
