import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/widgets/home_page_widgets.dart'; // Importa HorizontalGameListWidget
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

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Busca juegos según la consulta
  Future<void> _searchGames(String query) async {
    if (query.isEmpty) {
      setState(() {
        searchResults.clear();
      });
      return;
    }

    setState(() => isLoading = true);

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

  // Aplica debounce a la entrada de búsqueda
  void _onSearchChanged(String query) {
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer?.cancel();
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) _searchGames(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme =
        Theme.of(context).colorScheme; // Accede a los colores del tema

    return Scaffold(
      backgroundColor: colorScheme.surface, // Fondo consistente con HomePage
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
          // Barra de búsqueda
          GameSearchBar(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onSubmitted: _searchGames,
            onClear: () {
              _searchController.clear();
              setState(() => searchResults.clear());
            },
          ),
          // Título de la sección de resultados
          if (searchResults.isNotEmpty || _searchController.text.isNotEmpty)
            const SectionTitleWidget(title: 'Resultados de búsqueda'),
          // Contenido principal
          Expanded(
            child:
                isLoading
                    ? Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    )
                    : searchResults.isEmpty
                    ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Ingresa un término de búsqueda'
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
                        ), // Usa widget reutilizable
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
