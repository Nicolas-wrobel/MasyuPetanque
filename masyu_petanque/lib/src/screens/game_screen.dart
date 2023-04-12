import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/widgets/game_grid_widget.dart';

class GameScreen extends StatelessWidget {
  final String mapId;

  const GameScreen({Key? key, required this.mapId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final gameRepository = GameRepository(userRepository: userRepository);
    final mapStream =
        gameRepository.getMapStreamById(mapId).asBroadcastStream();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          StreamBuilder<Map<String, dynamic>>(
            stream: mapStream,
            builder: (BuildContext context,
                AsyncSnapshot<Map<String, dynamic>> snapshot) {
              if (snapshot.hasData) {
                GameGrid gameGrid = GameGrid.fromMap(mapId, snapshot.data!);

                final GlobalKey<GameGridWidgetState> gameGridWidgetKey =
                    GlobalKey<GameGridWidgetState>();

                GameGridWidget gameGridWidget = GameGridWidget(
                  key: gameGridWidgetKey,
                  gameGrid: gameGrid,
                );

                final GlobalKey<_TimerTextState> timerTextStateKey =
                    GlobalKey<_TimerTextState>();
                TimerText timerTextWidget = TimerText(key: timerTextStateKey);

                return Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            gameGrid.name!,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            "Créé par ${gameGrid.author!}",
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
                        aspectRatio: gameGrid.width! / gameGrid.height!,
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
                                timerTextStateKey.currentState!.resetTimer();
                                gameGridWidgetKey.currentState!.clear();
                              }
                            },
                            child: const Text('Recommencer'),
                          ),
                          ElevatedButton(
                            onPressed: () =>
                                gameGridWidgetKey.currentState!.clear(),
                            child: const Text('Clear'),
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
    );
  }
}

class TimerText extends StatefulWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  _TimerTextState createState() => _TimerTextState();
}

class _TimerTextState extends State<TimerText> with TickerProviderStateMixin {
  late AnimationController _timerController;

  @override
  void initState() {
    super.initState();

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    );

    _timerController.forward();
  }

  @override
  void dispose() {
    _timerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _timerController,
      builder: (BuildContext context, Widget? child) {
        Duration elapsedTime =
            _timerController.duration! * _timerController.value;
        String timerText =
            '${elapsedTime.inMinutes.toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}.${(elapsedTime.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}';
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.black,
              width: 1,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          child: Text(timerText, style: const TextStyle(fontSize: 24)),
        );
      },
    );
  }

  void resetTimer() {
    setState(() {
      _timerController.reset();
      _timerController.forward();
    });
  }
}
