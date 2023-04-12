import 'dart:async';

import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/game_grid.dart';
import '../repositories/database/game_repository.dart';
import '../screens/home_screen.dart';
import 'game_grid_widget.dart';

class CarouselWithFavorites extends StatefulWidget {
  const CarouselWithFavorites({Key? key}) : super(key: key);

  @override
  _CarouselWithFavoritesState createState() => _CarouselWithFavoritesState();
}

class _CarouselWithFavoritesState extends State<CarouselWithFavorites> {
  final GameRepository _gameRepository = GameRepository();
  List<Map<String, dynamic>> mapData = [];

  @override
  void initState() {
    super.initState();
    _loadMapData();
  }

  StreamSubscription<List<Map<String, dynamic>>>? _mapDataSubscription;

  void _loadMapData() {
    _mapDataSubscription?.cancel();
    _mapDataSubscription = _gameRepository.getAllMaps().listen((mapDataList) {
      setState(() {
        mapData = mapDataList;
      });
    });
  }

  @override
  void dispose() {
    _mapDataSubscription?.cancel();
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
            ? mapData.where((map) => map['isFavorite'] as bool).toList()
            : mapData.where((map) => !(map['isFavorite'] as bool)).toList();

        return CarouselSlider.builder(
          itemCount: filteredMaps.length,
          itemBuilder: (BuildContext context, int index, int realIndex) {
            final map = filteredMaps[index];

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: Card(
                key: ValueKey<String>(map['id'] as String),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(map['name'] as String,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        )),
                    const SizedBox(height: 10),
                    GameGridWidget(
                        gameGrid: GameGrid(
                      author: map['author'] as String,
                      id: map['id'] as String,
                      name: map['name'] as String,
                      blackPoints: map['blackPoints'] as List<List<int>>,
                      whitePoints: map['whitePoints'] as List<List<int>>,
                      width: map['width'] as int,
                      height: map['height'] as int,
                    )),
                    const SizedBox(height: 10),
                    Text('Créateur: ${map['author'] as String}'),
                    Text('Meilleur temps: ${map['bestTime'] ?? 'N/A'}'),
                    IconButton(
                      icon: Icon(
                        map['isFavorite'] as bool
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: map['isFavorite'] as bool ? Colors.red : null,
                      ),
                      onPressed: () {
                        setState(() {
                          map['isFavorite'] = !(map['isFavorite'] as bool);
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
