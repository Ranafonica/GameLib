import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/game_detail_screen.dart';
import 'package:proyecto3/screens/game_list_screen.dart';
import 'package:proyecto3/screens/platform_selection_screen.dart';
import 'package:proyecto3/widgets/search_bar.dart';
import 'package:proyecto3/Services/connection_service.dart';

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
  bool _isOnline = true;

  // Variables para búsqueda
  List<Game> searchResults = [];
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _loadGames();
    _initConnectionListener();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  //conexion
  void _initConnectionListener() {
    ConnectionService.onConnectionChanged.listen((isOnline) {
      if (mounted) {
        setState(() {
          _isOnline = isOnline;
        });

        // Si volvemos a tener conexión, recargar los juegos
        if (isOnline) {
          _loadGames();
        }
      }
    });
  }

  Future<void> _loadGames() async {
    // Verificar conexión antes de hacer cualquier llamada
    final isOnline = await ConnectionService.hasInternetAccess();
    if (!isOnline) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      return;
    }
    try {
      final List<int>? selectedPlatforms =
          await widget.prefsService.getSelectedPlatforms();

      final popular = await RawgApi.fetchPopularGames(
        platformIds: selectedPlatforms,
      );

      final allGames = await RawgApi.fetchPopularGames(
        platformIds: selectedPlatforms,
      );
      final best2024 = allGames.where((game) => game.rating > 4.5).toList();

      final rated = await RawgApi.fetchPopularGames(
        platformIds: selectedPlatforms,
        ordering: '-rating',
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
        SnackBar(
          content: Text('Error al cargar juegos: ${e.toString()}'),
          backgroundColor:
              Theme.of(
                context,
              ).colorScheme.error, // Usando color de error del tema
        ),
      );
    }
  }

  Future<void> _searchGames(String query) async {
    // Verificar conexión antes de buscar
    final isOnline = await ConnectionService.hasInternetAccess();
    if (!isOnline) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hay conexión a internet'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }
    if (query.isEmpty) {
      setState(() {
        isSearching = false;
        searchResults.clear();
      });
      return;
    }

    setState(() {
      isLoading = true;
      isSearching = true;
    });

    try {
      final List<int>? selectedPlatforms =
          await widget.prefsService.getSelectedPlatforms();
      final results = await RawgApi.searchGames(
        query: query,
        platformIds: selectedPlatforms,
      );

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar: ${e.toString()}'),
          backgroundColor:
              Theme.of(
                context,
              ).colorScheme.error, // Usando color de error del tema
        ),
      );
    }
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchGames(query);
      } else {
        setState(() {
          isSearching = false;
          searchResults.clear();
        });
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      isSearching = false;
      searchResults.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accediendo al ColorScheme

    if (isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Explorador de Juegos'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          // Icono de estado de conexión
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            color: _isOnline ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 10),
          IconButton(
            icon: Icon(Icons.settings, color: colorScheme.onPrimary),
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
            // Mostrar mensaje de modo offline si no hay conexión
            if (!_isOnline)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.orange,
                width: double.infinity,
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Modo offline - Conéctate para ver contenido actualizado',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            // Barra de búsqueda
            GameSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSubmitted: _searchGames,
              onClear: _clearSearch,
            ),
            // Contenido principal (búsqueda o normal)
            if (isSearching) _buildSearchResults() else _buildNormalContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final colorScheme =
        Theme.of(context).colorScheme; // Accediendo al ColorScheme

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
              color: colorScheme.onSurface, // Color del texto usando onSurface
            ),
          ),
          const SizedBox(height: 16),
          if (searchResults.isEmpty)
            Center(
              child: Text(
                'No se encontraron resultados',
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                ), // Color para texto secundario
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
                          color:
                              colorScheme
                                  .primary, // Ícono de error con color primario
                        ),
                  ),
                  title: Text(
                    game.name,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                    ), // Color del título
                  ),
                  subtitle: Text(
                    'Rating: ${game.rating}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                    ), // Color del subtítulo
                  ),
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
        ],
      ),
    );
  }

  Widget _buildNormalContent() {
    final colorScheme =
        Theme.of(context).colorScheme; // Accediendo al ColorScheme

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Populares'),
        _buildGameSwiper(popularGames),
        const SizedBox(height: 20),
        _buildSectionTitle('Lo mejor de 2024'),
        _buildHorizontalGameList(bestOf2024),
        const SizedBox(height: 20),
        _buildSectionTitle('Mejor valorados'),
        _buildHorizontalGameList(topRated),
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => GameListScreen(prefsService: widget.prefsService),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor:
                  colorScheme.primary, // Fondo del botón con color primario
              foregroundColor:
                  colorScheme.onPrimary, // Texto del botón con color onPrimary
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8), // Bordes redondeados
              ),
            ),
            child: const Text('Ver todos los juegos'),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accediendo al ColorScheme

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurface, // Color del título de sección
        ),
      ),
    );
  }

  Widget _buildGameSwiper(List<Game> games) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accediendo al ColorScheme

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
              color:
                  colorScheme
                      .surfaceContainer, // Fondo de la tarjeta usando surfaceContainer
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
                                color:
                                    colorScheme
                                        .primary, // Ícono de error con color primario
                              ),
                        ),
                      )
                      : Container(
                        color:
                            colorScheme
                                .surfaceContainerLow, // Fondo alternativo para tarjetas sin imagen
                        child: Icon(
                          Icons.videogame_asset,
                          size: 50,
                          color:
                              colorScheme.primary, // Ícono con color primario
                        ),
                      ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          colorScheme.scrim.withOpacity(
                            0.7,
                          ), // Usando scrim para el gradiente
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
                        color:
                            colorScheme
                                .onSurface, // Color del texto en la tarjeta
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
    final colorScheme =
        Theme.of(context).colorScheme; // Accediendo al ColorScheme

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
                              color:
                                  colorScheme
                                      .surfaceContainerLow, // Fondo para imágenes fallidas
                              child: Icon(
                                Icons.videogame_asset,
                                color:
                                    colorScheme
                                        .primary, // Ícono con color primario
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
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurface, // Color del texto del nombre
                  ),
                ),
                Text(
                  '⭐ ${game.rating.toStringAsFixed(1)}',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        colorScheme
                            .onSurfaceVariant, // Color del texto de rating
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
