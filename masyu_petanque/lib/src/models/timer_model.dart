import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class TimerModel extends ChangeNotifier {
  Timer? _timer;
  int _elapsedMilliseconds = 0;
  final _format = NumberFormat("00");

  String get elapsedTime {
    final minutes = _elapsedMilliseconds ~/ (60 * 1000);
    final seconds = (_elapsedMilliseconds % (60 * 1000)) ~/ 1000;
    final milliseconds = (_elapsedMilliseconds % 1000) ~/ 10;
    return '${_format.format(minutes)}:${_format.format(seconds)}.${_format.format(milliseconds)}';
  }

  void start() {
    if (_timer != null) return;

    _timer = Timer.periodic(const Duration(milliseconds: 10), (Timer timer) {
      _elapsedMilliseconds += 10;
      notifyListeners();
    });
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void reset() {
    stop();
    _elapsedMilliseconds = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
