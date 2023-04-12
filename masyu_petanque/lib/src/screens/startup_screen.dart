import 'package:flutter/material.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/screens/game_screen.dart';

class StartupScreen extends StatelessWidget {
  StartupScreen({super.key});

  final GameRepository _gameRepository = GameRepository();
  final String mapId = 'map1_id';

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              const Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Masyu Game',
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // Tester l'accès à la base de données
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => GameGridScreen()),
                    );
                  },
                  child: const Text(
                    '[ JOUER ]',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
