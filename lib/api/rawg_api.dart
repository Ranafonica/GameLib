import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_key.dart';
import '../models/game.dart';

class RawgApi {
  static const String baseUrl = 'https://api.rawg.io/api';

  static Future<List<Game>> fetchPopularGames({
    List<int>? platformIds,
    String? ordering,
  }) async {
    String url = '$baseUrl/games?key=$rawgApiKey&page_size=50';

    if (platformIds != null && platformIds.isNotEmpty) {
      url += '&platforms=${platformIds.join(',')}';
    }

    if (ordering != null) {
      url += '&ordering=$ordering';
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
}
