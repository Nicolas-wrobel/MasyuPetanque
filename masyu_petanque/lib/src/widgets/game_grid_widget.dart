import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/screens/game_screen.dart';
import 'package:masyu_petanque/src/utils/game_checker.dart';

class GameGridWidget extends StatefulWidget {
  final GameMap gameMap;
  final VoidCallback? onMapSolved;
  final bool isPreview;

  const GameGridWidget(
      {Key? key,
      required this.gameMap,
      this.onMapSolved,
      this.isPreview = false})
      : super(key: key);

  @override
  GameGridWidgetState createState() => GameGridWidgetState();
}

class GameGridWidgetState extends State<GameGridWidget> {
  final List<List<int>> liaisons = [];

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

  String formatElapsedTime(Duration elapsedTime) {
    String hours = elapsedTime.inHours > 0 ? '${elapsedTime.inHours}:' : '';
    String minutes =
        '${elapsedTime.inMinutes.remainder(60).toString().padLeft(2, '0')}:';
    String seconds = (elapsedTime.inSeconds % 60).toString().padLeft(2, '0');
    String milliseconds =
        (elapsedTime.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0');

    return '$hours$minutes$seconds.$milliseconds';
  }

  void _showVictoryDialog(elapsedTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Victoire!'),
          content: Text(
            "Temps écoulé: ${formatElapsedTime(elapsedTime)}",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
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

        // Déterminez si nous devons tracer un trait horizontal ou vertical
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

        // Ajoutez les coordonnées des deux cases à la liste des liaisons.
        setState(() {
          // Vérifiez si la liaison existe déjà
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
            print('Liaison supprimée: [$x1, $y1, $x2, $y2]');
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
              print('Liaison ajoutée: [$x1, $y1, $x2, $y2]');
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
            Duration elapsedTime = TimerData.of(context).elapsedTime;
            String elapsedTimeText =
                '${elapsedTime.inMinutes.toString().padLeft(2, '0')}:${(elapsedTime.inSeconds % 60).toString().padLeft(2, '0')}.${(elapsedTime.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}';

            _showVictoryDialog(elapsedTimeText);
            if (widget.onMapSolved != null) {
              widget.onMapSolved!();
            }
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
            painter: _GameGridPainter(
                liaisons: liaisons, gameGrid: widget.gameMap.grid),
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
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
                  return const _GridPoint(
                      color: Colors.black, sizePercentage: 0.5);
                } else if (widget.gameMap.grid.whitePoints
                    .any((point) => point.x == x && point.y == y)) {
                  return const _GridPoint(
                      color: Colors.white,
                      borderColor: Colors.black,
                      sizePercentage: 0.5);
                } else {
                  return _GridPoint(
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

class _GridPoint extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final double sizePercentage;

  const _GridPoint(
      {Key? key,
      required this.color,
      this.borderColor,
      required this.sizePercentage})
      : super(key: key);

  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      double size = constraints.maxWidth * sizePercentage;

      return Center(
        child: Container(
          margin: const EdgeInsets.all(1),
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: borderColor != null
                ? Border.all(color: borderColor!, width: 1)
                : null,
          ),
        ),
      );
    });
  }
}

class _GameGridPainter extends CustomPainter {
  final List<List<int>> liaisons;
  final GameGrid gameGrid;

  _GameGridPainter({required this.liaisons, required this.gameGrid});

  @override
  void paint(Canvas canvas, Size size) {
    double cellWidth = size.width / gameGrid.width;
    double cellHeight = size.height / gameGrid.height;
    double strokeWidth = cellWidth * 0.1;

    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = strokeWidth;

    double extension = cellWidth * 0.05;

    for (List<int> liaison in liaisons) {
      int x1 = liaison[0];
      int y1 = liaison[1];
      int x2 = liaison[2];
      int y2 = liaison[3];

      Offset startPoint = Offset(
          x1 * cellWidth + cellWidth / 2, y1 * cellHeight + cellHeight / 2);
      Offset endPoint = Offset(
          x2 * cellWidth + cellWidth / 2, y2 * cellHeight + cellHeight / 2);

      if (x1 == x2) {
        // Cas vertical
        double startY =
            y1 < y2 ? startPoint.dy - extension : startPoint.dy + extension;
        double endY =
            y1 < y2 ? endPoint.dy + extension : endPoint.dy - extension;

        canvas.drawLine(
          Offset(startPoint.dx, startY),
          Offset(endPoint.dx, endY),
          paint,
        );
      } else {
        // Cas horizontal
        double startX =
            x1 < x2 ? startPoint.dx - extension : startPoint.dx + extension;
        double endX =
            x1 < x2 ? endPoint.dx + extension : endPoint.dx - extension;

        canvas.drawLine(
          Offset(startX, startPoint.dy),
          Offset(endX, endPoint.dy),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GameGridPainter oldDelegate) {
    return oldDelegate.liaisons != liaisons;
  }
}
