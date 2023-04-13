import 'dart:ffi';

class GameGrid {
  final String? id;
  final String? name;
  final String? author;
  final String? creationDate;
  final int? width;
  final int? height;
  final List<List>? blackPoints;
  final List<List>? whitePoints;
  final List<Map<String, dynamic>>? ranking;

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

  static List<List<dynamic>> _convertPoints(List<dynamic> points) {
    return List.castFrom<dynamic, List<dynamic>>(points
        .map((point) => point != null ? [point['x'], point['y']] : null)
        .where((point) => point != null)
        .toList());
  }
}

class Point {
  final int x;
  final int y;

  Point({required this.x, required this.y});

  static List<Map<String, dynamic>> _convertRanking(List<dynamic> ranking) {
    return ranking.map((entry) {
      if (entry == null) {
        return {
          'date': 'N/A',
          'score': 0,
          'user_id': 'N/A',
        };
      }
      return {
        'date': entry['date'] ?? 'N/A',
        'score': entry['score'] ?? 0,
        'user_id': entry['user_id'] ?? 'N/A',
      };
    }).toList();
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
