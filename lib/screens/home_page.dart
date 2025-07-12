import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/platform_selection_screen.dart';
import 'package:proyecto3/Services/connection_service.dart';
import 'package:proyecto3/widgets/home_page_widgets.dart';
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
  bool _isOnline = true;
  StreamSubscription<bool>? _connectionSubscription;

  // Variables para búsqueda
  List<Game> searchResults = [];
  bool isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounceTimer;
  int? _selectedGenreId;
  final List<Map<String, dynamic>> _genres = [
    {'id': 4, 'name': 'Acción'},
    {'id': 51, 'name': 'Indie'},
    {'id': 3, 'name': 'Aventura'},
    {'id': 5, 'name': 'RPG'},
    {'id': 2, 'name': 'Estrategia'},
    {'id': 7, 'name': 'Deportes'},
  ];

  @override
  void initState() {
    super.initState();
    _loadGames();
    _initConnectionListener();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _initConnectionListener() {
    _connectionSubscription = ConnectionService.onConnectionChanged.listen((isOnline) {
      if (!mounted) return;

      setState(() => _isOnline = isOnline);
      if (isOnline) _loadGames();
    });
  }

  Future<void> _loadGames() async {
    final isOnline = await ConnectionService.hasInternetAccess();
    if (!isOnline) {
      if (mounted) setState(() => isLoading = false);
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

      if (!mounted) return;
      setState(() {
        popularGames = popular.take(10).toList();
        bestOf2024 = best2024.take(10).toList();
        topRated = rated.take(10).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar juegos: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  Future<void> _searchGames({String query = '', int? genreId}) async {
    final isOnline = await ConnectionService.hasInternetAccess();
    if (!isOnline) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No hay conexión a internet'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
      return;
    }

    if (query.isEmpty && genreId == null) {
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
        additionalParams: genreId != null ? {'genres': genreId.toString()} : null,
      );

      setState(() {
        searchResults = results;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al buscar: ${e.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _onGenreSelected(int genreId) {
    setState(() {
      _selectedGenreId = genreId == -1 ? null : genreId;
      _searchController.clear();
    });
    _searchGames(genreId: _selectedGenreId);
  }

  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) {
        _searchGames(query: query);
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
      _selectedGenreId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

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
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
            GameSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              onSubmitted: (query) => _searchGames(query: query),
              onClear: _clearSearch,
              genres: _genres,
              onGenreSelected: _onGenreSelected,
              selectedGenreId: _selectedGenreId,
            ),
            if (isSearching)
              SearchResultsWidget(searchResults: searchResults)
            else
              NormalContentWidget(
                popularGames: popularGames,
                bestOf2024: bestOf2024,
                topRated: topRated,
                prefsService: widget.prefsService,
              ),
          ],
        ),
      ),
    );
  }
}