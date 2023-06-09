// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Classe pour les options Firebase par défaut, utilisées avec vos applications Firebase.
///
/// Exemple d'utilisation :
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  // Récupère les options Firebase pour la plateforme actuelle
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        // Lance une erreur si les options Firebase par défaut n'ont pas été configurées pour la plateforme cible
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ${defaultTargetPlatform.toString()} - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // Options Firebase pour la plateforme Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAnYOtGk2HThoRuDFBtELZi-eMff7suj7c',
    appId: '1:789073274063:android:551faa3f1869e5f735c3ba',
    messagingSenderId: '789073274063',
    projectId: 'masyupetanque',
    databaseURL:
        'https://masyupetanque-default-rtdb.europe-west1.firebasedatabase.app',
    storageBucket: 'masyupetanque.appspot.com',
  );
}
