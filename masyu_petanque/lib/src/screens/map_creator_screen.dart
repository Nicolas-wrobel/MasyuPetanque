import 'package:flutter/material.dart';
import '../repositories/authentication/user_repository.dart';
import '../repositories/database/game_repository.dart';
import '../widgets/burger_menu.dart';
import 'dart:async';

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
  {'x1': 1, 'y1': 1},
  {'x2': 2, 'y2': 2},
];

List<Map<String, int>> noir = [
  {'x1': 3, 'y1': 3},
  {'x2': 4, 'y2': 4},
];

class MapEditorScreen extends StatelessWidget {
  MapEditorScreen({Key? key}) : super(key: key);

  final GameRepository _gameRepository =
      GameRepository(userRepository: UserRepository());

  final TextEditingController mapNameController = TextEditingController();
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();

  void _validateAndCreateMap(BuildContext context) {
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
              ),
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
                      // Ajoutez votre logique pour le bouton rond noir ici
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.circle, color: Colors.white),
                    onPressed: () {
                      // Ajoutez votre logique pour le bouton rond blanc ici
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.horizontal_rule, color: Colors.black),
                    onPressed: () {
                      // Ajoutez votre logique pour le bouton barre noire ici
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Ajoutez votre logique pour le bouton gomme ici
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.undo),
                    onPressed: () {
                      // Ajoutez votre logique pour le bouton retour en arrière ici
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () => _validateAndCreateMap(context),
                child: const Text('Validate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
