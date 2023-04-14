import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/screens/startup_screen.dart';

import '../screens/home_screen.dart';

class DrawerMenu extends StatelessWidget {
  final UserRepository userRepository;

  const DrawerMenu({Key? key, required this.userRepository}) : super(key: key);

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
              Navigator.pop(context); // Ferme le tiroir du menu
              Navigator.pushNamed(context, '/map_creator');
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
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sign Out'),
            onTap: () async {
              const rootRouteName = '/startup';
              final navigator = Navigator.of(context);
              await userRepository.signOut();
              navigator.pushNamedAndRemoveUntil(rootRouteName,
                  (route) => route.settings.name == rootRouteName);
            },
          ),
        ],
      ),
    );
  }
}
