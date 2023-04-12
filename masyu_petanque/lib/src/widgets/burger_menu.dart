import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

class DrawerMenu extends StatelessWidget {
  const DrawerMenu({Key? key}) : super(key: key);

  // Le menu tiroir avec les différentes options
  @override
  Widget build(BuildContext context) {
    final favoritesFilterNotifier =
        FavoritesFilterProvider.of(context)!.favoritesFilterNotifier;

    return Drawer(
      child: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('Edit'),
            onTap: () {
              // Add navigation logic here
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              // Add navigation logic here
            },
          ),
          ListTile(
            leading: favoritesFilterNotifier.value
                ? const Icon(Icons.home)
                : const Icon(Icons.favorite),
            title: favoritesFilterNotifier.value
                ? const Text('Home')
                : const Text('Favorites'),
            onTap: () {
              Navigator.pop(context); // Ferme le tiroir du menu
              favoritesFilterNotifier.value = !favoritesFilterNotifier.value;
            },
          ),
        ],
      ),
    );
  }
}
