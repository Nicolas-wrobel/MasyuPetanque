import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/screens/map_creator_screen.dart';
import 'package:masyu_petanque/src/utils/game_checker.dart';
import 'package:masyu_petanque/src/widgets/grid_point_painter.dart';

class GameGridWidgetEditor extends StatefulWidget {
  final GameMap gameMap;
  final bool isPreview;
  final ToolMode tool;

  const GameGridWidgetEditor({
    required this.gameMap,
    this.isPreview = false,
    required this.tool,
    Key? key,
  }) : super(key: key);

  @override
  GameGridWidgetState createState() => GameGridWidgetState();
}

class GameGridWidgetState extends State<GameGridWidgetEditor> {
  final List<List<int>> liaisons = []; // Liste des liaisons entre les points

  // Fonction pour annuler la dernière action
  void undo() {
    setState(() {
      if (liaisons.isNotEmpty) {
        liaisons.removeLast();
      }
    });
  }

  // Fonction pour effacer toutes les liaisons
  void clear() {
    setState(() {
      liaisons.clear();
    });
  }

  // Fonction pour ajouter un cercle noir
  void _handleAddBlackCircle(int x, int y) {
    setState(() {
      widget.gameMap.grid.blackPoints.add(Point(x: x, y: y));
    });
  }

  // Fonction pour ajouter un cercle blanc
  void _handleAddWhiteCircle(int x, int y) {
    setState(() {
      widget.gameMap.grid.whitePoints.add(Point(x: x, y: y));
    });
  }

  // Fonction pour ajouter une ligne noire
  void _handleAddBlackLine(int x1, int y1, int x2, int y2, double relativeX,
      double relativeY, double cellWidth, double cellHeight) {
    setState(() {
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

      // Ajouter les coordonnées des deux cases à la liste des liaisons
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
        liaisons.removeAt(index); // Si elle existe, la supprimer
      } else {
        // Sinon, vérifier si les points sont adjacents
        if ((x1 == x2 && (y1 == y2 + 1 || y1 == y2 - 1)) ||
            (y1 == y2 && (x1 == x2 + 1 || x1 == x2 - 1))) {
          // Si les coordonnées sont dans le mauvais ordre, les inverser
          if (x1 > x2 || (x1 == x2 && y1 > y2)) {
            int tempX = x1;
            int tempY = y1;
            x1 = x2;
            y1 = y2;
            x2 = tempX;
            y2 = tempY;
          }
          liaisons.add([x1, y1, x2, y2]); // Ajouter la liaison
        }
      }
    });
  }

  // Fonction pour effacer un point ou une ligne
  void _handleEraseItem(int x1, int y1) {
    setState(() {
      // Supprimer le point noir ou blanc à la position donnée
      widget.gameMap.grid.blackPoints
          .removeWhere((point) => point.x == x1 && point.y == y1);
      widget.gameMap.grid.whitePoints
          .removeWhere((point) => point.x == x1 && point.y == y1);

      // Supprimer les liaisons associées au point
      liaisons.removeWhere((liaison) =>
          (liaison[0] == x1 && liaison[1] == y1) ||
          (liaison[2] == x1 && liaison[3] == y1));
    });
  }

  // Fonction vide pour gérer l'annulation d'une action (non implémentée)
  void _handleUndoAction() {}

  @override
  Widget build(BuildContext context) {
    // Utiliser un Listener pour détecter les événements de toucher
    return Listener(
        onPointerDown: (PointerDownEvent details) {
          double cellWidth = context.size!.width / widget.gameMap.grid.width;
          double cellHeight = context.size!.height / widget.gameMap.grid.height;

          // Calculer la position du toucher dans la grille
          int x1 = (details.localPosition.dx / cellWidth).floor();
          int y1 = (details.localPosition.dy / cellHeight).floor();

          // Coordonnées relatives de la position du toucher dans la case sélectionnée
          double relativeX = details.localPosition.dx % cellWidth;
          double relativeY = details.localPosition.dy % cellHeight;

          int x2 = x1;
          int y2 = y1;

          // Choisir l'action à effectuer en fonction de l'outil sélectionné
          switch (widget.tool) {
            case ToolMode.addBlackCircle:
              _handleAddBlackCircle(x1, y1);
              break;
            case ToolMode.addWhiteCircle:
              _handleAddWhiteCircle(x1, y1);
              break;
            case ToolMode.addBlackLine:
              _handleAddBlackLine(
                  x1, y1, x2, y2, relativeX, relativeY, cellWidth, cellHeight);
              break;
            case ToolMode.eraseItem:
              _handleEraseItem(x1, y1);
              break;
            case ToolMode.undoAction:
              _handleUndoAction();
              break;
          }

          // Vérifier après chaque action si la victoire est atteinte
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (isVictory(
              widget.gameMap.grid.blackPoints,
              widget.gameMap.grid.whitePoints,
              liaisons
                  .map((liaison) => Connection(
                      liaison[0], liaison[1], liaison[2], liaison[3]))
                  .toList(),
            )) {
              // Déverrouiller le bouton validé (si nécessaire)
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

                  // Afficher les points noirs, blancs ou transparents dans chaque case
                  if (widget.gameMap.grid.blackPoints
                      .any((point) => point.x == x && point.y == y)) {
                    return GridPoint(
                        key: Key('white_{$x}_{$y}'),
                        color: Colors.black,
                        sizePercentage: 0.5);
                  } else if (widget.gameMap.grid.whitePoints
                      .any((point) => point.x == x && point.y == y)) {
                    return GridPoint(
                        key: Key('white_{$x}_{$y}'),
                        color: Colors.white,
                        borderColor: Colors.black,
                        sizePercentage: 0.5);
                  } else {
                    return GridPoint(
                        color: Colors.grey.withOpacity(0.2),
                        sizePercentage: 0.2);
                  }
                },
                itemCount:
                    widget.gameMap.grid.width * widget.gameMap.grid.height,
              ),
            ),
          ),
        ));
  }
}
