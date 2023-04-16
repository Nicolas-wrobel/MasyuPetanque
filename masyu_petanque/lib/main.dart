import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/screens/game_screen.dart';
import 'package:masyu_petanque/src/screens/home_screen.dart';
import 'package:masyu_petanque/src/screens/map_creator_screen.dart';
import 'package:masyu_petanque/src/screens/profile_screen.dart';
import 'package:masyu_petanque/src/screens/startup_screen.dart';
import 'package:masyu_petanque/src/repositories/database/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase si l'application est en mode debug
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
  const MainApp({Key? key}) : super(key: key);

  // Méthode pour gérer les routes de l'application
  Route<dynamic> _onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/startup':
        return MaterialPageRoute(builder: (_) => StartupScreen.create());
      case '/home':
        return MaterialPageRoute(builder: (_) => HomeScreen.create());
      case '/game':
        return MaterialPageRoute(
            builder: (_) => const GameScreen(
                  mapId: "map1_id",
                ));
      case '/map_creator':
        return MaterialPageRoute(builder: (_) => MapCreatorScreen());
      case '/profile':
        return MaterialPageRoute(builder: (_) => const ProfileScreen());
      default:
        return MaterialPageRoute(builder: (_) => StartupScreen.create());
    }
  }

  // Construire la méthode pour l'application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masyu Game',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.black,
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
      ),
      initialRoute: '/startup',
      onGenerateRoute: _onGenerateRoute,
    );
  }
}
