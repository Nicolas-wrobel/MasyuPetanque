import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';

import 'package:masyu_petanque/src/models/game_grid.dart';

class GameRepository {
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  late DatabaseReference _databaseReference;
  final UserRepository _userRepository;

  // Constructeur de la classe GameRepository
  GameRepository({required UserRepository userRepository})
      : _userRepository = userRepository {
    _databaseReference = _firebaseDatabase.ref();
  }

  // Méthode pour tester l'accès à la base de données
  Future<void> testDatabaseAccess() async {
    String userId = 'user1_id';
    DatabaseReference userRef = _databaseReference.child('users/$userId');

    DatabaseEvent dataSnapshot = await userRef.once();
    if (kDebugMode) {
      print('User data: ${dataSnapshot.snapshot.value}');
    }

    String mapId = 'map1_id';
    DatabaseReference mapRef = _databaseReference.child('maps/$mapId');

    dataSnapshot = await mapRef.once();
    if (kDebugMode) {
      print('Map data: ${dataSnapshot.snapshot.value}');
    }
  }

  // Méthode pour obtenir un flux de données d'une carte par son ID
  Stream<Map<String, dynamic>> getMapStreamById(String mapId) {
    return _databaseReference.child('maps/$mapId').onValue.map((event) {
      final Map<dynamic, dynamic>? mapData =
          event.snapshot.value as Map<dynamic, dynamic>?;

      if (mapData != null) {
        Map<String, dynamic> mapDataWithId = mapData.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );
        mapDataWithId['id'] = mapId;
        return mapDataWithId;
      } else {
        throw Exception('Map not found with id: $mapId');
      }
    });
  }

  // Méthode pour obtenir un flux de tous les ID de cartes
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

  // Méthode pour obtenir un flux de toutes les cartes
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

  // Méthode pour obtenir un flux des cartes favorites de l'utilisateur
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
          return mapDataWithId;
        }).toList();
      } else {
        return [];
      }
    });
  }

  // Méthode pour créer une nouvelle carte
  Future<String> createMap({
    required int height,
    required int width,
    required List<Map<String, int>> blackPoints,
    required List<Map<String, int>> whitePoints,
    required String name,
  }) async {
    //
    // final authorId = _userRepository.getCurrentUser()?.uid;

    //
    // if (authorId == null) {
    //   throw Exception('No user is currently signed in');
    // }

    // Nouvelle référence pour la carte
    final mapRef = _databaseReference.child('maps').push();

    // Date de création de la carte
    final creationDate = DateTime.now();

    // Créer l'objet mapData
    // Construisez l'objet mapData

    final mapData = {
      'author': _userRepository.getCurrentUser()?.displayName,
      'creation_date': creationDate.millisecondsSinceEpoch,
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

    // Enregistrer la nouvelle carte dans la base de données
    await mapRef.set(mapData);

    // Retourner l'ID de la nouvelle carte
    return mapRef.key ?? '';
  }

  // Méthode pour enregistrer une partie jouée par un utilisateur
  Future<void> saveAGamePlayedByAUser({
    required String mapId,
    required int timer,
  }) async {
    final userId = _userRepository.getCurrentUser()?.uid;

    if (userId == null) {
      throw Exception('No user is currently signed in');
    }

    bool haveToUpdateRanking = false;

    final userPlayedMapsRef =
        _databaseReference.child('users/$userId/played_maps');
    final userPlayedMapsDataSnapshot =
        await userPlayedMapsRef.child(mapId).once();
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    if (!userPlayedMapsDataSnapshot.snapshot.exists) {
      await userPlayedMapsRef.child(mapId).set({
        'best_time': timer,
        'history': {timestamp: timer}
      });
      haveToUpdateRanking = true;
    } else {
      final oldBestTime = (userPlayedMapsDataSnapshot.snapshot.value
          as Map<dynamic, dynamic>)['best_time'];
      if (timer < oldBestTime) {
        await userPlayedMapsRef.child(mapId).update({'best_time': timer});
        haveToUpdateRanking = true;
      }
      final userPlayedMapHistoryRef =
          _databaseReference.child('users/$userId/played_maps/$mapId/history');
      await userPlayedMapHistoryRef.update({timestamp.toString(): timer});
    }

    if (haveToUpdateRanking) {
      final mapRankingRef = _databaseReference.child('maps/$mapId/ranking');
      final mapRankingDataSnapshot = await mapRankingRef.once();
      final mapRankingData =
          mapRankingDataSnapshot.snapshot.value as List<dynamic>;
      final List<Map<String, dynamic>> mapRankingList = mapRankingData
          .where((entry) => entry != null)
          .map<Map<String, dynamic>>((entry) {
        return {entry.keys.first.toString(): entry.values.first as int};
      }).toList();

      int currentUserRankingIndex = mapRankingList
          .indexWhere((mapEntry) => mapEntry.keys.contains(userId));

      if (currentUserRankingIndex != -1) {
        mapRankingList.removeAt(currentUserRankingIndex);
      }

      int insertIndex = mapRankingList
          .indexWhere((mapEntry) => timer < mapEntry.values.first);

      if (insertIndex == -1) insertIndex = mapRankingList.length;

      mapRankingList.insert(insertIndex, {userId: timer});

      await mapRankingRef.set(mapRankingList);
    }
  }

  // Méthode pour ajouter une carte aux favoris
  Future<void> addMapToFavorites(String mapId) async {
    final userId = _userRepository.getCurrentUser()?.uid;

    if (userId == null) {
      throw Exception('No user is currently signed in');
    }

    final userFavoriteMapsRef =
        _databaseReference.child('users/$userId/favorite_maps');
    final newFavoriteMapRef = userFavoriteMapsRef.push();
    await newFavoriteMapRef.set({'map_id': mapId});
  }

  // Méthode pour supprimer une carte des favoris
  Future<void> removeMapFromFavorites(String mapId) async {
    final userId = _userRepository.getCurrentUser()?.uid;

    if (userId == null) {
      throw Exception('No user is currently signed in');
    }

    final userFavoriteMapsRef =
        _databaseReference.child('users/$userId/favorite_maps');
    DatabaseEvent event = await userFavoriteMapsRef.once();

    print(event.snapshot.value);

    if (event.snapshot.value != null) {
      final Map<dynamic, dynamic> favoriteMapsData =
          event.snapshot.value as Map<dynamic, dynamic>;

      String mapKeyToRemove = "";
      favoriteMapsData.forEach((key, value) {
        if (value['map_id'] == mapId) {
          mapKeyToRemove = key;
        }
      });

      if (mapKeyToRemove.isNotEmpty) {
        await userFavoriteMapsRef.child(mapKeyToRemove).remove();
      }
    }
  }

  // Méthode pour récupérer toutes les cartes une fois
  Future<List<GameMap>> getAllMapsOnce() async {
    DatabaseEvent event = await _databaseReference.child('maps').once();
    final Map<dynamic, dynamic>? mapsData =
        event.snapshot.value as Map<dynamic, dynamic>?;

    if (kDebugMode) {
      print("mapsData: $mapsData");
    }

    if (mapsData != null) {
      return mapsData.entries.map<GameMap>((entry) {
        final String key = entry.key.toString();
        final Map<dynamic, dynamic> value = entry.value;
        if (kDebugMode) {
          print("Juste une map: $value");
        }

        final Map<String, dynamic> mapDataWithId = {
          for (var k in value.keys) k.toString(): value[k],
        };
        mapDataWithId['id'] = key;
        return GameMap.fromMap(mapDataWithId, key);
      }).toList();
    } else {
      return [];
    }
  }

  // Méthode pour obtenir un flux de données d'une carte locale par son ID
  Stream<GameMap> getLocalMapStreamById(String mapId) {
    return _databaseReference.child('maps/$mapId').onValue.map((event) {
      final mapData = event.snapshot.value as Map<String, dynamic>;
      return GameMap.fromMap(mapData, event.snapshot.key!);
    });
  }
}
