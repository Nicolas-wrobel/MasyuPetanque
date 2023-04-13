import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/widgets/game_grid_widget.dart';

class TimerData extends InheritedWidget {
  final Duration elapsedTime;

  const TimerData({
    Key? key,
    required this.elapsedTime,
    required Widget child,
  }) : super(key: key, child: child);

  static TimerData of(BuildContext context) {
    final TimerData? result =
        context.dependOnInheritedWidgetOfExactType<TimerData>();
    assert(result != null, 'No TimerData found in context');
    return result!;
  }

  @override
  bool updateShouldNotify(TimerData old) => elapsedTime != old.elapsedTime;
}

class GameScreen extends StatefulWidget {
  final String mapId;

  const GameScreen({Key? key, required this.mapId}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GlobalKey<_TimerTextState> timerTextStateKey =
      GlobalKey<_TimerTextState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final gameRepository = GameRepository(userRepository: userRepository);
    final mapStream =
        gameRepository.getMapStreamById(widget.mapId).asBroadcastStream();

    // Créez une instance de TimerText avec la clé timerTextStateKey
    TimerText timerTextWidget = TimerText(key: timerTextStateKey);

    // Utilisez timerTextWidget pour créer une instance de TimerData
    TimerData _timerData = TimerData(
      elapsedTime: timerTextStateKey.currentState!.getElapsedTime(),
      child: timerTextWidget,
    );

    return TimerData(
        elapsedTime: timerTextStateKey.currentState!.getElapsedTime(),
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _timerData,
              StreamBuilder<Map<String, dynamic>>(
                stream: mapStream,
                builder: (BuildContext context,
                    AsyncSnapshot<Map<String, dynamic>> snapshot) {
                  if (snapshot.hasData) {
                    GameMap gameGrid =
                        GameMap.fromMap(snapshot.data!, widget.mapId);

                    final GlobalKey<GameGridWidgetState> gameGridWidgetKey =
                        GlobalKey<GameGridWidgetState>();

                    GameGridWidget gameGridWidget = GameGridWidget(
                      key: gameGridWidgetKey,
                      gameMap: gameGrid,
                      onMapSolved: () {
                        timerTextStateKey.currentState!.stopTimer();
                      },
                    );

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
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: TimerData(
                            elapsedTime: timerTextStateKey.currentState!
                                .getElapsedTime(),
                            child: AspectRatio(
                              aspectRatio:
                                  gameGrid.grid.width / gameGrid.grid.height,
                              child: gameGridWidget,
                            ),
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
                                    timerTextStateKey.currentState!
                                        .resetTimer();
                                    gameGridWidgetKey.currentState!.clear();
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

class TimerText extends StatefulWidget {
  const TimerText({Key? key}) : super(key: key);

  @override
  _TimerTextState createState() => _TimerTextState();
}

class _TimerTextState extends State<TimerText> with TickerProviderStateMixin {
  late AnimationController _timerController;
  ValueNotifier<Duration> elapsedTime = ValueNotifier(Duration.zero);

  @override
  void initState() {
    super.initState();

    _timerController = AnimationController(
      vsync: this,
      duration: const Duration(hours: 1),
    );

    _timerController.forward();
  }

  void stopTimer() {
    setState(() {
      _timerController.stop();
    });
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
        elapsedTime.value = _timerController.duration! * _timerController.value;

        int minutes = elapsedTime.value.inMinutes;
        int seconds = elapsedTime.value.inSeconds % 60;
        int milliseconds = elapsedTime.value.inMilliseconds % 1000 ~/ 10;

        String timerText =
            '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${milliseconds.toString().padLeft(2, '0')}';
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

  Duration getElapsedTime() {
    return _timerController.duration! * _timerController.value;
  }
}
