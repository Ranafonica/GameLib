import 'package:flutter/material.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/game_detail_screen.dart';
import 'package:proyecto3/screens/platform_selection_screen.dart';

class GameListScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const GameListScreen({super.key, required this.prefsService});

  @override
  State<GameListScreen> createState() => _GameListScreenState();
}

class _GameListScreenState extends State<GameListScreen> {
  List<Game> games = [];
  bool isLoading = true;

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
      setState(() {
        games = gameList;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar juegos: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Juegos Populares'),
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
              ? const Center(child: CircularProgressIndicator())
              : games.isEmpty
              ? const Center(
                child: Text(
                  'No se encontraron juegos para las plataformas seleccionadas',
                ),
              )
              : ListView.builder(
                itemCount: games.length,
                itemBuilder: (context, index) {
                  final game = games[index];
                  return ListTile(
                    leading: Image.network(
                      game.imageUrl,
                      width: 50,
                      errorBuilder:
                          (_, __, ___) => const Icon(Icons.videogame_asset),
                    ),
                    title: Text(game.name),
                    subtitle: Text('Rating: ${game.rating}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameDetailScreen(gameId: game.id),
                        ),
                      );
                    },
                  );
                },
              ),
    );
  }
}
