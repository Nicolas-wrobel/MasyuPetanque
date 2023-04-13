import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/user.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';

import '../models/game_grid.dart';
import '../repositories/database/game_repository.dart';
import '../screens/home_screen.dart';
import 'game_grid_widget.dart';

class CarouselWithFavorites extends StatefulWidget {
  final UserRepository userRepository;
  final GameRepository gameRepository;

  const CarouselWithFavorites({
    Key? key,
    required this.userRepository,
    required this.gameRepository,
  }) : super(key: key);

  @override
  _CarouselWithFavoritesState createState() => _CarouselWithFavoritesState();
}

class _CarouselWithFavoritesState extends State<CarouselWithFavorites> {
  List<GameMap> mapData = [];
  LocalUser? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final fetchedUser = await widget.userRepository.getUser();
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return const CircularProgressIndicator(); // Afficher un indicateur de chargement si l'utilisateur n'est pas encore chargé
    }

    // Récupérer les cartes favorites de l'utilisateur
    final favorites = user!.favoriteMaps;

    // Utiliser un FutureBuilder pour récupérer les données des cartes
    return FutureBuilder<List<GameMap>>(
        future: widget.gameRepository.getAllMapsOnce(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            if (kDebugMode) {
              print(snapshot.error);
            }
            return const Text('Erreur lors du chargement des données ');
          } else {
            // Filtrer les cartes favorites
            final mapData = snapshot.data!;
            final favoriteMaps =
                mapData.where((map) => favorites.contains(map.id)).toList();

            return ValueListenableBuilder<bool>(
              valueListenable:
                  FavoritesFilterProvider.of(context)!.favoritesFilterNotifier,
              builder: (context, favoritesFilterEnabled, child) {
                final displayedMaps =
                    favoritesFilterEnabled ? favoriteMaps : mapData;

                return CarouselSlider.builder(
                  itemCount: displayedMaps.length,
                  itemBuilder:
                      (BuildContext context, int index, int realIndex) {
                    final map = displayedMaps[index];

                    return AnimatedSwitcher(
                      duration: const Duration(milliseconds: 500),
                      child: Card(
                        key: ValueKey<String>(map.id),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(map.name,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                )),
                            const SizedBox(height: 10),
                            SizedBox(
                              height: MediaQuery.of(context).size.height *
                                  0.4, // Ajustez cette valeur selon vos besoins
                              child: GameGridWidget(gameMap: map),
                            ),
                            const SizedBox(height: 10),
                            Text('Créateur: ${map.author}'),
                            Text('Meilleur temps: ${map.bestTime ?? 'N/A'}'),
                            IconButton(
                              icon: Icon(
                                favorites.contains(map.id)
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: favorites.contains(map.id)
                                    ? Colors.red
                                    : null,
                              ),
                              onPressed: () {
                                setState(() {
                                  if (favorites.contains(map.id)) {
                                    favorites.remove(map.id);
                                  } else {
                                    favorites.add(map.id);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
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
        });
  }
}
