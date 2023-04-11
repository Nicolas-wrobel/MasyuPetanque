import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';

class StartupScreen extends StatelessWidget {
  StartupScreen({super.key});

  final GameRepository _gameRepository = GameRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Material(
        color: Colors.white,
        child: SafeArea(
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Masyu Game',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 24,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () async {
                    // Tester l'accès à la base de données
                    await _gameRepository.testDatabaseAccess();
                  },
                  child: Text(
                    '[ JOUER ]',
                    style: GoogleFonts.robotoSlab(
                      fontSize: 18,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
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
