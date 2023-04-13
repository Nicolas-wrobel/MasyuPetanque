import 'package:collection/collection.dart';

class Point {
  int x;
  int y;
  String color;

  Point(this.x, this.y, this.color);

  @override
  String toString() {
    return 'Point(x: $x, y: $y, color: $color)';
  }
}

class Connection {
  int x1;
  int y1;
  int x2;
  int y2;

  Connection(this.x1, this.y1, this.x2, this.y2);

  @override
  String toString() {
    return 'Connection(x1: $x1, y1: $y1, x2: $x2, y2: $y2)';
  }
}

bool hasCycleDFS(
    int node, int parent, Map<int, List<int>> graph, Map<int, bool> visited) {
  visited[node] = true;

  for (int neighbor in graph[node]!) {
    if (!visited[neighbor]!) {
      if (hasCycleDFS(neighbor, node, graph, visited)) {
        return true;
      }
    } else if (neighbor != parent) {
      return true;
    }
  }

  return false;
}

bool isVictory(List<Point> black_points, List<Point> white_points,
    List<Connection> connections) {
  print('Points noirs: $black_points');
  print('Points blancs: $white_points');
  print('Liaisons: $connections');

  List<Point> points = [
    ...black_points,
    ...white_points,
  ];

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

  Map<int, List<int>> buildGraph() {
    Map<int, List<int>> graph = {};
    for (Point point in points) {
      graph[point.x * 10 + point.y] = [];
    }
    for (Connection connection in connections) {
      int node1 = connection.x1 * 10 + connection.y1;
      int node2 = connection.x2 * 10 + connection.y2;
      graph.putIfAbsent(node1, () => []).add(node2);
      graph.putIfAbsent(node2, () => []).add(node1);
    }
    return graph;
  }

  bool checkLoop() {
    Map<int, List<int>> graph = buildGraph();
    Map<int, bool> visited = {for (var key in graph.keys) key: false};

    for (int node in graph.keys) {
      if (!visited[node]!) {
        if (hasCycleDFS(node, -1, graph, visited)) {
          return true;
        }
      }
    }

    return false;
  }

  // Vérifier qu'une boucle existe
  bool loopExists = checkLoop();
  print('Loop exists: $loopExists');
  if (!loopExists) return false;
  bool checkBlackPoint(Point point) {
    List<Connection> pointConnections = getConnections(point);
    print('Black point: $point, connections: $pointConnections');

    if (pointConnections.length != 2) return false;

    Connection c1 = pointConnections[0];
    Connection c2 = pointConnections[1];

    bool oppositeDirections =
        (c1.x1 - c1.x2) * (c2.x1 - c2.x2) + (c1.y1 - c1.y2) * (c2.y1 - c2.y2) ==
            0;
    print('Opposite directions: $oppositeDirections');
    return oppositeDirections;
  }

  bool checkWhitePoint(Point point) {
    List<Connection> pointConnections = getConnections(point);
    print('White point: $point, connections: $pointConnections');

    if (pointConnections.length != 2) return false;

    Connection c1 = pointConnections[0];
    Connection c2 = pointConnections[1];

    bool sameDirections =
        (c1.x1 - c1.x2) * (c2.x1 - c2.x2) + (c1.y1 - c1.y2) * (c2.y1 - c2.y2) !=
            0;
    print('Same directions: $sameDirections');
    return sameDirections;
  }

  bool loopDetected = checkLoop();
  print('Loop detected: $loopDetected');
  if (!loopDetected) return false;

// Vérifier que les points noirs sont bien reliés
  for (Point point in black_points) {
    if (!checkBlackPoint(point)) return false;
  }

// Vérifier que les points blancs sont bien reliés
  for (Point point in white_points) {
    if (!checkWhitePoint(point)) return false;
  }

  return true;
}
