class Game {
  final int id;
  final String name;
  final String imageUrl;
  final double rating;

  Game({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.rating,
  });

  factory Game.fromJson(Map<String, dynamic> json) {
    return Game(
      id: json['id'],
      name: json['name'],
      imageUrl: json['background_image'] ?? '',
      rating: (json['rating'] as num).toDouble(),
    );
  }
}
