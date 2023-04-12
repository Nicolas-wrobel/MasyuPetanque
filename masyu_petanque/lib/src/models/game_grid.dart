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

  GameGrid({
    this.id,
    this.name,
    this.author,
    this.creationDate,
    this.width,
    this.height,
    this.blackPoints,
    this.whitePoints,
    this.ranking,
  });

  static GameGrid fromMap(String id, Map<String, dynamic> map) {
    return GameGrid(
      id: id,
      name: map['name'] ?? 'N/A',
      author: map['author'] ?? 'N/A',
      creationDate: map['creation_date'] ?? 'N/A',
      width: map['dimensions']['width'] ?? 0,
      height: map['dimensions']['height'] ?? 0,
      blackPoints: _convertPoints(map['grid']['black_points'] as List),
      whitePoints: _convertPoints(map['grid']['white_points'] as List),
      ranking: _convertRanking(map['ranking'] as List),
    );
  }

  static List<List> _convertPoints(List<dynamic> points) {
    return points.map((point) => [point['x'], point['y']]).toList();
  }

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
      gameGrids.add(GameGrid.fromMap(map['id'], map));
    }
  }
}
