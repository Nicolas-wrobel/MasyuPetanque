import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';

class GameGridWidget extends StatelessWidget {
  final GameMap gameMap;

  const GameGridWidget({Key? key, required this.gameMap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = gameMap.grid.width;
    final height = gameMap.grid.height;

    final blackPoints = gameMap.grid.blackPoints;
    final whitePoints = gameMap.grid.whitePoints;

    return Center(
      child: Container(
        margin: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: width,
            childAspectRatio: 1,
            mainAxisSpacing: 2,
            crossAxisSpacing: 2,
          ),
          itemBuilder: (context, index) {
            int x = index % width;
            int y = index ~/ width;

            if (blackPoints.any((point) => point.x == x && point.y == y)) {
              return const _GridPoint(color: Colors.black, size: 14);
            } else if (whitePoints
                .any((point) => point.x == x && point.y == y)) {
              return const _GridPoint(
                  color: Colors.white, borderColor: Colors.black, size: 14);
            } else {
              return _GridPoint(color: Colors.grey.withOpacity(0.2), size: 8);
            }
          },
          itemCount: width * height,
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
