import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';

class GameGridWidget extends StatefulWidget {
  final GameGrid gameGrid;

  const GameGridWidget({required this.gameGrid, Key? key}) : super(key: key);

  @override
  _GameGridWidgetState createState() => _GameGridWidgetState();
}

class _GameGridWidgetState extends State<GameGridWidget> {
  final List<List<int>> liaisons = [];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (TapDownDetails details) {
        RenderBox box = context.findRenderObject() as RenderBox;
        Offset localPosition = box.globalToLocal(details.globalPosition);

        double cellWidth = box.size.width / widget.gameGrid.width!;
        double cellHeight = box.size.height / widget.gameGrid.height!;

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
                x1 < widget.gameGrid.width! - 1)) {
          x2 = relativeX < cellWidth / 4 ? x1 - 1 : x1 + 1;
        } else if ((relativeY < cellHeight / 4 && y1 > 0) ||
            (relativeY > cellHeight * 3 / 4 &&
                y1 < widget.gameGrid.height! - 1)) {
          y2 = relativeY < cellHeight / 4 ? y1 - 1 : y1 + 1;
        } else {
          // Gestion des cas aux bords de la grille pour les traits verticaux
          if (x1 == 0 && relativeX < cellWidth / 4) {
            x2 = x1 + 1;
          } else if (x1 == widget.gameGrid.width! - 1 &&
              relativeX > cellWidth * 3 / 4) {
            x2 = x1 - 1;
          }
        }

        // Ajoutez les coordonnées des deux cases à la liste des liaisons.
        setState(() {
          liaisons.add([x1, y1, x2, y2]);
        });
      },
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black, width: 2),
          ),
          child: CustomPaint(
            painter:
                _GameGridPainter(liaisons: liaisons, gameGrid: widget.gameGrid),
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: widget.gameGrid.width!,
                childAspectRatio: 1,
                mainAxisSpacing: 3,
                crossAxisSpacing: 2,
              ),
              itemBuilder: (context, index) {
                int x = index % widget.gameGrid.width!;
                int y = index ~/ widget.gameGrid.width!;

                // Vérifiez si le point est noir ou blanc
                if (widget.gameGrid.blackPoints!
                    .any((point) => point[0] == x && point[1] == y)) {
                  return const _GridPoint(color: Colors.black, size: 14);
                } else if (widget.gameGrid.whitePoints!
                    .any((point) => point[0] == x && point[1] == y)) {
                  return const _GridPoint(
                      color: Colors.white, borderColor: Colors.black, size: 14);
                } else {
                  return _GridPoint(
                      color: Colors.grey.withOpacity(0.2), size: 8);
                }
              },
              itemCount: widget.gameGrid.width! * widget.gameGrid.height!,
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
  final double size;

  const _GridPoint(
      {Key? key, required this.color, this.borderColor, required this.size})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(
            1), // Ajoutez une marge pour éviter le chevauchement
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
  }
}

class _GameGridPainter extends CustomPainter {
  final List<List<int>> liaisons;
  final GameGrid gameGrid;

  _GameGridPainter({required this.liaisons, required this.gameGrid});

  @override
  void paint(Canvas canvas, Size size) {
    double cellWidth = size.width / gameGrid.width!;
    double cellHeight = size.height / gameGrid.height!;
    Paint paint = Paint()
      ..color = Colors.black
      ..strokeWidth = 4; // Ajuster la taille des traits

    for (List<int> liaison in liaisons) {
      int x1 = liaison[0];
      int y1 = liaison[1];
      int x2 = liaison[2];
      int y2 = liaison[3];

      canvas.drawLine(
        Offset(x1 * cellWidth + cellWidth / 2,
            y1 * cellHeight + cellHeight / 2 - 1),
        Offset(x2 * cellWidth + cellWidth / 2,
            y2 * cellHeight + cellHeight / 2 - 1),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GameGridPainter oldDelegate) {
    return oldDelegate.liaisons != liaisons;
  }
}
