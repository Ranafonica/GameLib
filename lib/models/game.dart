import 'dart:convert'; // Importar para usar jsonDecode y jsonEncode

class Game {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;
  final List<int> platforms;
  final List<String>? screenshots;

  Game({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
    required this.platforms,
    this.screenshots,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    // Manejo de plataformas (mantén tu implementación actual)
    final platformsRaw = json['platforms'];
    List<int> platforms;
    if (platformsRaw is List<dynamic>) {
      if (platformsRaw.isNotEmpty && platformsRaw.first is int) {
        platforms = List<int>.from(platformsRaw);
      } else {
        platforms = platformsRaw?.map((p) => p['platform']['id'] as int).toList() ?? [];
      }
    } else {
      platforms = [];
    }

    // Manejo más robusto de screenshots
    List<String>? screenshots;
    if (json['short_screenshots'] != null) {
      screenshots = (json['short_screenshots'] as List)
          .map((s) => s['image'] as String?)
          .whereType<String>()
          .where((url) => url.isNotEmpty)
          .toList();
    }

    return Game(
      id: json['id'] as int,
      name: json['name'] as String,
      imageUrl: (json['background_image'] ?? json['imageUrl'] ?? '') as String,
      rating: (json['rating'] as num).toDouble(),
      platforms: platforms,
      screenshots: screenshots,
    );
  }

  // Añade este método para actualizar las screenshots
  Game copyWith({
    List<String>? screenshots,
  }) {
    return Game(
      id: id,
      name: name,
      imageUrl: imageUrl,
      rating: rating,
      platforms: platforms,
      screenshots: screenshots ?? this.screenshots,
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
