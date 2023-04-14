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

  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/startup':
        return MaterialPageRoute(builder: (_) => StartupScreen.create());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen.create());
      case '/game':
        return MaterialPageRoute(builder: (_) => const GameScreen());
      case '/map_creator':
        return MaterialPageRoute(builder: (_) => const MapCreatorScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => StartupScreen.create());
    }
  }

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
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
