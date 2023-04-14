import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/widgets/game_grid_widget.dart';
import 'package:provider/provider.dart';
import 'package:masyu_petanque/src/models/timer_model.dart';

class GameScreen extends StatelessWidget {
  final String mapId;

  const GameScreen({Key? key, required this.mapId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final gameRepository = GameRepository(userRepository: userRepository);
    final mapStream =
        gameRepository.getMapStreamById(mapId).asBroadcastStream();

    return ChangeNotifierProvider(
        create: (context) => TimerModel(),
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              StreamBuilder<Map<String, dynamic>>(
                stream: mapStream,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    GameMap gameGrid = GameMap.fromMap(snapshot.data!, mapId);

                    final GlobalKey<GameGridWidgetState> gameGridWidgetKey =
                        GlobalKey<GameGridWidgetState>();

                    GameGridWidget gameGridWidget = GameGridWidget(
                      key: gameGridWidgetKey,
                      gameMap: gameGrid,
                    );

                    TimerText timerTextWidget = const TimerText();

                    return Column(
                      children: [
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
                        timerTextWidget,
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: AspectRatio(
                            aspectRatio:
                                gameGrid.grid.width / gameGrid.grid.height,
                            child: gameGridWidget,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
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
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Non'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Oui'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
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
                    return Center(child: Text('Erreur: ${snapshot.error}'));
                  } else {
                    return const Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ));
  }
}

class TimerText extends StatelessWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<TimerModel>(
      builder: (BuildContext context, TimerModel timerModel, Widget? child) {
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
