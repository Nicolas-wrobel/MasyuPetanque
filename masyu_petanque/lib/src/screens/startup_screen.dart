import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/screens/home_screen.dart';

// Définition de l'écran de démarrage
class StartupScreen extends StatefulWidget {
  final UserRepository _userRepository;

  // Constructeur privé pour initialiser le UserRepository
  const StartupScreen._({Key? key, required UserRepository userRepository})
      : _userRepository = userRepository,
        super(key: key);

  // Méthode statique pour créer une instance de StartupScreen
  static StartupScreen create({Key? key}) {
    final userRepository = UserRepository();
    return StartupScreen._(key: key, userRepository: userRepository);
  }

  @override
  _StartupScreenState createState() => _StartupScreenState();
}

// Le state pour l'écran de démarrage
class _StartupScreenState extends State<StartupScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  // Initialise l'animation
  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _animationController.repeat(reverse: true);
    super.initState();
  }

  // Libère les ressources lorsque le widget est retiré
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Vérifie si l'utilisateur est authentifié
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

  // Gère l'appui sur l'écran et lance l'authentification
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

  // Construit l'interface de l'écran de démarrage
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: SafeArea(
        child: Stack(
          children: [
            // Titre de l'application
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
            // Message animé pour appuyer sur l'écran
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
            // Gestionnaire de tap pour démarrer l'authentification et naviguer vers l'écran d'accueil
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
