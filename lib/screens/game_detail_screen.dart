// Modifica el game_detail_screen.dart con este código
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/models/game.dart';
import '../utils/api_key.dart';
import '../constants/filters.dart';
import 'game_list_screen.dart'; // Para mostrar los nombres de las plataformas

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
  final SharedPreferencesService _prefsService = SharedPreferencesService.prefsService;

  @override
  void initState() {
    super.initState();
    fetchGameDetails();
  }

  Future<void> fetchGameDetails() async {
    final url = Uri.parse(
      'https://api.rawg.io/api/games/${widget.gameId}?key=$rawgApiKey',
    );
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        gameData = data;
        game = Game.fromJson(data);
        isLoading = false;
      });
    } else {
      throw Exception('Error al obtener los detalles del juego');
    }
  }

  // Método para obtener los nombres de las plataformas
  List<String> getPlatformNames() {
    if (gameData == null || gameData!['platforms'] == null) return [];
    
    final platformNames = <String>[];
    for (var platform in gameData!['platforms']) {
      final platformName = platform['platform']['name'];
      if (platformName != null) {
        platformNames.add(platformName);
      }
    }
    return platformNames;
  }

  // Método para obtener los géneros
  List<Map<String, dynamic>> getGenres() {
  if (gameData == null || gameData!['genres'] == null) return [];
  
  return (gameData!['genres'] as List)
      .map((genre) => {
        'id': genre['id'],
        'name': genre['name']
      })
      .toList();
}

  List<String> getDevelopers() {
  if (gameData == null || gameData!['developers'] == null) return [];
  
  return (gameData!['developers'] as List)
      .map((developer) => developer['name'] as String)
      .toList();
}

void _searchByGenre(int genreId, String genreName) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => GameListScreen(
        prefsService: _prefsService,
        initialFilters: {
          'genres': genreId.toString(),
          'ordering': '-rating', // Ordenar por rating
        },
        title: 'Juegos de $genreName',
      ),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalles del Juego'),
        actions: [
          if (game != null)
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
                    setState(() {});
                  },
                );
              },
            ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Portada del juego
                  if (gameData!['background_image'] != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        gameData!['background_image'],
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                  const SizedBox(height: 16),

                  // Título y rating
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          gameData!['name'] ?? 'Sin nombre',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Chip(
                        backgroundColor: colorScheme.primaryContainer,
                        label: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            const SizedBox(width: 4),
                            Text(
                              gameData!['rating']?.toStringAsFixed(1) ?? '0.0',
                              style: textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Metadatos (Géneros, plataformas, año)
                  Row(
                    children: [
                      if (gameData!['released'] != null)
                        Text(
                          gameData!['released'].toString().split('-')[0],
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      if (gameData!['released'] != null && getDevelopers().isNotEmpty)
                        const SizedBox(width: 8),
                      if (gameData!['released'] != null && getDevelopers().isNotEmpty)
                        const Text('•', style: TextStyle(color: Colors.grey)),
                      if (getDevelopers().isNotEmpty) const SizedBox(width: 8),
                      if (getDevelopers().isNotEmpty)
                        Text(
                          getDevelopers().join(', '), // Muestra todos los desarrolladores separados por coma
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Sección de géneros
                  Text(
                    'Géneros',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: getGenres().map((genre) => InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () => _searchByGenre(genre['id'], genre['name']),
                      child: Chip(
                        label: Text(genre['name']),
                        backgroundColor: colorScheme.surfaceVariant,
                      ),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),

                  // Sección de plataformas
                  Text(
                    'Plataformas disponibles',
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: getPlatformNames().map((platform) => Chip(
                      label: Text(platform),
                      backgroundColor: colorScheme.surfaceVariant,
                      labelStyle: TextStyle(color: colorScheme.onSurfaceVariant),
                    )).toList(),
                  ),
                  const SizedBox(height: 16),


                  // Descripción
                  Text(
                    'Descripción',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gameData!['description_raw'] ?? 'No hay descripción disponible',
                    style: textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  // Sección de trailers (simulada)
                  Text(
                    'Trailers',
                    style: textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Esto es un placeholder - en una app real usarías la API para obtener trailers
                  _buildTrailerItem('Tráiler oficial', '2 min 14 sec'),
                  _buildTrailerItem('Gameplay trailer', '1 min 30 sec'),
                  _buildTrailerItem('Tráiler de lanzamiento', '1 min 14 sec'),
                ],
              ),
            ),
    );
  }

  Widget _buildTrailerItem(String title, String duration) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            width: 120,
            height: 70,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.play_circle_fill, size: 40),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(duration, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ],
      ),
    );
  }
}