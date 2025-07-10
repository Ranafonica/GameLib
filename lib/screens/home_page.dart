import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/game_detail_screen.dart';
import 'package:proyecto3/screens/game_list_screen.dart';
import 'package:proyecto3/screens/platform_selection_screen.dart';

class HomePage extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const HomePage({super.key, required this.prefsService});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Game> popularGames = [];
  List<Game> bestOf2024 = [];
  List<Game> topRated = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGames();
  }

  Future<void> _loadGames() async {
    try {
      final List<int>? selectedPlatforms =
          await widget.prefsService.getSelectedPlatforms();

      // Obtener juegos populares
      final popular = await RawgApi.fetchPopularGames(
        platformIds: selectedPlatforms,
      );

      // Obtener mejores de 2024 (filtrando por fecha de lanzamiento)
      final allGames = await RawgApi.fetchPopularGames(
        platformIds: selectedPlatforms,
      );
      final best2024 =
          allGames.where((game) {
            // Aquí deberías implementar lógica para filtrar por fecha
            // Esto es un placeholder - necesitarías modificar la API o el modelo
            return game.rating > 4.5; // Ejemplo simple
          }).toList();

      // Obtener mejor valorados
      final rated = await RawgApi.fetchPopularGames(
        platformIds: selectedPlatforms,
        ordering: '-rating', // Ordenar por rating descendente
      );

      setState(() {
        popularGames = popular.take(10).toList();
        bestOf2024 = best2024.take(10).toList();
        topRated = rated.take(10).toList();
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
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explorador de Juegos'),
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
              await _loadGames();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrusel de juegos populares
            _buildSectionTitle('Populares'),
            _buildGameSwiper(popularGames),

            const SizedBox(height: 20),

            // Mejores de 2024
            _buildSectionTitle('Lo mejor de 2024'),
            _buildHorizontalGameList(bestOf2024),

            const SizedBox(height: 20),

            // Mejor valorados
            _buildSectionTitle('Mejor valorados'),
            _buildHorizontalGameList(topRated),

            const SizedBox(height: 20),

            // Botón para ver todos los juegos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) =>
                              GameListScreen(prefsService: widget.prefsService),
                    ),
                  );
                },
                child: const Text('Ver todos los juegos'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildGameSwiper(List<Game> games) {
    return SizedBox(
      height: 200,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final game = games[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameDetailScreen(gameId: game.id),
                ),
              );
            },
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              elevation: 4,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  game.imageUrl.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          game.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (_, __, ___) => const Icon(Icons.videogame_asset),
                        ),
                      )
                      : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.videogame_asset, size: 50),
                      ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Text(
                      game.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: games.length,
        viewportFraction: 0.8,
        scale: 0.9,
        autoplay: true,
      ),
    );
  }

  Widget _buildHorizontalGameList(List<Game> games) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 120,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameDetailScreen(gameId: game.id),
                        ),
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        game.imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder:
                            (_, __, ___) => Container(
                              color: Colors.grey[300],
                              child: const Icon(Icons.videogame_asset),
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.name,
                  maxLines: 1,
                  overflow:
                      TextOverflow
                          .ellipsis, // Corregir: usar overflow en lugar de max
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '⭐ ${game.rating.toStringAsFixed(1)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
