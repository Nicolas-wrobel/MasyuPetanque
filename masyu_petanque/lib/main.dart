import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/repositories/database/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print("Firebase initializing...");
  }
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(const MainApp());
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Hello World!'),
        ),
      ),
    );
  }
}
