import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/models/game.dart';
import '../utils/api_key.dart';

class GameDetailScreen extends StatefulWidget {
  final int gameId;

  const GameDetailScreen({super.key, required this.gameId});

  @override
  State<GameDetailScreen> createState() => _GameDetailScreenState();
}

class _GameDetailScreenState extends State<GameDetailScreen> {
  Map<String, dynamic>? gameData;
  bool isLoading = true;
  Game? game;
  final SharedPreferencesService _prefsService =
      SharedPreferencesService.prefsService;

  @override
  void initState() {
    super.initState();
    fetchGameDetails();
  }

  // Obtener detalles del juego desde la API
  Future<void> fetchGameDetails() async {
    final url = Uri.parse(
      'https://api.rawg.io/api/games/${widget.gameId}?key=$rawgApiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        gameData = data;
        game = Game.fromJson(data); // Crear instancia de Game
        isLoading = false;
      });
    } else {
      throw Exception('Error al obtener los detalles del juego');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Juego'),
        actions: [
          if (game != null) // Mostrar ícono solo si el juego está cargado
            FutureBuilder<bool>(
              future: _prefsService.isFavoriteGame(game!.id),
              builder: (context, snapshot) {
                final isFavorite = snapshot.data ?? false;
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () async {
                    if (isFavorite) {
                      await _prefsService.removeFavoriteGame(game!.id);
                    } else {
                      await _prefsService.addFavoriteGame(game!);
                    }
                    setState(() {}); // Refrescar la UI
                  },
                );
              },
            ),
        ],
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (gameData!['background_image'] != null)
                        Image.network(gameData!['background_image']),
                      const SizedBox(height: 16),
                      Text(
                        gameData!['name'] ?? 'Sin nombre',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      Text('Rating: ${gameData!['rating']}'),
                      const SizedBox(height: 16),
                      Text(
                        gameData!['description_raw'] ?? 'Sin descripción',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }
}
