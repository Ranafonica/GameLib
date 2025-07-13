// Modifica el game_detail_screen.dart con este código
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/models/game.dart';
import '../utils/api_key.dart';
import '../constants/filters.dart';
import 'game_list_screen.dart';
import 'package:share_plus/share_plus.dart';

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
  
  void _shareGame() {
    if (gameData == null) return;
    
    final String name = gameData!['name'] ?? 'Este increíble juego';
    final String releaseDate = gameData!['released'] ?? 'próximamente';
    final String rating = gameData!['rating']?.toStringAsFixed(1) ?? 'N/A';
    final String gameUrl = 'https://rawg.io/games/${widget.gameId}'; // URL de RAWG
    
    final String shareText = '🎮 $name 🎮\n\n'
        '📅 Fecha de lanzamiento: $releaseDate\n'
        '⭐ Calificación: $rating/5\n\n'
        '🔗 Más información: $gameUrl\n\n'
        '¡Descúbrelo en GameLib!';

    Share.share(shareText);
  }

  Future<void> fetchGameDetails() async {
  if (mounted) setState(() => isLoading = true);

  try {
    final gameUrl = Uri.parse(
      'https://api.rawg.io/api/games/${widget.gameId}?key=$rawgApiKey',
    );
    final screenshotsUrl = Uri.parse(
      'https://api.rawg.io/api/games/${widget.gameId}/screenshots?key=$rawgApiKey',
    );

    // Realiza ambas llamadas en paralelo
    final responses = await Future.wait([
      http.get(gameUrl),
      http.get(screenshotsUrl),
    ]);

    if (!mounted) return;

    if (responses[0].statusCode != 200) {
      throw Exception('Failed to load game details');
    }

    final gameData = json.decode(responses[0].body);
    List<String> screenshots = [];

    // Procesar screenshots si la respuesta fue exitosa
    if (responses[1].statusCode == 200) {
      final screenshotsData = json.decode(responses[1].body);
      if (screenshotsData['results'] != null) {
        screenshots = (screenshotsData['results'] as List)
            .map((s) => s['image'] as String?)
            .whereType<String>()
            .where((url) => url.isNotEmpty)
            .toList();
      }
    }

    if (mounted) {
      setState(() {
        this.gameData = gameData;
        game = Game.fromJson(gameData);
        
        // Actualiza solo las screenshots si se obtuvieron
        if (screenshots.isNotEmpty) {
          game = game!.copyWith(screenshots: screenshots);
        }
        
        isLoading = false;
      });
    }
  } catch (e) {
    debugPrint('Error fetching game details: $e');
    if (mounted) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading game: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
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

Widget _buildScreenshotsCarousel() {
  if (game?.screenshots == null || game!.screenshots!.isEmpty) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          'Capturas de Pantalla',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'No hay capturas disponibles para este juego',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      Text(
        'Capturas de Pantalla',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      SizedBox(
        height: 200,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: game!.screenshots!.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final screenshotUrl = game!.screenshots![index];
            return Container(
              margin: EdgeInsets.only(
                right: 16,
                left: index == 0 ? 16 : 0,
              ),
              width: 300,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  screenshotUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.broken_image),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
      ),
    ],
  );
}
// Añadir esta nueva función para mostrar la imagen en pantalla completa
void _showFullScreenImage(BuildContext context, String imageUrl) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: Center(
          child: InteractiveViewer(
            panEnabled: true,
            minScale: 0.5,
            maxScale: 3.0,
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
            ),
          ),
        ),
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
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareGame,
              tooltip: 'Compartir juego', // Texto descriptivo al mantener presionado
            ),
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
                // Imagen principal con sombra
                if (gameData!['background_image'] != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        gameData!['background_image'],
                        width: double.infinity,
                        height: 220,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            height: 220,
                            color: Colors.grey[300],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

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
                _buildScreenshotsCarousel(),
                const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}