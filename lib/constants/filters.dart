import 'package:flutter/material.dart';

class Platform {
  final int id;
  final String name;
  final IconData icon;

  const Platform({required this.id, required this.name, required this.icon});
}

const List<Platform> platforms = [
  Platform(id: 4, name: 'PC', icon: Icons.computer), // IDs como int
  Platform(id: 1, name: 'Xbox', icon: Icons.sports_esports),
  Platform(id: 18, name: 'PlayStation', icon: Icons.videogame_asset),
  Platform(id: 7, name: 'Nintendo Switch', icon: Icons.gamepad),
  Platform(id: 3, name: 'iOS', icon: Icons.phone_iphone),
  Platform(id: 21, name: 'Android', icon: Icons.android),
];

// IDs de plataforma de RAWG API:
// 1: Xbox
// 2: PlayStation 2
// 3: iOS
// 4: PC
// 5: macOS
// 6: Linux
// 7: Nintendo Switch
// 8: Nintendo 3DS
// 9: Nintendo DS
// 10: Wii U
// 11: Wii
// 12: Neo Geo
// 13: Nintendo DSi
// 14: Xbox 360
// 15: PlayStation 3
// 16: PlayStation 4
// 17: PlayStation 5
// 18: PlayStation
// 19: PSP
// 20: Xbox One
// 21: Android
// etc...
