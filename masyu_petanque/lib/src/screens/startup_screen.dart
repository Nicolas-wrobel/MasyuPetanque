import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/screens/home_screen.dart';

class StartupScreen extends StatelessWidget {
  final UserRepository _userRepository;

  const StartupScreen._({Key? key, required UserRepository userRepository})
      : _userRepository = userRepository,
        super(key: key);

  // Static method to create an instance of StartupScreen
  static StartupScreen create({Key? key}) {
    final userRepository = UserRepository();
    return StartupScreen._(key: key, userRepository: userRepository);
  }

  Future<bool> _isUserAuthenticated() async {
    User? currentUser = _userRepository.getCurrentUser();
    if (currentUser != null) {
      return true;
    } else {
      User? user = await _userRepository.signInWithGoogle();
      return user != null;
    }
  }

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
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FutureBuilder<bool>(
                          future: _isUserAuthenticated(),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.done) {
                              if (snapshot.hasData && snapshot.data == true) {
                                return HomeScreen.create(key: key);
                              } else {
                                return const Text('Error');
                              }
                            } else {
                              return const CircularProgressIndicator();
                            }
                          },
                        ),
                      ),
                    );
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
