import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_key.dart';
import '../models/game.dart';

class RawgApi {
  static const String baseUrl = 'https://api.rawg.io/api';

  static Future<List<Game>> fetchPopularGames({
    List<int>? platformIds,
    String? ordering,
    Map<String, String>? additionalParams, // Nuevo parámetro para filtros adicionales
  }) async {
    String url = '$baseUrl/games?key=$rawgApiKey&page_size=50';

    // Filtro por plataformas
    if (platformIds != null && platformIds.isNotEmpty) {
      url += '&platforms=${platformIds.join(',')}';
    }

    // Ordenamiento
    if (ordering != null) {
      url += '&ordering=$ordering';
    }

    // Parámetros adicionales (como géneros)
    if (additionalParams != null) {
      additionalParams.forEach((key, value) {
        url += '&$key=$value';
      });
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final allGames =
          (data['results'] as List).map((json) => Game.fromJson(json)).toList();

      // Filtrado adicional para asegurar compatibilidad
      if (platformIds != null && platformIds.isNotEmpty) {
        return allGames
            .where(
              (game) => platformIds.any((id) => game.platforms.contains(id)),
            )
            .toList();
      }

      return allGames;
    } else {
      throw Exception(
        'Error al obtener juegos populares: ${response.statusCode}',
      );
    }
  }

  static Future<List<Game>> searchGames({
    required String query,
    List<int>? platformIds,
    Map<String, String>? additionalParams, // Nuevo parámetro para filtros adicionales
  }) async {
    String url = '$baseUrl/games?key=$rawgApiKey&page_size=50&search=$query';

    // Filtro por plataformas
    if (platformIds != null && platformIds.isNotEmpty) {
      url += '&platforms=${platformIds.join(',')}';
    }

    // Parámetros adicionales
    if (additionalParams != null) {
      additionalParams.forEach((key, value) {
        url += '&$key=$value';
      });
    }

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final allGames =
          (data['results'] as List).map((json) => Game.fromJson(json)).toList();

      if (platformIds != null && platformIds.isNotEmpty) {
        return allGames
            .where(
              (game) => platformIds.any((id) => game.platforms.contains(id)),
            )
            .toList();
      }

      return allGames;
    } else {
      throw Exception('Error al buscar juegos: ${response.statusCode}');
    }
  }

  // Método adicional para buscar por género específico
  static Future<List<Game>> fetchGamesByGenre({
    required int genreId,
    List<int>? platformIds,
    String? ordering,
  }) async {
    return fetchPopularGames(
      platformIds: platformIds,
      ordering: ordering,
      additionalParams: {'genres': genreId.toString()},
    );
  }
}