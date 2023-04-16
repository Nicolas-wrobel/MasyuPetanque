import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';

// Classe représentant un point (noir, blanc ou transparent) dans la grille
class GridPoint extends StatelessWidget {
  final Color color;
  final Color? borderColor;
  final double sizePercentage;

  const GridPoint(
      {Key? key,
      required this.color,
      this.borderColor,
      required this.sizePercentage})
      : super(key: key);

  @override
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

// Classe représentant le dessin de la grille de jeu, y compris les liaisons
class GameGridPainter extends CustomPainter {
  final List<List<int>> liaisons;
  final GameGrid gameGrid;

  GameGridPainter({required this.liaisons, required this.gameGrid});

  @override
  void paint(Canvas canvas, Size size) {
    final double cellWidth = size.width / gameGrid.width;
    final double cellHeight = size.height / gameGrid.height;

    // Dessin des liaisons entre les points
    for (List<int> liaison in liaisons) {
      int x1 = liaison[0];
      int y1 = liaison[1];
      int x2 = liaison[2];
      int y2 = liaison[3];

      // Coordonnées du centre des cellules
      double centerX1 = x1 * cellWidth + cellWidth / 2;
      double centerY1 = y1 * cellHeight + cellHeight / 2;
      double centerX2 = x2 * cellWidth + cellWidth / 2;
      double centerY2 = y2 * cellHeight + cellHeight / 2;

      Paint paint = Paint()
        ..color = Colors.black
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
          Offset(centerX1, centerY1), Offset(centerX2, centerY2), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
