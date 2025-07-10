import 'package:flutter/material.dart';
import 'package:proyecto3/services/shared_preferences_services.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/game_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const FavoritesScreen({super.key, required this.prefsService});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Game> favoriteGames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  // Cargar juegos favoritos desde SharedPreferences
  Future<void> _loadFavorites() async {
    final favorites = await widget.prefsService.getFavoriteGames();
    setState(() {
      favoriteGames = favorites;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Juegos Favoritos')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : favoriteGames.isEmpty
              ? const Center(child: Text('No tienes juegos favoritos aún'))
              : ListView.builder(
                itemCount: favoriteGames.length,
                itemBuilder: (context, index) {
                  final game = favoriteGames[index];
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
