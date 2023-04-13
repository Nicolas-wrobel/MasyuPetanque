import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/repositories/database/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:masyu_petanque/src/screens/game_screen.dart';
import 'package:masyu_petanque/src/screens/home_screen.dart';
import 'package:masyu_petanque/src/screens/map_creator_screen.dart';
import 'package:masyu_petanque/src/screens/profile_screen.dart';
import 'package:masyu_petanque/src/screens/startup_screen.dart';

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
    return MaterialApp(
      title: 'Masyu Game',
      theme: ThemeData(
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
      ),
      initialRoute: '/startup',
      routes: {
        '/startup': (context) => StartupScreen.create(),
        '/home': (context) => HomeScreen.create(),
        '/game': (context) => const GameScreen(
              mapId: "map1_id",
            ),
        '/map_creator': (context) => const MapCreatorScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
    );
  }
}
