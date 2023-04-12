import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

import '../models/game_grid.dart';
import '../repositories/database/game_repository.dart';
import '../screens/home_screen.dart';
import 'game_grid_widget.dart';

class MapTileData {
  final String id;
  final String mapName;
  final String creatorName;
  final String bestTime;
  bool isFavorite;
  final GameGrid gameGrid;

  MapTileData({
    required this.id,
    required this.mapName,
    required this.creatorName,
    required this.bestTime,
    this.isFavorite = false,
    required this.gameGrid,
  });
}

List<MapTileData> mapData = [];

class CarouselWithFavorites extends StatefulWidget {
  const CarouselWithFavorites({Key? key}) : super(key: key);

  // StatefulWidget pour gérer l'état des favoris et afficher le carrousel approprié
  @override
  _CarouselWithFavoritesState createState() => _CarouselWithFavoritesState();
}

class _CarouselWithFavoritesState extends State<CarouselWithFavorites> {
  final GameRepository _gameRepository = GameRepository();

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  StreamSubscription<List<Map<String, dynamic>>>? _mapDataSubscription;

  void _loadMapData() {
    _mapDataSubscription
        ?.cancel(); // Annuler l'abonnement précédent, si existant
    _mapDataSubscription = _gameRepository.getAllMaps().listen((mapDataList) {
      setState(() {
        mapData = mapDataList.map<MapTileData>((map) {
          return MapTileData(
            id: map['id'],
            mapName: map['name'],
            creatorName: map['author'],
            bestTime: map['bestTime'] ?? 'N/A',
            isFavorite: map['isFavorite'] ?? false,
            gameGrid: GameGrid(
              author: map['author'],
              id: map['id'],
              name: map['name'],
              blackPoints: map['blackPoints'] ?? [],
              whitePoints: map['whitePoints'] ?? [],
              width: map['width'] ?? 5,
              height: map['height'] ?? 5,
            ),
          );
        }).toList();
      });
    });
  }

  @override
  void dispose() {
    _mapDataSubscription
        ?.cancel(); // Annuler l'abonnement lors de la suppression du widget
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final favoritesFilterNotifier =
        FavoritesFilterProvider.of(context)!.favoritesFilterNotifier;
    return ValueListenableBuilder<bool>(
      valueListenable: favoritesFilterNotifier,
      builder: (context, favoritesFilterEnabled, child) {
        final filteredMaps = favoritesFilterEnabled
            ? mapData.where((map) => map.isFavorite).toList()
            : mapData.where((map) => !map.isFavorite).toList();

        return CarouselSlider.builder(
          itemCount: filteredMaps.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final map = filteredMaps[index];

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Card(
                key: ValueKey<String>(map.id),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(map.mapName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 10),
                    GameGridWidget(gameGrid: map.gameGrid),
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
