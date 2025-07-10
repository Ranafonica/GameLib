import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';
import 'package:proyecto3/services/shared_preferences_services.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/game_detail_screen.dart';
import 'package:proyecto3/screens/game_list_screen.dart';
import 'package:proyecto3/screens/platform_selection_screen.dart';
import 'package:proyecto3/screens/preferences_screen.dart';
import 'package:proyecto3/widgets/search_bar.dart';

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
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadGames() async {
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
        SnackBar(content: Text('Error al cargar juegos: ${e.toString()}')),
      );
    }
  }

  Future<void> _searchGames(String query) async {
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
          behavior: SnackBarBehavior.floating,
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

  Future<void> _refreshData() async {
    setState(() => isLoading = true);
    await _loadGames();
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
            icon: const Icon(Icons.search),
            onPressed: () {
              _searchFocusNode.requestFocus();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PreferencesScreen(
                    prefsService: widget.prefsService,
                  ),
                ),
              );
              _refreshData();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GameSearchBar(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onSubmitted: _searchGames,
                onClear: _clearSearch,
              ),

              if (isSearching)
                _buildSearchResults()
              else
                _buildNormalContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => _clearSearch(),
              ),
              const SizedBox(width: 8),
              Text(
                'Resultados para "${_searchController.text}"',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (searchResults.isEmpty)
            const Center(
              child: Text(
                'No se encontraron juegos',
                style: TextStyle(fontSize: 16),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final game = searchResults[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        game.imageUrl,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[300],
                          child: const Icon(Icons.videogame_asset),
                        ),
                      ),
                    ),
                    title: Text(game.name),
                    subtitle: Text('⭐ ${game.rating.toStringAsFixed(1)}'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => GameDetailScreen(gameId: game.id),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildNormalContent() {
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
                  builder: (_) => GameListScreen(prefsService: widget.prefsService),
                ),
              );
            },
            child: const Text('Ver todos los juegos'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildGameSwiper(List<Game> games) {
    return SizedBox(
      height: 220,
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
                borderRadius: BorderRadius.circular(12.0),
              ),
              elevation: 6,
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  game.imageUrl.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            game.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Center(
                              child: Icon(
                                Icons.videogame_asset,
                                size: 50,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.videogame_asset, size: 50),
                        ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Colors.black87, Colors.transparent],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 16,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              game.rating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        itemCount: games.length,
        viewportFraction: 0.85,
        scale: 0.92,
        autoplay: true,
        autoplayDelay: 5000,
      ),
    );
  }

  Widget _buildHorizontalGameList(List<Game> games) {
    return SizedBox(
      height: 180,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: games.length,
        itemBuilder: (context, index) {
          final game = games[index];
          return Container(
            width: 140,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(10),
                      ),
                      child: Image.network(
                        game.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Center(
                          child: Icon(
                            Icons.videogame_asset,
                            size: 40,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          game.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              game.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}