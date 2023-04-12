import 'package:collection/collection.dart';

class Point {
  int x;
  int y;
  String color;

  Point(this.x, this.y, this.color);
}

class Connection {
  int x1;
  int y1;
  int x2;
  int y2;

  Connection(this.x1, this.y1, this.x2, this.y2);
}

bool isVictory(
    List<Map<String, dynamic>> black_points,
    List<Map<String, dynamic>> white_points,
    List<Map<String, dynamic>> connections_data) {
  print('Points noirs: $black_points');
  print('Points blancs: $white_points');
  print('Liaisons: $connections_data');
  List<Point> points = [
    ...black_points.map((p) => Point(p['x'], p['y'], 'B')),
    ...white_points.map((p) => Point(p['x'], p['y'], 'W')),
  ];
  List<Connection> connections = connections_data
      .map((c) => Connection(c['x1'], c['y1'], c['x2'], c['y2']))
      .toList();

  Point? getPoint(int x, int y) {
    return points.firstWhereOrNull((p) => p.x == x && p.y == y);
  }

  List<Connection> getConnections(Point point) {
    return connections
        .where((c) =>
            (c.x1 == point.x && c.y1 == point.y) ||
            (c.x2 == point.x && c.y2 == point.y))
        .toList();
  }

  bool checkLoop() {
    Set<Point> visited = {};
    void dfs(Point point, Connection? previousConnection) {
      if (visited.contains(point)) return;
      visited.add(point);
      for (Connection connection in getConnections(point)) {
        if (previousConnection == connection) continue;
        Point? next = getPoint(connection.x1, connection.y1) == point
            ? getPoint(connection.x2, connection.y2)
            : getPoint(connection.x1, connection.y1);
        if (next != null) {
          dfs(next, connection);
        }
      }
    }

    dfs(points.first, null);
    return visited.length == points.length;
  }

  bool checkBlackPoint(Point point) {
    List<Connection> pointConnections = getConnections(point);

    if (pointConnections.length != 2) return false;

    Connection c1 = pointConnections[0];
    Connection c2 = pointConnections[1];

    bool oppositeDirections =
        (c1.x1 - c1.x2) * (c2.x1 - c2.x2) + (c1.y1 - c1.y2) * (c2.y1 - c2.y2) ==
            0;
    return oppositeDirections;
  }

  bool checkWhitePoint(Point point) {
    List<Connection> pointConnections = getConnections(point);

    if (pointConnections.length != 2) return false;

    Connection c1 = pointConnections[0];
    Connection c2 = pointConnections[1];

    bool sameDirections =
        (c1.x1 - c1.x2) * (c2.x1 - c2.x2) + (c1.y1 - c1.y2) * (c2.y1 - c2.y2) !=
            0;
    return sameDirections;
  }

  // Vérifier qu'une boucle existe
  if (!checkLoop()) return false;

  // Vérifier que les points noirs sont bien reliés
  for (Point point in black_points.map((p) => Point(p['x'], p['y'], 'B'))) {
    if (!checkBlackPoint(point)) return false;
  }

  // Vérifier que les points blancs sont bien reliés
  for (Point point in white_points.map((p) => Point(p['x'], p['y'], 'W'))) {
    if (!checkWhitePoint(point)) return false;
  }

  return true;
}
