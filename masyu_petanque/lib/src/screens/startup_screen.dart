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

  Future<String?> _isUserAuthenticated() async {
    User? currentUser = _userRepository.getCurrentUser();
    if (currentUser != null) {
      return null;
    } else {
      User? user = await _userRepository.signInWithGoogle();
      if (user != null) {
        return null;
      } else {
        return "Sign in failed. Please try again.";
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Material(
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FutureBuilder<String?>(
                            future: _isUserAuthenticated(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  // Show an error message to the user
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(snapshot.data!),
                                    ),
                                  );
                                  return const CircularProgressIndicator(); // Keep the loading indicator if authentication fails
                                } else {
                                  return HomeScreen.create(key: key);
                                }
                              } else {
                                return const CircularProgressIndicator();
                              }
                            },
                          ),
                        ),
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
      ),
    );
  }
}
