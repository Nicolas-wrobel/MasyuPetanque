import 'package:collection/collection.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';

// Classe représentant une connexion entre deux points
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

// Fonction DFS pour vérifier si un cycle existe dans le graphe
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

// Fonction principale pour vérifier si la configuration actuelle est une victoire
bool isVictory(List<Point> black_points, List<Point> white_points,
    List<Connection> connections) {
  // Combiner les points noirs et blancs dans une liste unique
  List<Point> points = [
    ...black_points,
    ...white_points,
  ];

  // Fonction pour obtenir un point en fonction de ses coordonnées x et y
  Point? getPoint(int x, int y) {
    return points.firstWhereOrNull((p) => p.x == x && p.y == y);
  }

  // Fonction pour obtenir les connexions d'un point spécifique
  List<Connection> getConnections(Point point) {
    return connections
        .where((c) =>
            (c.x1 == point.x && c.y1 == point.y) ||
            (c.x2 == point.x && c.y2 == point.y))
        .toList();
  }

  // Fonction pour construire le graphe à partir des points et des connexions
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

  // Fonction pour vérifier si un cycle existe dans le graphe
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
  if (!loopExists) return false;
  // Fonction pour vérifier les règles spécifiques aux points noirs
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

  // Fonction pour vérifier les règles spécifiques aux points blancs
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

  // Vérifier que les points noirs sont bien reliés
  for (Point point in black_points) {
    if (!checkBlackPoint(point)) return false;
  }

  // Vérifier que les points blancs sont bien reliés
  for (Point point in white_points) {
    if (!checkWhitePoint(point)) return false;
  }

  // Si toutes les conditions sont remplies, c'est une victoire
  return true;
}
