import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/widgets/game_grid_widget.dart';
import 'package:provider/provider.dart';
import 'package:masyu_petanque/src/models/timer_model.dart';

// Classe principale de l'écran de jeu
class GameScreen extends StatelessWidget {
  final String mapId;

  const GameScreen({Key? key, required this.mapId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Initialisation des repositories
    final userRepository = UserRepository();
    final gameRepository = GameRepository(userRepository: userRepository);

    // Récupération du flux de données de la carte
    final mapStream =
        gameRepository.getMapStreamById(mapId).asBroadcastStream();

    // Création de l'écran de jeu avec le timer et le widget de la grille de jeu
    return ChangeNotifierProvider(
        create: (context) => TimerModel(),
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Création du StreamBuilder pour afficher la grille de jeu
              StreamBuilder<Map<String, dynamic>>(
                stream: mapStream,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    // Création de l'objet GameMap
                    GameMap gameGrid = GameMap.fromMap(snapshot.data!, mapId);

                    // Création du widget GameGridWidget
                    final GlobalKey<GameGridWidgetState> gameGridWidgetKey =
                        GlobalKey<GameGridWidgetState>();

                    GameGridWidget gameGridWidget = GameGridWidget(
                      key: gameGridWidgetKey,
                      gameMap: gameGrid,
                    );

                    // Création du widget TimerText
                    TimerText timerTextWidget = const TimerText();

                    // Affichage de l'écran de jeu
                    return Column(
                      children: [
                        // Affichage des informations de la carte
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text(
                                gameGrid.name,
                                style: const TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Créé par ${gameGrid.author}",
                                style: const TextStyle(
                                    fontSize: 18, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
                        // Affichage du timer
                        timerTextWidget,
                        // Affichage de la grille de jeu
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: AspectRatio(
                            aspectRatio:
                                gameGrid.grid.width / gameGrid.grid.height,
                            child: gameGridWidget,
                          ),
                        ),
                        // Affichage des boutons de contrôle
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Bouton "Recommencer"
                              ElevatedButton(
                                onPressed: () async {
                                  bool? resetGame = await showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Recommencer'),
                                        content: const Text(
                                            'Êtes-vous sûr de vouloir recommencer?'),
                                        actions: [
                                          // Bouton "Non"
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Non'),
                                          ),
                                          // Bouton "Oui"
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Oui'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                  // Si l'utilisateur décide de recommencer
                                  if (resetGame != null && resetGame) {
                                    gameGridWidgetKey.currentState!
                                        .restartTimer();
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                child: const Text(
                                  'Recommencer',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // Bouton "Clear"
                              ElevatedButton(
                                onPressed: () =>
                                    gameGridWidgetKey.currentState!.clear(),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white),
                                child: const Text(
                                  'Clear',
                                  style: TextStyle(
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              // Bouton "Undo"
                              IconButton(
                                onPressed: () {
                                  gameGridWidgetKey.currentState!.undo();
                                },
                                icon: const Icon(Icons.undo),
                                color: Colors.black,
                                iconSize: 24.0,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  } else if (snapshot.hasError) {
                    // En cas d'erreur
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else {
                    // Affichage d'un indicateur de progression
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ));
  }
}

// Classe pour le widget du texte du timer
class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Utilisation du Consumer pour récupérer le modèle du timer
    return Consumer<TimerModel>(
      builder: (BuildContext context, TimerModel timerModel, Widget? child) {
        // Création du widget pour afficher le temps écoulé
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(timerModel.elapsedTime,
              style: const TextStyle(fontSize: 24)),
        );
      },
    );
  }
}
