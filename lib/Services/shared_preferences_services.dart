import 'package:shared_preferences/shared_preferences.dart';
import 'package:proyecto3/models/game.dart';

class SharedPreferencesService {
  static const String _platformsKey = 'selected_platforms';
  static const String _firstTimeKey = 'first_time';
  static const String _favoritesKey = 'favorite_games';
  static late final SharedPreferencesService prefsService; // Instancia estática
  static const String _darkModeKey = 'dark_mode';
  static const String _notificationsKey = 'notifications_enabled';

  final SharedPreferences _prefs;

  SharedPreferencesService(this._prefs);

  // Inicializar la instancia estática
  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    prefsService = SharedPreferencesService(prefs);
  }

  Future<bool> hasSelectedPlatforms() async {
    return _prefs.containsKey(_platformsKey);
  }

  Future<List<int>?> getSelectedPlatforms() async {
    final String? platformsString = _prefs.getString(_platformsKey);
    if (platformsString == null || platformsString.isEmpty) return null;

    try {
      return platformsString.split(',').map(int.parse).toList();
    } catch (e) {
      return null;
    }
  }

  Future<void> setSelectedPlatforms(List<int> platforms) async {
    await _prefs.setString(_platformsKey, platforms.join(','));
    await _prefs.setBool(_firstTimeKey, false);
  }

  Future<void> clearSelectedPlatforms() async {
    await _prefs.remove(_platformsKey);
  }

  // Guardar juegos favoritos
  Future<void> setFavoriteGames(List<Game> games) async {
    final List<String> gamesJson = games.map((game) => game.toJson()).toList();
    await _prefs.setStringList(_favoritesKey, gamesJson);
  }

  // Obtener juegos favoritos
  Future<List<Game>> getFavoriteGames() async {
    final List<String>? gamesJson = _prefs.getStringList(_favoritesKey);
    if (gamesJson == null || gamesJson.isEmpty) return [];
    return gamesJson.map((json) => Game.fromJsonString(json)).toList();
  }

  // Agregar un juego a favoritos
  Future<void> addFavoriteGame(Game game) async {
    final favorites = await getFavoriteGames();
    if (!favorites.any((g) => g.id == game.id)) {
      favorites.add(game);
      await setFavoriteGames(favorites);
    }
  }

  // Eliminar un juego de favoritos
  Future<void> removeFavoriteGame(int gameId) async {
    final favorites = await getFavoriteGames();
    favorites.removeWhere((game) => game.id == gameId);
    await setFavoriteGames(favorites);
  }

  // Verificar si un juego es favorito
  Future<bool> isFavoriteGame(int gameId) async {
    final favorites = await getFavoriteGames();
    return favorites.any((game) => game.id == gameId);
  }

  // Nuevos métodos para preferencias
  Future<bool> getDarkMode() async {
    return _prefs.getBool(_darkModeKey) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    await _prefs.setBool(_darkModeKey, value);
  }

  Future<bool> getNotificationsEnabled() async {
    return _prefs.getBool(_notificationsKey) ?? true;
  }

  Future<void> setNotificationsEnabled(bool value) async {
    await _prefs.setBool(_notificationsKey, value);
  }
}
