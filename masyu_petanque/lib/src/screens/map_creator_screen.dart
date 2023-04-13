import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import '../widgets/burger_menu.dart';

class MapCreatorScreen extends StatelessWidget {
  const MapCreatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Editor'),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openDrawer(),
            );
          },
        ),
      ),
      drawer: DrawerMenu(userRepository: userRepository),
      body: const SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MapNameAndDimensionForm(),
            MapEditor(),
            ValidateButton(),
          ],
        ),
      ),
    );
  }
}

class MapNameAndDimensionForm extends StatelessWidget {
  const MapNameAndDimensionForm({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Map Name'),
                ),
                TextFormField(
                  decoration: const InputDecoration(labelText: 'Map Dimension'),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () {
              // Ajoutez votre logique d'enregistrement ici
            },
          ),
        ],
      ),
    );
  }
}

class MapEditor extends StatelessWidget {
  const MapEditor({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        // Ajoutez votre logique d'affichage de la map ici
        );
  }
}

class ValidateButton extends StatelessWidget {
  const ValidateButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () {
          // Ajoutez votre logique de validation ici
        },
        child: const Text('Validate'),
      ),
    );
  }
}

class MapEditorButtons extends StatelessWidget {
  const MapEditorButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
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
          icon: const Icon(Icons.horizontal_rule, color: Colors.black),
          onPressed: () {
            // Ajoutez votre logique pour le bouton barre noire ici
          },
        ),
        IconButton(
          icon: const Icon(Icons.undo),
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
    );
  }
}
