import 'package:flutter/material.dart';
import 'package:masyu_petanque/src/repositories/authentication/user_repository.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Home')),
        // body is containing a signout button, just for testing
        body: Center(
            child: ElevatedButton(
          onPressed: () {
            _userRepository.signOut();
          },
          child: const Text('Sign out'),
        )));
  }
}
