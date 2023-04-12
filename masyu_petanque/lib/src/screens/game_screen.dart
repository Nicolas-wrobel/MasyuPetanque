import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';

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
  final UserRepository _userRepository;
  final GameRepository _gameRepository;

  GameGridScreen._({Key? key, required UserRepository userRepository})
      : _userRepository = userRepository,
        _gameRepository = GameRepository(userRepository: userRepository),
        super(key: key);

  // Static method to create an instance of GameGridScreen
  static GameGridScreen create({Key? key}) {
    final userRepository = UserRepository();
    return GameGridScreen._(key: key, userRepository: userRepository);
  }

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
            children: [
              for (final Map<String, dynamic> map in mapData)
                Text(map['name'] as String),
            ],
          );
        },
      ),
    );
  }
}
