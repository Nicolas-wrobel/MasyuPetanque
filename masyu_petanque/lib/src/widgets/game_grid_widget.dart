import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/models/timer_model.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/utils/game_checker.dart';
import 'package:masyu_petanque/src/widgets/grid_point_painter.dart';
import 'package:provider/provider.dart';

class GameGridWidget extends StatefulWidget {
  final GameMap gameMap;
  final bool isPreview;

  // Constructeur avec les propriétés du widget GameGrid
  const GameGridWidget({
    required this.gameMap,
    this.isPreview = false,
    Key? key,
  }) : super(key: key);

  @override
  GameGridWidgetState createState() => GameGridWidgetState();
}

class GameGridWidgetState extends State<GameGridWidget> {
  final List<List<int>> liaisons = [];
  late BuildContext dialogContext;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<TimerModel>(context, listen: false).start();
      }
    });
  }

  // Méthodes pour gérer le TimerModel
  void startTimer() {
    Provider.of<TimerModel>(context, listen: false).start();
  }

  void stopTimer() {
    Provider.of<TimerModel>(context, listen: false).stop();
  }

  void resetTimer() {
    Provider.of<TimerModel>(context, listen: false).reset();
  }

  void restartTimer() {
    stopTimer();
    resetTimer();
    clear();
    Provider.of<TimerModel>(context, listen: false).start();
  }

  // Méthodes pour gérer les liaisons dans la grille de jeu
  void undo() {
    setState(() {
      if (liaisons.isNotEmpty) {
        liaisons.removeLast();
      }
    });
  }

  void clear() {
    setState(() {
      liaisons.clear();
    });
  }

  // Méthode pour afficher la boîte de dialogue de victoire
  void _showVictoryDialog() {
    if (!mounted) return;
    final userRepository = UserRepository();
    final gameRepository = GameRepository(userRepository: userRepository);
    stopTimer();
    String elapsedTimeStr =
        Provider.of<TimerModel>(context, listen: false).elapsedTime;
    List<String> timeParts = elapsedTimeStr.split(':');
    int minutes = int.parse(timeParts[0]);
    List<String> secondsAndCentiseconds = timeParts[1].split('.');
    int seconds = int.parse(secondsAndCentiseconds[0]);
    int centiseconds = int.parse(secondsAndCentiseconds[1]);
    int totalTimeInCentiseconds =
        (minutes * 60 * 100) + (seconds * 100) + centiseconds;

    // Sauvegarder les données du jeu en utilisant les repositories
    gameRepository.saveAGamePlayedByAUser(
      mapId: widget.gameMap.id,
      timer: totalTimeInCentiseconds,
    );

    // Affichage de la boîte de dialogue de victoire
    showDialog(
      context: context,
      builder: (BuildContext context) {
        dialogContext = context;
        return AlertDialog(
          title: const Text('Victoire !'),
          content: Text(
              'Félicitations, vous avez gagné ! Temps écoulé : ${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${centiseconds.toString().padLeft(2, '0')}'),
          actions: <Widget>[
            TextButton(
              child: const Text('Quitter'),
              onPressed: () {
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            TextButton(
              child: const Text('Rejouer'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                resetTimer();
                clear();
                startTimer();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.isPreview
        ? IgnorePointer(child: buildGameGrid(context))
        : buildGameGrid(context);
  }

  Widget buildGameGrid(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localPosition = box.globalToLocal(details.globalPosition);

        double cellWidth = box.size.width / widget.gameMap.grid.width;
        double cellHeight = box.size.height / widget.gameMap.grid.height;

        int x1 = (localPosition.dx / cellWidth).floor();
        int y1 = (localPosition.dy / cellHeight).floor();

        // Coordonnées relatives de la position du toucher dans la case sélectionnée
        double relativeX = localPosition.dx % cellWidth;
        double relativeY = localPosition.dy % cellHeight;

        int x2 = x1;
        int y2 = y1;

        // Déterminer si nous devons tracer un trait horizontal ou vertical
        if ((relativeX < cellWidth / 4 && x1 > 0) ||
            (relativeX > cellWidth * 3 / 4 &&
                x1 < widget.gameMap.grid.width - 1)) {
          x2 = relativeX < cellWidth / 4 ? x1 - 1 : x1 + 1;
        } else if ((relativeY < cellHeight / 4 && y1 > 0) ||
            (relativeY > cellHeight * 3 / 4 &&
                y1 < widget.gameMap.grid.height - 1)) {
          y2 = relativeY < cellHeight / 4 ? y1 - 1 : y1 + 1;
        } else {
          // Gestion des cas aux bords de la grille pour les traits verticaux
          if (x1 == 0 && relativeX < cellWidth / 4) {
            x2 = x1 + 1;
          } else if (x1 == widget.gameMap.grid.width - 1 &&
              relativeX > cellWidth * 3 / 4) {
            x2 = x1 - 1;
          }
        }

        // Ajouter les coordonnées des deux cases à la liste des liaisons.
        setState(() {
          // Vérifier si la liaison existe déjà
          int index = liaisons.indexWhere((liaison) =>
              (liaison[0] == x1 &&
                  liaison[1] == y1 &&
                  liaison[2] == x2 &&
                  liaison[3] == y2) ||
              (liaison[0] == x2 &&
                  liaison[1] == y2 &&
                  liaison[2] == x1 &&
                  liaison[3] == y1));
          if (index != -1) {
            liaisons.removeAt(index);
          } else {
            if ((x1 == x2 && (y1 == y2 + 1 || y1 == y2 - 1)) ||
                (y1 == y2 && (x1 == x2 + 1 || x1 == x2 - 1))) {
              if (x1 > x2 || (x1 == x2 && y1 > y2)) {
                int tempX = x1;
                int tempY = y1;
                x1 = x2;
                y1 = y2;
                x2 = tempX;
                y2 = tempY;
              }
              liaisons.add([x1, y1, x2, y2]);
            }
          }
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (isVictory(
            widget.gameMap.grid.blackPoints,
            widget.gameMap.grid.whitePoints,
            liaisons
                .map((liaison) =>
                    Connection(liaison[0], liaison[1], liaison[2], liaison[3]))
                .toList(),
          )) {
            _showVictoryDialog();
          }
        });
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: CustomPaint(
            painter: GameGridPainter(
                liaisons: liaisons, gameGrid: widget.gameMap.grid),
            child: GridView.builder(
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.gameMap.grid.width,
                childAspectRatio: 1,
                mainAxisSpacing: 1.75,
                crossAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                int x = index % widget.gameMap.grid.width;
                int y = index ~/ widget.gameMap.grid.width;

                if (widget.gameMap.grid.blackPoints
                    .any((point) => point.x == x && point.y == y)) {
                  return const GridPoint(
                      color: Colors.black, sizePercentage: 0.5);
                } else if (widget.gameMap.grid.whitePoints
                    .any((point) => point.x == x && point.y == y)) {
                  return const GridPoint(
                      color: Colors.white,
                      borderColor: Colors.black,
                      sizePercentage: 0.5);
                } else {
                  return GridPoint(
                      color: Colors.grey.withOpacity(0.2), sizePercentage: 0.2);
                }
              },
              itemCount: widget.gameMap.grid.width * widget.gameMap.grid.height,
            ),
          ),
        ),
      ),
    );
  }
}
