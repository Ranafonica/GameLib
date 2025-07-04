import 'package:flutter/material.dart';
import 'api/rawg_api.dart';
import 'models/game.dart';
import 'screens/game_detail_screen.dart';

void main() {
  runApp(const GameApp());
}

class GameApp extends StatelessWidget {
  const GameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'RAWG Game Explorer', home: GameListScreen());
  }
}

class GameListScreen extends StatefulWidget {
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
    final rawList = await RawgApi.fetchPopularGames();
    setState(() {
      games = rawList.map((json) => Game.fromJson(json)).toList();
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Juegos Populares')),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
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
