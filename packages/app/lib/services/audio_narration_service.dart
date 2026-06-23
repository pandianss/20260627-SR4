import 'dart:async';
import 'package:flutter/foundation.dart';

class AudioNarrationService extends ChangeNotifier {
  List<String> _texts = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _isPaused = false;
  Timer? _timer;
  int _secondsRemaining = 0;

  void Function(int index)? _onProgress;
  void Function()? _onDone;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentIndex => _currentIndex;
  String get currentText => (_currentIndex >= 0 && _currentIndex < _texts.length) ? _texts[_currentIndex] : '';

  void play(List<String> texts, {
    required void Function(int index) onProgress,
    required void Function() onDone,
  }) {
    stop();
    _texts = texts;
    _currentIndex = 0;
    _isPlaying = true;
    _isPaused = false;
    _onProgress = onProgress;
    _onDone = onDone;
    notifyListeners();

    _speakCurrent();
  }

  void _speakCurrent() {
    if (!_isPlaying || _isPaused || _currentIndex < 0 || _currentIndex >= _texts.length) return;

    _onProgress?.call(_currentIndex);
    notifyListeners();

    // Simulate reading duration: ~3 words per second, min 3s, max 8s
    final words = _texts[_currentIndex].split(RegExp(r'\s+')).length;
    final durationSec = (words / 3.0).round().clamp(3, 8);

    _secondsRemaining = durationSec;

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isPaused) return;

      _secondsRemaining--;
      if (_secondsRemaining <= 0) {
        timer.cancel();
        _next();
      }
    });
  }

  void _next() {
    if (_currentIndex + 1 < _texts.length) {
      _currentIndex++;
      _speakCurrent();
    } else {
      stop();
      _onDone?.call();
    }
  }

  void pause() {
    if (_isPlaying && !_isPaused) {
      _isPaused = true;
      _timer?.cancel();
      notifyListeners();
    }
  }

  void resume() {
    if (_isPlaying && _isPaused) {
      _isPaused = false;
      notifyListeners();
      
      // Continue speaking current card with remaining seconds
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_isPaused) return;

        _secondsRemaining--;
        if (_secondsRemaining <= 0) {
          timer.cancel();
          _next();
        }
      });
    }
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    _isPlaying = false;
    _isPaused = false;
    _currentIndex = -1;
    _texts = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
