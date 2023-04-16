import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/screens/home_screen.dart';

class StartupScreen extends StatefulWidget {
  final UserRepository _userRepository;

  const StartupScreen._({Key? key, required UserRepository userRepository})
      : _userRepository = userRepository,
        super(key: key);

  // Static method to create an instance of StartupScreen
  static StartupScreen create({Key? key}) {
    final userRepository = UserRepository();
    return StartupScreen._(key: key, userRepository: userRepository);
  }

  @override
  _StartupScreenState createState() => _StartupScreenState();
}

class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<String?> _isUserAuthenticated() async {
    User? currentUser = widget._userRepository.getCurrentUser();
    if (currentUser != null) {
      return null;
    } else {
      User? user = await widget._userRepository.signInWithGoogle();
      if (user != null) {
        return null;
      } else {
        return "Sign in failed. Please try again.";
      }
    }
  }

  void _handleTap(BuildContext context) async {
    String? authError = await _isUserAuthenticated();
    if (authError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(authError),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen.create(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            const Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Masyu',
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (BuildContext context, Widget? child) {
                  return Opacity(
                    opacity: _animationController.value,
                    child: const Text(
                      '[ Appuyer sur l\'écran pour jouer ]',
                      style: TextStyle(fontSize: 25),
                    ),
                  );
                },
              ),
            ),
            Positioned.fill(
              child: InkWell(
                onTap: () => _handleTap(context),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
