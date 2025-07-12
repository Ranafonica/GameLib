import 'package:flutter/material.dart';
import 'package:proyecto3/Services/shared_preferences_services.dart';
import 'package:proyecto3/models/game.dart';
import 'package:proyecto3/widgets/home_page_widgets.dart';

class FavoritesScreen extends StatefulWidget {
  final SharedPreferencesService prefsService;

  const FavoritesScreen({super.key, required this.prefsService});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Game> favoriteGames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await widget.prefsService.getFavoriteGames();
    setState(() {
      favoriteGames = favorites;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body:
          isLoading
              ? Center(
                child: CircularProgressIndicator(color: colorScheme.primary),
              )
              : favoriteGames.isEmpty
              ? Center(
                child: Text(
                  'No tienes juegos favoritos aún',
                  style: TextStyle(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                ),
              )
              : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionTitleWidget(title: 'Tus Juegos Favoritos'),
                    SearchGameGridWidget(games: favoriteGames),
                  ],
                ),
              ),
    );
  }
}
