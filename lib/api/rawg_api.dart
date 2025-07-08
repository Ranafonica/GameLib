import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_key.dart';
import '../models/game.dart'; // Asegúrate de tener este modelo

class RawgApi {
  static const String baseUrl = 'https://api.rawg.io/api';

  static Future<List<Game>> fetchPopularGames() async {
    final url = Uri.parse('$baseUrl/games?key=$rawgApiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['results'] as List)
          .map((json) => Game.fromJson(json))
          .toList();
    } else {
      throw Exception('Error al obtener juegos populares: ${response.statusCode}');
    }
  }
}
