import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';

import '../../models/game_grid.dart';

class GameRepository {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  late DatabaseReference _databaseReference;
  final UserRepository _userRepository;

  GameRepository({required UserRepository userRepository})
      : _userRepository = userRepository {
    _databaseReference = _firebaseDatabase.ref();
  }

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

  Stream<List<Map<String, dynamic>>> getUserFavoriteMaps() {
    return _databaseReference
        .child('users/${_userRepository.getCurrentUser()?.uid}/favorite_maps')
        .onValue
        .map((event) {
      if (event.snapshot.value != null) {
        final Map<dynamic, dynamic> favoriteMapsData =
            event.snapshot.value as Map;
        return favoriteMapsData.entries.map<Map<String, dynamic>>((entry) {
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

  Future<String> createMap({
    required int height,
    required int width,
    required List<Map<String, int>> blackPoints,
    required List<Map<String, int>> whitePoints,
    required String name,
  }) async {
    // Obtenez l'UID de l'utilisateur connecté
    final authorId = _userRepository.getCurrentUser()?.uid;

    // Vérifiez si un utilisateur est connecté
    if (authorId == null) {
      throw Exception('No user is currently signed in');
    }

    // Créez une nouvelle référence pour la carte
    final mapRef = _databaseReference.child('maps').push();

    // Obtenez la date de création de la carte
    final creationDate = DateTime.now();

    // Construisez l'objet mapData
    final mapData = {
      'author': authorId,
      'creation_date': creationDate.toIso8601String(),
      'dimensions': {
        'height': height,
        'width': width,
      },
      'grid': {
        'black_points': blackPoints,
        'white_points': whitePoints,
      },
      'name': name,
    };

    // Enregistrez la nouvelle carte dans la base de données
    await mapRef.set(mapData);

    // Retournez l'ID de la nouvelle carte
    return mapRef.key ?? '';
  }

  Future<void> saveAGamePlayedByAUser({
    required String mapId,
    required int timer,
  }) async {
    // Get the UID of the signed-in user
    final userId = _userRepository.getCurrentUser()?.uid;

    // Check if a user is signed in
    if (userId == null) {
      throw Exception('No user is currently signed in');
    }

    // Update the list of played maps by the user: users/$userId/played_maps
    final userPlayedMapsRef =
        _databaseReference.child('users/$userId/played_maps');
    await userPlayedMapsRef.update({mapId: true});

    // Update users/$userId/played_maps/$mapId/best_time
    final userPlayedMapBestTimeRef =
        _databaseReference.child('users/$userId/played_maps/$mapId/best_time');
    final userPlayedMapBestTimeDataSnapshot =
        await userPlayedMapBestTimeRef.once();
    final userPlayedMapBestTimeData =
        userPlayedMapBestTimeDataSnapshot.snapshot.value;

    if (userPlayedMapBestTimeData == null ||
        timer < (userPlayedMapBestTimeData as num)) {
      await userPlayedMapBestTimeRef.set(timer);
    }

    // Add the playtime to the list of playtimes of the map: users/$userId/played_maps/$mapId/history/{timestamp: timer}
    final userPlayedMapHistoryRef =
        _databaseReference.child('users/$userId/played_maps/$mapId/history');
    final timestamp = DateTime.now().toIso8601String();
    await userPlayedMapHistoryRef.update({timestamp: timer});

    // Update the ranking of the map: maps/$mapId/ranking/$rank/{user_id: timer}
    final mapRankingRef = _databaseReference.child('maps/$mapId/ranking');
    final mapRankingDataSnapshot = await mapRankingRef.once();
    final mapRankingData = mapRankingDataSnapshot.snapshot.value;

    if (mapRankingData != null) {
      final Map<dynamic, dynamic> mapRankingDataMap =
          mapRankingData as Map<dynamic, dynamic>;
      final List<int> mapRankingDataMapKeysInt = mapRankingDataMap.keys
          .map<int>((key) => int.parse(key))
          .toList(growable: false);

      int currentUserRankingIndex = mapRankingDataMapKeysInt
          .indexWhere((key) => mapRankingDataMap[key.toString()] == userId);

      int insertIndex = mapRankingDataMapKeysInt
          .indexWhere((key) => timer < mapRankingDataMap[key.toString()]);

      if (insertIndex == -1) insertIndex = mapRankingDataMapKeysInt.length;

      if (currentUserRankingIndex == -1) {
        // User is not currently in the ranking
        mapRankingDataMapKeysInt.insert(insertIndex, timer);
      } else {
        // User is already in the ranking
        if (timer <
            mapRankingDataMap[
                mapRankingDataMapKeysInt[currentUserRankingIndex].toString()]) {
          // Update the existing user's time
          mapRankingDataMapKeysInt.removeAt(currentUserRankingIndex);
          mapRankingDataMapKeysInt.insert(insertIndex, timer);
        }
      }
      await _updateRankingData(mapRankingRef, mapRankingDataMapKeysInt, userId);
    } else {
      // No existing ranking data, create a new entry for the user
      await mapRankingRef.child('1').set({userId: timer});
    }
  }

  Future<void> _updateRankingData(DatabaseReference mapRankingRef,
      List<int> mapRankingDataMapKeysInt, String userId) async {
    int rank = 1;
    for (int key in mapRankingDataMapKeysInt) {
      await mapRankingRef.child(rank.toString()).update({userId: key});
      rank++;
    }
  }

  Future<void> addMapToFavorites(String mapId) async {
    // Get the UID of the signed-in user
    final userId = _userRepository.getCurrentUser()?.uid;

    // Check if a user is signed in
    if (userId == null) {
      throw Exception('No user is currently signed in');
    }

    // Update the list of favorite maps by the user: users/$userId/favorite_maps
    final userFavoriteMapsRef =
        _databaseReference.child('users/$userId/favorite_maps');
    await userFavoriteMapsRef.update({mapId: true});
  }

  Future<void> removeMapFromFavorites(String mapId) async {
    // Get the UID of the signed-in user
    final userId = _userRepository.getCurrentUser()?.uid;

    // Check if a user is signed in
    if (userId == null) {
      throw Exception('No user is currently signed in');
    }

    // Update the list of favorite maps by the user: users/$userId/favorite_maps
    final userFavoriteMapsRef =
        _databaseReference.child('users/$userId/favorite_maps');
    await userFavoriteMapsRef.update({mapId: null});
  }

  Future<List<GameMap>> getAllMapsOnce() async {
    DatabaseEvent event = await _databaseReference.child('maps').once();
    final Map<dynamic, dynamic>? mapsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (kDebugMode) {
      print("toutes les maps: $mapsData");
    }

    if (mapsData != null) {
      return mapsData.entries.map<GameMap>((entry) {
        final String key = entry.key.toString();
        final Map<dynamic, dynamic> value = entry.value;
        final Map<String, dynamic> mapDataWithId = value.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );
        mapDataWithId['id'] = key;
        return GameMap.fromMap(mapDataWithId, key);
      }).toList();
    } else {
      return [];
    }
  }

  Stream<GameMap> getLocalMapStreamById(String mapId) {
    return _databaseReference.child('maps/$mapId').onValue.map((event) {
      final mapData = event.snapshot.value as Map<String, dynamic>;
      return GameMap.fromMap(mapData, event.snapshot.key!);
    });
  }
}
