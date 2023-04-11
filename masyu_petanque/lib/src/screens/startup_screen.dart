import 'package:flutter/material.dart';

class StartupScreen extends StatelessWidget {
  const StartupScreen({super.key});

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
                    style: TextStyle(fontSize: 24, color: Colors.black),
                  ),
                ),
              ),
              Center(
                child: GestureDetector(
                  onTap: () {
                    // TODO: Ajouter la connexion avec Google et la navigation vers l'écran d'accueil
                  },
                  child: const Text(
                    'JOUER',
                    style: TextStyle(fontSize: 18, color: Colors.black),
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
