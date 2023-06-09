// Classe représentant une carte de jeu
class GameMap {
  final String id;
  final String name;
  final String author;
  final DateTime creationDate;
  final GameGrid grid;
  late final List<GameRanking>? ranking;
  late final String? bestTime;

  GameMap({
    required this.id,
    required this.name,
    required this.author,
    required this.creationDate,
    required this.grid,
    this.bestTime,
    this.ranking,
  });

  // Getters
  String get getId => id;
  String get getName => name;
  String get getAuthor => author;
  DateTime get getCreationDate => creationDate;
  GameGrid get getGrid => grid;
  List<GameRanking>? get getRanking => ranking;
  String? get getBestTime => bestTime;

  // Setters
  set setRanking(List<GameRanking>? ranking) => this.ranking = ranking;
  set setBestTime(String? bestTime) => this.bestTime = bestTime;

  // Méthode pour créer une instance de GameMap à partir d'une Map
  factory GameMap.fromMap(Map<String, dynamic> map, String id) {
    String name = map['name'] as String;
    String author = map['author'] as String;
    DateTime creationDate =
        DateTime.fromMillisecondsSinceEpoch(map['creation_date'] as int);
    Map<String, dynamic> dimensions = {
      for (var k in map['dimensions'].keys) k.toString(): map['dimensions'][k]
    };
    GameGrid grid = GameGrid.fromMap(dimensions, map);

    List<GameRanking>? ranking;
    String? bestTime;

    if (map.containsKey('ranking')) {
      ranking = (map['ranking'] as List<dynamic>)
          .sublist(1)
          .map<GameRanking>((dynamic e) {
        Map<String, dynamic> rankingMap = {
          for (var k in (e as Map).keys) k.toString(): e[k]
        };
        return GameRanking.fromMap(rankingMap.entries.first);
      }).toList();
      if (ranking.isNotEmpty) {
        bestTime = ranking[0].time;
      }
    }

    return GameMap(
      id: id,
      name: name,
      author: author,
      creationDate: creationDate,
      grid: grid,
      bestTime: bestTime,
      ranking: ranking,
    );
  }
}

// Classe représentant un classement de jeu
class GameRanking {
  final String userId;
  final String time;

  GameRanking({required this.userId, required this.time});

  // Méthode pour créer une instance de GameRanking à partir d'une MapEntry
  factory GameRanking.fromMap(MapEntry<String, dynamic> entry) {
    return GameRanking(
      userId: entry.key,
      time: entry.value.toString(),
    );
  }
}

// Classe représentant une grille de jeu
class GameGrid {
  final int width;
  final int height;
  final List<Point> blackPoints;
  final List<Point> whitePoints;

  GameGrid({
    required this.width,
    required this.height,
    required this.blackPoints,
    required this.whitePoints,
  });

  // Méthode pour créer une instance de GameGrid à partir d'une Map
  factory GameGrid.fromMap(
      Map<String, dynamic> dimensions, Map<String, dynamic> map) {
    int width = dimensions['width'] as int;
    int height = dimensions['height'] as int;

    List<Point> blackPoints = _pointsFromMap(map['grid']['black_points']);
    List<Point> whitePoints = _pointsFromMap(map['grid']['white_points']);

    return GameGrid(
      width: width,
      height: height,
      blackPoints: blackPoints,
      whitePoints: whitePoints,
    );
  }

  // Méthode privée pour créer une liste de points à partir d'une Map
  static List<Point> _pointsFromMap(List<dynamic>? pointMapList) {
    if (pointMapList == null) {
      return [];
    } else {
      return pointMapList.sublist(1).map<Point>((dynamic e) {
        Map<String, dynamic> pointMap = {
          for (var k in (e as Map).keys) k.toString(): e[k]
        };
        return Point.fromMap(pointMap);
      }).toList();
    }
  }
}

// Classe représentant un point
class Point {
  final int x;
  final int y;

  Point({required this.x, required this.y});

  // Méthode pour créer une instance de Point à partir d'une Map
  factory Point.fromMap(Map<String, dynamic> map) {
    return Point(
      x: map['x'] as int,
      y: map['y'] as int,
    );
  }
}
