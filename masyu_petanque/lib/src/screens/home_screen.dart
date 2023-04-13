import 'package:flutter/material.dart';
import '../widgets/burger_menu.dart';
import '../widgets/carousel.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';

void main() {
  runApp(HomeScreen._(userRepository: UserRepository()));
}

class HomeScreen extends StatelessWidget {
  final UserRepository _userRepository;

  const HomeScreen._({Key? key, required UserRepository userRepository})
      : _userRepository = userRepository,
        super(key: key);

  // Static method to create an instance of StartupScreen
  static HomeScreen create({Key? key}) {
    final userRepository = UserRepository();
    return HomeScreen._(key: key, userRepository: userRepository);
  }

  // MaterialApp qui définit le thème et le widget principal de l'application
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Masyu',
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

  // L'écran principal avec la barre d'applications et le burger menu
  @override
  Widget build(BuildContext context) {
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
      drawer: const DrawerMenu(),
      body: const CarouselWithFavorites(),
    );
  }
}
