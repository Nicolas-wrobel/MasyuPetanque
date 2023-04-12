import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/screens/game_screen.dart';

class StartupScreen extends StatelessWidget {
  StartupScreen({super.key});

  final GameRepository _gameRepository = GameRepository();
  final UserRepository _userRepository = UserRepository();
  final String mapId = 'map1_id';

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
                    User? user = await _userRepository.signInWithGoogle();
                    if (user != null) {
                      if (kDebugMode) {
                        print('User: ${user.displayName}');
                      }
                    } else {
                      if (kDebugMode) {
                        print('User is null');
                      }
                    }
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
