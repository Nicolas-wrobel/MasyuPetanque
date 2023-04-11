import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
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
    print('Map data: ${dataSnapshot.snapshot.value}');
  }
}
