import 'dart:convert'; // Importar para usar jsonDecode y jsonEncode

class Game {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final List<int> platforms; // Lista de IDs de plataformas

  Game({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.platforms,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    final platformsRaw = json['platforms'];
    List<int> platforms;
    if (platformsRaw is List<dynamic>) {
      if (platformsRaw.isNotEmpty && platformsRaw.first is int) {
        // Caso de SharedPreferences: platforms es una lista de enteros
        platforms = List<int>.from(platformsRaw);
      } else {
        // Caso de la API: platforms es una lista de mapas
        platforms =
            platformsRaw?.map((p) => p['platform']['id'] as int).toList() ?? [];
      }
    } else {
      platforms = [];
    }

    return Game(
      id: json['id'],
      name: json['name'],
      imageUrl: json['background_image'] ?? '',
      rating: (json['rating'] as num).toDouble(),
      platforms: platforms,
    );
  }

  // Convertir el juego a JSON para guardar en SharedPreferences
  String toJson() {
    return jsonEncode({
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'rating': rating,
      'platforms': platforms,
    });
  }

  // Crear un juego desde un string JSON
  factory Game.fromJsonString(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return Game.fromJson(json);
  }

  bool isAvailableOnPlatform(int platformId) {
    return platforms.contains(platformId);
  }
}
