import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

class UserRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseDatabase _firebaseDatabase = FirebaseDatabase.instance;
  late DatabaseReference _databaseReference;

  UserRepository() {
    _databaseReference = _firebaseDatabase.ref();
  }

  Future<User?> signInWithGoogle() async {
    if (kDebugMode) {
      print("signInWithGoogle");
    }
    try {
      final GoogleSignInAccount? googleSignInAccount =
          await _googleSignIn.signIn();
      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        final UserCredential userCredential =
            await _auth.signInWithCredential(credential);
        final User? user = userCredential.user;

        if (user != null) {
          // Checking if the user is new or already exists
          final isNewUser = userCredential.additionalUserInfo!.isNewUser;
          if (isNewUser) {
            if (kDebugMode) {
              print("New user created");
            }

            // Create a new user instance in the database
            final newUser = {
              "favourites_maps": [],
              "first_connection": DateTime.now().toIso8601String(),
              "first_name": user.displayName?.split(' ')[0],
              "last_connection": DateTime.now().toIso8601String(),
              "last_name": user.displayName!.split(' ').length > 1
                  ? user.displayName?.split(' ')[1]
                  : '',
              "played_maps": {}
            };

            await _databaseReference.child('users/${user.uid}').set(newUser);
          } else {
            if (kDebugMode) {
              print("User named ${user.displayName} already exists");
            }
            // Update the last connection time
            await _databaseReference
                .child('users/${user.uid}/last_connection')
                .set(DateTime.now().toIso8601String());
          }
          return user;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
    return null;
  }

  User? getCurrentUser() {
    if (kDebugMode) {
      print("getCurrentUser ${_auth.currentUser}");
    }
    return _auth.currentUser;
  }

  Future<void> signOut() async {
    if (kDebugMode) {
      print("signOut");
    }
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
