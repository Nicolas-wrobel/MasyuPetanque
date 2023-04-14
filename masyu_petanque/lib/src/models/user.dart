import 'package:flutter/foundation.dart';

class LocalUser {
  final String id;
  final String firstName;
  final String lastName;
  final DateTime firstConnection;
  final DateTime lastConnection;
  final List<String> favoriteMaps;
  final Map<String, dynamic>? playedMaps;

  LocalUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.firstConnection,
    required this.lastConnection,
    required this.favoriteMaps,
    required this.playedMaps,
  });

  static LocalUser fromMap(Map<String, dynamic> map, String id) {
    if (kDebugMode) {
      print("voici le user reçu $map");
    }

    List<String> favoriteMaps = [];
    if (map['favorite_maps'] != null) {
      final Map<dynamic, dynamic> favoriteMapsData = map['favorite_maps'];
      favoriteMapsData.forEach((key, value) {
        favoriteMaps.add(value['map_id']);
      });
    }

    // Gérer le cas où played_maps est vide ou null
    Map<String, dynamic>? playedMaps;
    if (map['played_maps'] != null && map['played_maps'].isNotEmpty) {
      playedMaps = Map<String, dynamic>.from(map['played_maps']);
    }

    return LocalUser(
      id: id,
      firstName: map['first_name'],
      lastName: map['last_name'],
      firstConnection: DateTime.parse(map['first_connection']),
      lastConnection: DateTime.parse(map['last_connection']),
      favoriteMaps: favoriteMaps,
      playedMaps: playedMaps,
    );
  }
}
