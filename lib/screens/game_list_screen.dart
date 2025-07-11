import 'package:flutter/material.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/game_detail_screen.dart';
import 'package:proyecto3/screens/platform_selection_screen.dart';
import 'package:proyecto3/widgets/home_page_widgets.dart'; // Importamos los widgets

class GameListScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const GameListScreen({super.key, required this.prefsService});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  List<Game> games = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    loadGames();
  }

  Future<void> loadGames() async {
    try {
      final List<int>? selectedPlatforms =
          await widget.prefsService.getSelectedPlatforms();
      final gameList = await RawgApi.fetchPopularGames(
        platformIds: selectedPlatforms,
      );

      if (!mounted) return;
      setState(() {
        games = gameList;
        isLoading = false;
        hasError = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar juegos: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Juegos'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => PlatformSelectionScreen(
                        prefsService: widget.prefsService,
                        isInitialSetup: false,
                      ),
                ),
              );
              if (!mounted) return;
              setState(() {
                isLoading = true;
              });
              await loadGames();
            },
          ),
        ],
      ),
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
              : hasError
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: colorScheme.error,
                      size: 48,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error al cargar los juegos',
                      style: textTheme.headlineSmall?.copyWith(
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: loadGames,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              )
              : games.isEmpty
              ? Center(
                child: Text(
                  'No se encontraron juegos para las plataformas seleccionadas',
                  style: textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: AllGamesGridWidget(games: games),
              ),
    );
  }
}
