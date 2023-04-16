import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

// Modèle pour gérer un chronomètre
class TimerModel extends ChangeNotifier {
  Timer? _timer; // Timer pour suivre le temps écoulé
  int _elapsedMilliseconds = 0; // Temps écoulé en millisecondes
  final _format = NumberFormat("00"); // Format pour afficher le temps écoulé

  // Méthode pour obtenir le temps écoulé formaté
  String get elapsedTime {
    final minutes = _elapsedMilliseconds ~/ (60 * 1000);
    final seconds = (_elapsedMilliseconds % (60 * 1000)) ~/ 1000;
    final milliseconds = (_elapsedMilliseconds % 1000) ~/ 10;
    return '${_format.format(minutes)}:${_format.format(seconds)}.${_format.format(milliseconds)}';
  }

  // Méthode pour démarrer le chronomètre
  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(milliseconds: 10), (Timer timer) {
      _elapsedMilliseconds += 10;
      notifyListeners();
    });
  }

  // Méthode pour arrêter le chronomètre
  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  // Méthode pour réinitialiser le chronomètre
  void reset() {
    stop();
    _elapsedMilliseconds = 0;
    notifyListeners();
  }

  // Méthode pour nettoyer les ressources lors de la suppression de l'objet
  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
