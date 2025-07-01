import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/api_key.dart';

class RawgApi {
  static const String baseUrl = 'https://api.rawg.io/api';

  static Future<List<dynamic>> fetchPopularGames() async {
    final url = Uri.parse('$baseUrl/games?key=$rawgApiKey');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['results'];
    } else {
      throw Exception('Error al obtener juegos populares');
    }
  }
}
