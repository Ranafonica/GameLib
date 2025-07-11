import 'dart:async';
import 'package:flutter/material.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/api/rawg_api.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/screens/platform_selection_screen.dart';
import 'package:proyecto3/Services/connection_service.dart';
import 'package:proyecto3/widgets/home_page_widgets.dart'; // Importa widgets extraídos
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

  @override
  void initState() {
    super.initState();
    _loadGames(); // Carga los juegos al inicializar
    _initConnectionListener(); // Inicializa el listener de conectividad
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  // Inicializa el listener de conectividad para actualizar la UI
  void _initConnectionListener() {
    _connectionSubscription = ConnectionService.onConnectionChanged.listen((
      isOnline,
    ) {
      if (!mounted) return;

      setState(() {
        _isOnline = isOnline;
      });

      if (isOnline)
        _loadGames(); // Esto también contiene setState, por eso el check es importante
    });
  }

  // Carga los juegos desde la API según las plataformas seleccionadas
  Future<void> _loadGames() async {
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

      if (!mounted) return;
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
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  // Busca juegos según la consulta
  Future<void> _searchGames(String query) async {
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

  // Limpia la búsqueda
  void _clearSearch() {
    _searchController.clear();
    setState(() {
      isSearching = false;
      searchResults.clear();
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
      appBar: AppBar(
        title: const Text('Explorador de Juegos'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        actions: [
          // Ícono de estado de conexión
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
              await _loadGames(); // Recarga juegos tras seleccionar plataformas
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Advertencia de modo offline
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
            // Contenido condicional: resultados de búsqueda o contenido normal
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
