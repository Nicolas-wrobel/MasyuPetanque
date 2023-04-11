import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';

class GameRepository {
  final DatabaseReference _databaseReference;

  GameRepository() : _databaseReference = FirebaseDatabase.instance.ref();

  Future<void> testDatabaseAccess() async {
    // Lire les données d'un utilisateur
    String userId = 'user1_id';
    DatabaseReference userRef = _databaseReference.child('users/$userId');

    DatabaseEvent dataSnapshot = await userRef.once();
    if (kDebugMode) {
      print('User data: ${dataSnapshot.snapshot.value}');
    }

    // Lire les données d'une carte
    String mapId = 'map1_id';
    DatabaseReference mapRef = _databaseReference.child('maps/$mapId');

    dataSnapshot = await mapRef.once();
    if (kDebugMode) {
      print('Map data: ${dataSnapshot.snapshot.value}');
    }
  }

  Stream<Map<String, dynamic>> getMapStreamById(String mapId) {
    return _databaseReference.child('maps/$mapId').onValue.map((event) {
      final Map<dynamic, dynamic>? mapData =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (mapData != null) {
        Map<String, dynamic> mapDataWithId = mapData.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );
        mapDataWithId['id'] = mapId; // Add the mapId to the map data.
        return mapDataWithId;
      } else {
        throw Exception('Map not found with id: $mapId');
      }
    });
  }

  Stream<List<String>> getAllMapIds() {
    return _databaseReference.child('maps').onValue.map((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> mapsData = event.snapshot.value as Map;
        return mapsData.keys.map<String>((key) => key.toString()).toList();
      } else {
        return [];
      }
    });
  }

  Stream<List<Map<String, dynamic>>> getAllMaps() {
    return _databaseReference.child('maps').onValue.map((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> mapsData = event.snapshot.value as Map;
        return mapsData.entries.map<Map<String, dynamic>>((entry) {
          final String key = entry.key.toString();
          final Map<dynamic, dynamic> value = entry.value;
          final Map<String, dynamic> mapDataWithId = value.map<String, dynamic>(
            (key, value) => MapEntry(key.toString(), value),
          );
          mapDataWithId['id'] = key;
          return mapDataWithId;
        }).toList();
      } else {
        return [];
      }
    });
  }
}
