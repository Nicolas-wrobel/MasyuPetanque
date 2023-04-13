import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import '../repositories/authentication/user_repository.dart';
import '../repositories/database/game_repository.dart';
import '../widgets/burger_menu.dart';
import 'dart:async';

import '../widgets/game_grid_editor.dart';

enum ToolMode {
  addBlackCircle,
  addWhiteCircle,
  addBlackLine,
  eraseItem,
  undoAction
}

ToolMode currentToolMode = ToolMode.addBlackCircle;

Future<void> showAlertDialog(
    BuildContext context, String title, String content) {
  final completer = Completer<void>();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () {
              Navigator.of(context).pop();
              completer.complete();
            },
          ),
        ],
      );
    },
  );

  return completer.future;
}

List<Map<String, int>> blanc = [
  {},
  {'x': 1, 'y': 1},
  {'x': 2, 'y': 2},
];

List<Map<String, int>> noir = [
  {},
  {'x': 3, 'y': 3},
  {'x': 4, 'y': 4},
];

class MapCreatorScreen extends StatefulWidget {
  MapCreatorScreen({Key? key}) : super(key: key);

  @override
  _MapCreatorScreenState createState() => _MapCreatorScreenState();
}

class _MapCreatorScreenState extends State<MapCreatorScreen> {
  List<String> previousActions = [];

  GameMap gameMap = GameMap(
    author: "",
    creationDate: DateTime.now(),
    grid: GameGrid(blackPoints: [], whitePoints: [], width: 6, height: 6),
    id: '',
    name: '',
  );

  final GameRepository _gameRepository =
      GameRepository(userRepository: UserRepository());

  final TextEditingController mapNameController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  void _validateAndCreateMap(BuildContext context, GameMap gamemap) {
    if (heightController.text.trim().isEmpty ||
        widthController.text.trim().isEmpty ||
        mapNameController.text.trim().isEmpty) {
      // Affichez un message d'erreur
      showAlertDialog(context, "Erreur", "Il y a des champs vides.");
      return;
    }

    _gameRepository
        .createMap(
      height: int.parse(heightController.text),
      width: int.parse(widthController.text),
      blackPoints: noir,
      whitePoints: blanc,
      name: mapNameController.text,
    )
        .then((mapId) {
      // Gérez le résultat, par exemple en affichant un message de succès ou en naviguant vers une autre page
      if (mapId.isNotEmpty) {
        showAlertDialog(context, "Succès", "La carte a été créée avec succès.");
      } else {
        showAlertDialog(context, "Erreur", "La création de la carte a échoué.");
      }
    });
  }

//--------------------------------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Map Editor',
          style: TextStyle(color: Colors.black),
        ),
      ),
      drawer: const DrawerMenu(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: mapNameController,
                    decoration: const InputDecoration(
                      labelText: 'Map Name',
                      labelStyle: TextStyle(color: Colors.black),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: widthController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'L',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const Text(' x '),
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'H',
                            labelStyle: TextStyle(color: Colors.black),
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: const Icon(Icons.save),
                  onPressed: () {
                    // Ajoutez votre logique pour le bouton enregistrer ici
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                  color: Colors.grey[200],
                  // Votre widget pour afficher la map ici

                  child: GameGridWidgetEditor(
                    gameMap: GameMap(
                      author: gameMap.getAuthor,
                      creationDate: DateTime.now(),
                      grid: GameGrid(
                          blackPoints: gameMap.getGrid.blackPoints,
                          whitePoints: gameMap.getGrid.blackPoints,
                          width: gameMap.getGrid.width,
                          height: gameMap.getGrid.height),
                      id: '',
                      name: '',
                    ),
                    tool: currentToolMode,
                  )),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.circle, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        currentToolMode = ToolMode.addBlackCircle;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.circle, color: Colors.white),
                    onPressed: () {
                      setState(() {
                        currentToolMode = ToolMode.addWhiteCircle;
                      });
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.horizontal_rule, color: Colors.black),
                    onPressed: () {
                      setState(() {
                        currentToolMode = ToolMode.addBlackLine;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        currentToolMode = ToolMode.eraseItem;
                      });
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      setState(() {
                        currentToolMode = ToolMode.undoAction;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _validateAndCreateMap(context, gameMap),
                child: const Text('Validate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

@override
Widget build(BuildContext context) {
  // TODO: implement build
  throw UnimplementedError();
}
