import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';

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

  Future<String> saveAGamePlayedByAUser({
    required String mapId,
    required int timer,
  }) async {
    // Obtenez l'UID de l'utilisateur connecté
    final userId = _userRepository.getCurrentUser()?.uid;

    // Vérifiez si un utilisateur est connecté
    if (userId == null) {
      throw Exception('No user is currently signed in');
    }

    // Mettez à jour la liste des cartes jouées par l'utilisateur : users/$userId/played_maps
    final userPlayedMapsRef =
        _databaseReference.child('users/$userId/played_maps');
    final userPlayedMapsDataSnapshot = await userPlayedMapsRef.once();
    final userPlayedMapsData = userPlayedMapsDataSnapshot.snapshot.value;
    if (userPlayedMapsData != null) {
      final userPlayedMapsDataMap = userPlayedMapsData as Map;
      final userPlayedMapsDataMapKeys = userPlayedMapsDataMap.keys;
      if (!userPlayedMapsDataMapKeys.contains(mapId)) {
        await userPlayedMapsRef.update({mapId: true});
      }
    } else {
      await userPlayedMapsRef.set({mapId: true});
    }

    // Mettez à jour users/$userId/played_maps/$mapId/best_time
    final userPlayedMapBestTimeRef =
        _databaseReference.child('users/$userId/played_maps/$mapId/best_time');
    final userPlayedMapBestTimeDataSnapshot =
        await userPlayedMapBestTimeRef.once();
    final userPlayedMapBestTimeData =
        userPlayedMapBestTimeDataSnapshot.snapshot.value;
    if (userPlayedMapBestTimeData != null) {
      final userPlayedMapBestTimeDataInt = userPlayedMapBestTimeData as int;
      if (timer < userPlayedMapBestTimeDataInt) {
        await userPlayedMapBestTimeRef.set(timer);
      }
    } else {
      await userPlayedMapBestTimeRef.set(timer);
    }

    // Ajoutez le temps de jeu à la liste des temps de jeu de la carte : users/$userId/played_maps/$mapId/history/{timestamp: timer}
    final userPlayedMapHistoryRef =
        _databaseReference.child('users/$userId/played_maps/$mapId/history');
    final userPlayedMapHistoryDataSnapshot =
        await userPlayedMapHistoryRef.once();
    final userPlayedMapHistoryData =
        userPlayedMapHistoryDataSnapshot.snapshot.value;
    if (userPlayedMapHistoryData != null) {
      final timestamp = DateTime.now().toIso8601String();
      await userPlayedMapHistoryRef.update({timestamp: timer});
    } else {
      final timestamp = DateTime.now().toIso8601String();
      await userPlayedMapHistoryRef.set({timestamp: timer});
    }

    return 'ok';
  }
}
