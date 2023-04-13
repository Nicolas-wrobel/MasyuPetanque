class GameMap {
  final String id;
  final String name;
  final String author;
  final DateTime creationDate;
  final GameGrid grid;
  final List<GameRanking>? ranking;
  final bestTime;

  GameMap({
    required this.id,
    required this.name,
    required this.author,
    required this.creationDate,
    required this.grid,
    required this.bestTime,
    this.ranking,
  });

  factory GameMap.fromMap(Map<String, dynamic> map, String id) {
    String id = map['id'] as String;
    String name = map['name'] as String;
    String author = map['author'] as String;
    DateTime creationDate = DateTime.parse(map['creation_date'] as String);
    GameGrid grid = GameGrid.fromMap(map['grid'] as Map<String, dynamic>);

    List<GameRanking> ranking = [];
    for (int i = 1; i < map['ranking'].length; i++) {
      ranking.add(GameRanking.fromMap(map['ranking'][i]));
    }

    String bestTime = ranking[0].time;

    return GameMap(
        id: id,
        name: name,
        author: author,
        creationDate: creationDate,
        grid: grid,
        ranking: ranking,
        bestTime: bestTime);
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

  GameGrid(
      {required this.width,
      required this.height,
      required this.blackPoints,
      required this.whitePoints});

  factory GameGrid.fromMap(Map<String, dynamic> map) {
    int width = map['dimensions']['width'] as int;
    int height = map['dimensions']['height'] as int;

    List<Point> blackPoints = [];
    for (int i = 1; i < map['black_points'].length; i++) {
      blackPoints.add(Point(
          x: map['black_points'][i]['x'], y: map['black_points'][i]['y']));
    }

    List<Point> whitePoints = [];
    for (int i = 1; i < map['white_points'].length; i++) {
      whitePoints.add(Point(
          x: map['white_points'][i]['x'], y: map['white_points'][i]['y']));
    }

    return GameGrid(
        width: width,
        height: height,
        blackPoints: blackPoints,
        whitePoints: whitePoints);
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

class GameGridList {
  final List<GameGrid> gameGrids;

  GameGridList() : gameGrids = [];

  void addGameGridListFromMap(List<Map<String, dynamic>> mapList) {
    gameGrids.clear();
    for (var map in mapList) {
      gameGrids.add(GameGrid.fromMap(map));
    }
  }
}
