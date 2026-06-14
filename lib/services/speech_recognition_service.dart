import 'dart:async';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';

class SpeechRecognitionService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isAvailable = false;
  bool _isListening = false;

  final _resultCtrl = StreamController<String>.broadcast();
  final _statusCtrl = StreamController<String>.broadcast();
  final _errorCtrl = StreamController<String>.broadcast();

  Stream<String> get resultStream => _resultCtrl.stream;
  Stream<String> get statusStream => _statusCtrl.stream;
  Stream<String> get errorStream => _errorCtrl.stream;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  // ── Initialisation + permissions ──────────────────────────────────────
  Future<bool> init() async {
    try {
      _isAvailable = await _speech.initialize(
        onStatus: (status) {
          _statusCtrl.add(status);
          if (status == 'done' || status == 'notListening') {
            _isListening = false;
          }
        },
        onError: (error) {
          _isListening = false;
          _errorCtrl.add(error.errorMsg);
        },
        debugLogging: false,
      );
      return _isAvailable;
    } catch (e) {
      _isAvailable = false;
      _errorCtrl.add('Initialisation impossible: $e');
      return false;
    }
  }

  // ── Démarrer l'écoute (arabe) ─────────────────────────────────────────
  // Tous les paramètres passent via SpeechListenOptions pour éviter
  // les warnings de dépréciation (localeId, listenFor, pauseFor).
  Future<void> startListening() async {
    if (!_isAvailable) {
      final ok = await init();
      if (!ok) {
        _errorCtrl.add('Microphone indisponible. Vérifiez les permissions.');
        return;
      }
    }

    _isListening = true;
    String accumulated = '';

    await _speech.listen(
      onResult: (SpeechRecognitionResult result) {
        accumulated = result.recognizedWords;
        _resultCtrl.add(accumulated);
      },
      listenOptions: stt.SpeechListenOptions(
        localeId: 'ar-SA',
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        cancelOnError: true,
        autoPunctuation: false,
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  // ── Arrêter l'écoute ───────────────────────────────────────────────────
  Future<void> stopListening() async {
    await _speech.stop();
    _isListening = false;
  }

  Future<void> cancel() async {
    await _speech.cancel();
    _isListening = false;
  }

  // ── Liste des langues disponibles (debug) ─────────────────────────────
  Future<List<stt.LocaleName>> getLocales() async {
    if (!_isAvailable) await init();
    return _speech.locales();
  }

  void dispose() {
    _speech.cancel();
    _resultCtrl.close();
    _statusCtrl.close();
    _errorCtrl.close();
  }
}
