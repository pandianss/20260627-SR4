import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Real text-to-speech narration of lesson cards using the device's on-device
/// speech engine (Google's neural TTS on Android, AVSpeechSynthesizer on iOS) —
/// natural-sounding, offline, no API keys. Speaks each card's text in turn and
/// reports progress so the lesson UI can follow along.
///
/// Public surface (play/pause/resume/stop + isPlaying/isPaused/currentIndex/
/// currentText) is unchanged from the previous timer-based stub; state is
/// updated synchronously so callers/tests observe it immediately, while the
/// engine calls are async + guarded.
class AudioNarrationService extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  bool _configured = false;

  List<String> _texts = [];
  int _currentIndex = -1;
  bool _isPlaying = false;
  bool _isPaused = false;

  void Function(int index)? _onProgress;
  void Function()? _onDone;

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  int get currentIndex => _currentIndex;
  String get currentText => (_currentIndex >= 0 && _currentIndex < _texts.length)
      ? _texts[_currentIndex]
      : '';

  void play(
    List<String> texts, {
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

  Future<void> _configure() async {
    if (_configured) return;
    try {
      // Prefer Google's neural engine on Android for the most natural voice.
      final engines = await _tts.getEngines;
      if (engines is List && engines.contains('com.google.android.tts')) {
        await _tts.setEngine('com.google.android.tts');
      }
    } catch (_) {}
    await _tts.setLanguage(await _pickLanguage());
    await _tts.setSpeechRate(0.5); // natural pace
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _tts.setCompletionHandler(() {
      if (_isPlaying && !_isPaused) _advance();
    });
    _tts.setCancelHandler(() {});
    _tts.setErrorHandler((dynamic msg) => debugPrint('TTS error: $msg'));
    _configured = true;
  }

  Future<String> _pickLanguage() async {
    try {
      final langs = await _tts.getLanguages;
      final available =
          (langs as List).map((e) => e.toString()).toList();
      for (final pref in const ['en-IN', 'en-US', 'en-GB']) {
        if (available.contains(pref)) return pref;
      }
    } catch (_) {}
    return 'en-US';
  }

  Future<void> _speakCurrent() async {
    if (!_isPlaying || _isPaused || _currentIndex >= _texts.length) return;
    try {
      await _configure();
      if (!_isPlaying || _isPaused) return;
      _onProgress?.call(_currentIndex);
      notifyListeners();
      await _tts.speak(_texts[_currentIndex]);
    } catch (e) {
      debugPrint('TTS speak failed: $e');
    }
  }

  void _advance() {
    if (_currentIndex + 1 < _texts.length) {
      _currentIndex++;
      _speakCurrent();
    } else {
      final done = _onDone;
      stop();
      done?.call();
    }
  }

  void pause() {
    if (_isPlaying && !_isPaused) {
      _isPaused = true;
      _tts.stop().catchError((Object e) {
        debugPrint('TTS pause failed: $e');
      });
      notifyListeners();
    }
  }

  void resume() {
    if (_isPlaying && _isPaused) {
      _isPaused = false;
      notifyListeners();
      // The engine can't resume mid-utterance, so re-speak the current card.
      _speakCurrent();
    }
  }

  void stop() {
    _isPlaying = false;
    _isPaused = false;
    _currentIndex = -1;
    _texts = [];
    _tts.stop().catchError((Object e) {
      debugPrint('TTS stop failed: $e');
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop().catchError((Object _) {});
    super.dispose();
  }
}
