import 'package:flutter/material.dart';
import '../widgets/burger_menu.dart';

class MapEditorScreen extends StatelessWidget {
  const MapEditorScreen({Key? key}) : super(key: key);

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
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
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
                onPressed: () {
                  // Ajoutez votre logique pour le bouton valider ic
                },
                child: const Text('Validate'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
