import 'package:flutter/material.dart';

import '../models/game_grid.dart';
import '../repositories/database/game_repository.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class GameGridScreen extends StatelessWidget {
  final GameRepository _gameRepository = GameRepository();

  GameGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Game Grid')),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _gameRepository.getAllMaps(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text('An error has occurred'));
          }

          if (snapshot.data == null) {
            return const Center(child: Text('No data available'));
          }

          final List<Map<String, dynamic>> mapData = snapshot.data!;
          return Column(
            children: mapData
                .map((map) => [
                      Text(map['name'] as String),
                      Text(map['author'] as String),
                      Text(map['ranking'][0][""] as String),
                    ])
                .expand((widgetList) => widgetList)
                .toList(),
          );
        },
      ),
    );
  }
}
