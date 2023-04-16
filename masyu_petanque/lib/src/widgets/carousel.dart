import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/models/user.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/screens/game_screen.dart';
import 'package:masyu_petanque/src/models/game_grid.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/screens/home_screen.dart';
import 'package:masyu_petanque/src/widgets/game_grid_widget.dart';

// Définit un widget personnalisé de type StatefulWidget appelé CarouselWithFavorites
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
  final ValueNotifier<int> _currentIndex = ValueNotifier<int>(0);
  GameRepository gameRepository =
      GameRepository(userRepository: UserRepository());
  LocalUser? user;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Charge les données utilisateur
  Future<void> _loadUserData() async {
    final fetchedUser = await widget.userRepository.getUser();
    setState(() {
      user = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Si l'utilisateur n'est pas encore chargé, affiche un indicateur de chargement
    if (user == null) {
      return const CircularProgressIndicator();
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

            // Affiche le contenu en fonction du filtre de favoris et de l'état du favori
            return ValueListenableBuilder<bool>(
              valueListenable:
                  FavoritesFilterProvider.of(context)!.favoritesFilterNotifier,
              builder: (context, favoritesFilterEnabled, child) {
                final displayedMaps =
                    favoritesFilterEnabled ? favoriteMaps : mapData;

                if (favoritesFilterEnabled && favoriteMaps.isEmpty) {
                  return const Center(
                    child: Text("Vous n'avez pas encore de cartes favorites"),
                  );
                }

                // Construit un PageView avec les cartes filtrées
                return ValueListenableBuilder<int>(
                  valueListenable: _currentIndex,
                  builder: (context, index, _) {
                    final map = displayedMaps[index];

                    // Affiche les détails de la carte et le bouton de favori
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          SizedBox(
                              height:
                                  MediaQuery.of(context).size.height * 0.15),
                          Text(map.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              )),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * 0.425,
                            child: PageView.builder(
                              itemBuilder: (BuildContext context, int index) {
                                final map = displayedMaps[index];

                                // Crée un widget InkWell avec un GameGridWidget pour chaque carte
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 25.0),
                                  child: InkWell(
                                    onTap: () {
                                      // Navigue vers l'écran de jeu lorsqu'on clique sur une carte
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => GameScreen(
                                            mapId: map.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: AspectRatio(
                                      aspectRatio:
                                          map.grid.width / map.grid.height,
                                      child: GameGridWidget(
                                          gameMap: map, isPreview: true),
                                    ),
                                  ),
                                );
                              },
                              itemCount: displayedMaps.length,
                              onPageChanged: (int newIndex) {
                                // Mettez à jour l'index lorsque l'utilisateur change de page
                                _currentIndex.value = newIndex;
                              },
                            ),
                          ),
                          const SizedBox(
                            height: 20.0,
                          ),
                          Text('Créateur: ${map.author}'),
                          Text('Meilleur temps: ${map.bestTime ?? 'N/A'}'),
                          // Crée un bouton pour ajouter/supprimer la carte des favoris
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
                                  gameRepository.removeMapFromFavorites(map.id);
                                  favorites.remove(map.id);
                                } else {
                                  gameRepository.addMapToFavorites(map.id);
                                  favorites.add(map.id);
                                }
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          }
        });
  }
}
