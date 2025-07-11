import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/game_detail_screen.dart';
import 'package:proyecto3/screens/game_list_screen.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';

// Widget reutilizable para mostrar títulos de secciones con estilo consistente.
class SectionTitleWidget extends StatelessWidget {
  final String title;

  const SectionTitleWidget({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accede a los colores del tema

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface, // Color del texto
        ),
      ),
    );
  }
}

// Widget reutilizable para mostrar un carrusel de juegos.
class GameSwiperWidget extends StatelessWidget {
  final List<Game> games;

  const GameSwiperWidget({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accede a los colores del tema

    return SizedBox(
      height: 200,
      child: Swiper(
        itemBuilder: (BuildContext context, int index) {
          final game = games[index];
          return GestureDetector(
            onTap: () {
              // Navega a la pantalla de detalles del juego
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
              color: colorScheme.surfaceContainer, // Fondo de la tarjeta
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
                              (_, __, ___) => Icon(
                                Icons.videogame_asset,
                                color: colorScheme.primary, // Ícono de respaldo
                              ),
                        ),
                      )
                      : Container(
                        color: colorScheme.surfaceContainerLow,
                        child: Icon(
                          Icons.videogame_asset,
                          size: 50,
                          color: colorScheme.primary,
                        ),
                      ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colorScheme.scrim.withOpacity(0.7), // Gradiente
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    left: 10,
                    right: 10,
                    child: Text(
                      game.name,
                      style: TextStyle(
                        color: colorScheme.onSurface,
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
}

// Widget reutilizable para mostrar una lista horizontal de juegos.
class HorizontalGameListWidget extends StatelessWidget {
  final List<Game> games;

  const HorizontalGameListWidget({super.key, required this.games});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accede a los colores del tema

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
                      // Navega a la pantalla de detalles del juego
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
                              color: colorScheme.surfaceContainerLow,
                              child: Icon(
                                Icons.videogame_asset,
                                color: colorScheme.primary, // Ícono de respaldo
                              ),
                            ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  game.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, color: colorScheme.onSurface),
                ),
                Text(
                  '⭐ ${game.rating.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// Widget reutilizable para mostrar resultados de búsqueda.
class SearchResultsWidget extends StatelessWidget {
  final List<Game> searchResults;

  const SearchResultsWidget({super.key, required this.searchResults});

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accede a los colores del tema

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Resultados de búsqueda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          if (searchResults.isEmpty)
            Center(
              child: Text(
                'No se encontraron resultados',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final game = searchResults[index];
                return ListTile(
                  leading: Image.network(
                    game.imageUrl,
                    width: 50,
                    errorBuilder:
                        (_, __, ___) => Icon(
                          Icons.videogame_asset,
                          color: colorScheme.primary, // Ícono de respaldo
                        ),
                  ),
                  title: Text(
                    game.name,
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                  subtitle: Text(
                    'Rating: ${game.rating}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  onTap: () {
                    // Navega a la pantalla de detalles del juego
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
        ],
      ),
    );
  }
}

// Widget reutilizable para el contenido principal de la página de inicio.
class NormalContentWidget extends StatelessWidget {
  final List<Game> popularGames;
  final List<Game> bestOf2024;
  final List<Game> topRated;
  final SharedPreferencesService prefsService;

  const NormalContentWidget({
    super.key,
    required this.popularGames,
    required this.bestOf2024,
    required this.topRated,
    required this.prefsService,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accede a los colores del tema

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sección de juegos populares
        const SectionTitleWidget(title: 'Populares'),
        GameSwiperWidget(games: popularGames),
        const SizedBox(height: 20),
        // Sección de lo mejor de 2024
        const SectionTitleWidget(title: 'Lo mejor de 2024'),
        HorizontalGameListWidget(games: bestOf2024),
        const SizedBox(height: 20),
        // Sección de mejor valorados
        const SectionTitleWidget(title: 'Mejor valorados'),
        HorizontalGameListWidget(games: topRated),
        const SizedBox(height: 20),
        // Botón para ver todos los juegos
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => GameListScreen(prefsService: prefsService),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Ver todos los juegos'),
          ),
        ),
      ],
    );
  }
}
