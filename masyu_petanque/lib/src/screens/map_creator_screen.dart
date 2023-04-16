import 'dart:async';
import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/widgets/burger_menu.dart';
import 'package:masyu_petanque/src/widgets/game_grid_editor.dart';

// Enumération pour les modes d'outils disponibles dans l'éditeur de carte
enum ToolMode {
  addBlackCircle,
  addWhiteCircle,
  addBlackLine,
  eraseItem,
  undoAction
}

ToolMode currentToolMode = ToolMode.addBlackCircle;

// Fonction pour afficher une boîte de dialogue d'alerte
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

List<Map<String, int>> blanc = [{}];
List<Map<String, int>> noir = [{}];

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

  final TextEditingController mapNameController =
      TextEditingController(text: "Map");
  final TextEditingController widthController =
      TextEditingController(text: "6");
  final TextEditingController heightController =
      TextEditingController(text: "6");

  // Fonction pour valider et créer la carte
  void _validateAndCreateMap(BuildContext context, GameMap gamemap) {
    if (heightController.text.trim().isEmpty ||
        widthController.text.trim().isEmpty ||
        mapNameController.text.trim().isEmpty) {
      showAlertDialog(context, "Erreur", "Il y a des champs vides.");
      return;
    }

    for (Point p in gameMap.getGrid.blackPoints) {
      noir.add(<String, int>{'x': p.x, 'y': p.y});
    }

    for (Point p in gameMap.getGrid.whitePoints) {
      blanc.add(<String, int>{'x': p.x, 'y': p.y});
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
      if (mapId.isNotEmpty) {
        showAlertDialog(context, "Succès", "La carte a été créée avec succès.");
      } else {
        showAlertDialog(context, "Erreur", "La création de la carte a échoué.");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
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
      drawer: DrawerMenu(
        userRepository: userRepository,
        isMapCreator: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Champs pour le nom de la carte et les dimensions (largeur et hauteur)
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
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Grille de l'éditeur de carte
            Expanded(
              child: Container(
                  color: Colors.grey[200],
                  child: GameGridWidgetEditor(
                    gameMap: GameMap(
                      author: gameMap.getAuthor,
                      creationDate: DateTime.now(),
                      grid: GameGrid(
                          blackPoints: gameMap.getGrid.blackPoints,
                          whitePoints: gameMap.getGrid.whitePoints,
                          width: int.parse(widthController.text),
                          height: int.parse(heightController.text)),
                      id: '',
                      name: '',
                    ),
                    tool: currentToolMode,
                  )),
            ),
            const SizedBox(height: 16),
            // Barre d'outils pour l'édition de la carte
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
            // Bouton pour valider et créer la carte
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
