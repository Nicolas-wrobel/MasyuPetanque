import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:masyu_petanque/src/repositories/database/game_repository.dart';
import 'package:masyu_petanque/src/widgets/burger_menu.dart';
import 'package:masyu_petanque/src/widgets/carousel.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';
import 'package:masyu_petanque/src/models/timer_model.dart';

// Classe pour l'écran d'accueil
class HomeScreen extends StatelessWidget {
  final UserRepository _userRepository;

  // Constructeur privé
  const HomeScreen._({Key? key, required UserRepository userRepository})
      : _userRepository = userRepository,
        super(key: key);

  // Méthode statique pour créer une instance de HomeScreen
  static HomeScreen create({Key? key}) {
    final userRepository = UserRepository();
    return HomeScreen._(key: key, userRepository: userRepository);
  }

  @override
  Widget build(BuildContext context) {
    // Utilisation de FavoritesFilterProvider et ChangeNotifierProvider pour gérer les favoris et le timer
    return FavoritesFilterProvider(
      favoritesFilterNotifier: ValueNotifier(false),
      child: ChangeNotifierProvider<TimerModel>(
        create: (context) => TimerModel(),
        child: const MainScreen(),
      ),
    );
  }
}

// Classe pour le provider de filtre de favoris
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

// Classe pour l'écran principal avec la barre d'applications et le menu burger
class MainScreen extends StatelessWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final userRepository = UserRepository();
    final gameRepository = GameRepository(userRepository: userRepository);

    // Création de la barre d'applications et du menu burger
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Masyu',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
            );
          },
        ),
      ),
      drawer: DrawerMenu(
        userRepository: userRepository,
      ),
      // Utilisation du widget CarouselWithFavorites pour afficher les favoris
      body: CarouselWithFavorites(
        userRepository: userRepository,
        gameRepository: gameRepository,
      ),
    );
  }
}
