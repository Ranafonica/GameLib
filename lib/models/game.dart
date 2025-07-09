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
    final platformsRaw = json['platforms'] as List?;
    final platforms =
        platformsRaw?.map((p) => p['platform']['id'] as int).toList() ?? [];

    return Game(
      id: json['id'],
      name: json['name'],
      imageUrl: json['background_image'] ?? '',
      rating: (json['rating'] as num).toDouble(),
      platforms: platforms,
    );
  }

  bool isAvailableOnPlatform(int platformId) {
    return platforms.contains(platformId);
  }
}
