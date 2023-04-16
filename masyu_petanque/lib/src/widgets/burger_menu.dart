import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/screens/startup_screen.dart';

import '../screens/home_screen.dart';

class DrawerMenu extends StatelessWidget {
  final UserRepository userRepository;
  final bool isMapCreator;

  const DrawerMenu(
      {Key? key, required this.userRepository, this.isMapCreator = false})
      : super(key: key);

  // Le menu tiroir avec les différentes options
  @override
  Widget build(BuildContext context) {
    final favoritesFilterProvider = FavoritesFilterProvider.of(context);
    final favoritesFilterNotifier =
        favoritesFilterProvider?.favoritesFilterNotifier;

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
            leading: isMapCreator || favoritesFilterNotifier?.value == true
                ? const Icon(Icons.home)
                : const Icon(Icons.favorite),
            title: isMapCreator || favoritesFilterNotifier?.value == true
                ? const Text('Home')
                : const Text('Favorites'),
            onTap: () {
              Navigator.pop(context); // Ferme le tiroir du menu
              if (isMapCreator) {
                Navigator.pushNamed(context, '/home');
              } else if (favoritesFilterNotifier != null) {
                favoritesFilterNotifier.value = !favoritesFilterNotifier.value;
              }
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
