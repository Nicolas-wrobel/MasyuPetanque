import 'dart:async';
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
    final mapStream = gameRepository.getMapStreamById(mapId);

    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TimerText(),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<Map<String, dynamic>>(
              stream: mapStream,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, dynamic>> snapshot) {
                if (snapshot.hasData) {
                  GameGrid gameGrid = GameGrid.fromMap(mapId, snapshot.data!);
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: AspectRatio(
                        aspectRatio: gameGrid.width! / gameGrid.height!,
                        child: GameGridWidget(gameGrid: gameGrid),
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TimerText extends StatefulWidget {
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
        return Text(timerText, style: TextStyle(fontSize: 24));
      },
    );
  }
}
