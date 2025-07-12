import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/widgets/home_page_widgets.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/widgets/search_bar.dart';

class SearchScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const SearchScreen({super.key, required this.prefsService});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Game> searchResults = [];
  bool isLoading = false;
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
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<void> _searchGames({String query = '', int? genreId}) async {
    if (query.isEmpty && genreId == null) {
      setState(() => searchResults.clear());
      return;
    }

    setState(() => isLoading = true);

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
          behavior: SnackBarBehavior.floating,
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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Buscar Juegos'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GameSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onSubmitted: (query) => _searchGames(query: query),
            onClear: () => setState(() => searchResults.clear()),
            genres: _genres,
            onGenreSelected: _onGenreSelected,
            selectedGenreId: _selectedGenreId,
          ),
          if (searchResults.isNotEmpty || 
              _searchController.text.isNotEmpty || 
              _selectedGenreId != null)
            const SectionTitleWidget(title: 'Resultados de búsqueda'),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: colorScheme.primary,
                    ),
                  )
                : searchResults.isEmpty
                    ? Center(
                        child: Text(
                          _searchController.text.isEmpty && _selectedGenreId == null
                              ? 'Ingresa un término o selecciona un género'
                              : 'No se encontraron resultados',
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 16,
                          ),
                        ),
                      )
                    : SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: HorizontalGameListWidget(
                            games: searchResults,
                          ),
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}