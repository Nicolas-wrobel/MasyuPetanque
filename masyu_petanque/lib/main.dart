import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'src/repositories/database/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:masyu_petanque/src/screens/game_screen.dart';
import 'package:masyu_petanque/src/screens/home_screen.dart';
import 'package:masyu_petanque/src/screens/map_creator_screen.dart';
import 'package:masyu_petanque/src/screens/profile_screen.dart';
import 'package:masyu_petanque/src/screens/startup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kDebugMode) {
    print("Firebase initializing...");
  }
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    runApp(const MasuiApp());
}

class MasuiApp extends StatelessWidget {
  const MasuiApp({Key? key}) : super(key: key);
  } catch (e) {
    if (kDebugMode) {
      print(e);
    }
  }

  // MaterialApp qui définit le thème et le widget principal de l'application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masui',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          elevation: 0,
        ),
      ),
      home: FavoritesFilterProvider(
        favoritesFilterNotifier: ValueNotifier(false),
        child: const MainScreen(),
      ),
    );
  }
}

class FavoritesFilterProvider extends InheritedWidget {
  final ValueNotifier<bool> favoritesFilterNotifier;

  const FavoritesFilterProvider({
    Key? key,
    required this.favoritesFilterNotifier,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  bool updateShouldNotify(FavoritesFilterProvider oldWidget) {
    return favoritesFilterNotifier != oldWidget.favoritesFilterNotifier;
  }

  static FavoritesFilterProvider? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<FavoritesFilterProvider>();
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  // L'écran principal avec la barre d'applications et le tiroir du menu
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masyu Game',
      theme: ThemeData(
        primaryColor: Colors.black,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black),
      ),
      initialRoute: '/startup',
      routes: {
        '/startup': (context) => StartupScreen(),
        '/home': (context) => const HomeScreen(),
        '/game': (context) => const GameScreen(),
        '/map_creator': (context) => const MapCreatorScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      drawer: const DrawerMenu(),
      body: CarouselWithFavorites(),
    );
  }
}

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

class MapTileData {
  final String mapName;
  final String creatorName;
  final String bestTime;
  bool isFavorite;

  MapTileData({
    required this.mapName,
    required this.creatorName,
    required this.bestTime,
    this.isFavorite = false,
  });
}

List<MapTileData> mapData = [
  MapTileData(
    mapName: 'Nom de la map 1',
    creatorName: 'Créateur 1',
    bestTime: '00:30',
  ),
  MapTileData(
    mapName: 'Nom de la map 2',
    creatorName: 'Créateur 2',
    bestTime: '00:45',
  ),
  MapTileData(
    mapName: 'Nom de la map 3',
    creatorName: 'Créateur 3',
    bestTime: '00:50',
  ),
  // Ajoutez plus de MapTileData ici pour d'autres maps
];

class CarouselWithFavorites extends StatefulWidget {
  const CarouselWithFavorites({Key? key}) : super(key: key);

  // StatefulWidget pour gérer l'état des favoris et afficher le carrousel approprié
  @override
  _CarouselWithFavoritesState createState() => _CarouselWithFavoritesState();
}

class _CarouselWithFavoritesState extends State<CarouselWithFavorites> {
  @override
  Widget build(BuildContext context) {
    final favoritesFilterNotifier =
        FavoritesFilterProvider.of(context)!.favoritesFilterNotifier;
    return ValueListenableBuilder<bool>(
      valueListenable: favoritesFilterNotifier,
      builder: (context, favoritesFilterEnabled, child) {
        final filteredMaps = favoritesFilterEnabled
            ? mapData.where((map) => map.isFavorite).toList()
            : mapData;

        return CarouselSlider.builder(
          itemCount: filteredMaps.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final map = filteredMaps[index];

            return Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(map.mapName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),
                  const SizedBox(height: 10),
                  const SizedBox(height: 10),
                  Text('Créateur: ${map.creatorName}'),
                  Text('Meilleur temps: ${map.bestTime}'),
                  IconButton(
                    icon: Icon(
                      map.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: map.isFavorite ? Colors.red : null,
                    ),
                    onPressed: () {
                      setState(() {
                        map.isFavorite = !map.isFavorite;
                      });
                    },
                  ),
                ],
              ),
            );
          },
          options: CarouselOptions(
            height: MediaQuery.of(context).size.height * 0.8,
            viewportFraction: 0.8,
            enableInfiniteScroll: false,
          ),
        );
      },
    );
  }
}
