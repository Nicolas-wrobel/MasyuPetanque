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

  String get getId => id;
  String get getName => name;
  String get getAuthor => author;
  DateTime get getCreationDate => creationDate;
  GameGrid get getGrid => grid;
  List<GameRanking>? get getRanking => ranking;
  String? get getBestTime => bestTime;

  set setRanking(List<GameRanking>? ranking) => this.ranking = ranking;
  set setBestTime(String? bestTime) => this.bestTime = bestTime;

  factory GameMap.fromMap(Map<String, dynamic> map, String id) {
    print(map);
    String name = map['name'] as String;
    String author = map['author'] as String;
    DateTime creationDate = DateTime.parse(map['creation_date'] as String);
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
        return GameRanking.fromMap(rankingMap);
      }).toList();
      bestTime = ranking[0].time;
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

class GameRanking {
  final String userId;
  final String time;

  GameRanking({required this.userId, required this.time});

  factory GameRanking.fromMap(Map<String, dynamic> map) {
    return GameRanking(
      userId: map['user_id'] as String,
      time: map['time'] as String,
    );
  }
}

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

  factory GameGrid.fromMap(
      Map<String, dynamic> dimensions, Map<String, dynamic> map) {
    int width = dimensions['width'] as int;
    int height = dimensions['height'] as int;

    // Declare blackPoints and whitePoints as nullable local variables
    List<Point>? blackPoints;
    List<Point>? whitePoints;

    if (map['grid']['black_points'] == null) {
      blackPoints = [];
    } else {
      blackPoints = (map['grid']['black_points'] as List<dynamic>)
          .sublist(1)
          .map<Point>((dynamic e) {
        Map<String, dynamic> pointMap = {
          for (var k in (e as Map).keys) k.toString(): e[k]
        };
        return Point.fromMap(pointMap);
      }).toList();
    }

    if (map['grid']['white_points'] == null) {
      whitePoints = [];
    } else {
      whitePoints = (map['grid']['white_points'] as List<dynamic>)
          .sublist(1)
          .map<Point>((dynamic e) {
        Map<String, dynamic> pointMap = {
          for (var k in (e as Map).keys) k.toString(): e[k]
        };
        return Point.fromMap(pointMap);
      }).toList();
    }

    return GameGrid(
      width: width,
      height: height,
      blackPoints: blackPoints,
      whitePoints: whitePoints,
    );
  }
}

class Point {
  final int x;
  final int y;

  Point({required this.x, required this.y});

  factory Point.fromMap(Map<String, dynamic> map) {
    return Point(
      x: map['x'] as int,
      y: map['y'] as int,
    );
  }
}
