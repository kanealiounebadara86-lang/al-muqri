import 'dart:async';
import 'package:just_audio/just_audio.dart';
import 'audio_cache_service.dart';
import 'package:audio_session/audio_session.dart';
import '../models/models.dart';

enum PlayerState { idle, loading, playing, paused, completed, error }

enum PlayMode { single, takrar, continuous }

typedef AudioUrlGetter = String Function(int ayahInSurah, String reciterId);
typedef AudioUrlListGetter = List<String> Function(
    int ayahInSurah, String reciterId);

class AudioService {
  AudioPlayer? _player;
  ConcatenatingAudioSource? _playlist;

  final _stateCtrl = StreamController<PlayerState>.broadcast();
  final _ayahCtrl = StreamController<int>.broadcast();
  final _progressCtrl = StreamController<TakrarProgress>.broadcast();
  final _indexCtrl = StreamController<int>.broadcast();

  Stream<PlayerState> get stateStream => _stateCtrl.stream;
  Stream<int> get currentAyahStream => _ayahCtrl.stream;
  Stream<TakrarProgress> get progressStream => _progressCtrl.stream;
  Stream<int> get currentIndexStream => _indexCtrl.stream;

  PlayerState _state = PlayerState.idle;
  bool _cancelled = false;
  PlayMode _mode = PlayMode.single;
  int _sessionId = 0;
  final _errorCtrl = StreamController<String>.broadcast();
  Stream<String> get errorStream => _errorCtrl.stream;

  Future<void> init() async {
    _player = AudioPlayer();

    // Écouter les changements d'index (pour lecture continue)
    _player!.currentIndexStream.listen((index) {
      if (index != null) {
        _indexCtrl.add(index);
        _ayahCtrl.add(index + 1);
      }
    });

    // Écouter la fin de la playlist
    _player!.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _setState(PlayerState.completed);
      }
    });

    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: true,
      ));
    } catch (_) {}
  }

  // ── STOP total ────────────────────────────────────────────────────────
  Future<void> stop() async {
    _cancelled = true;
    _sessionId++; // invalide tout appel _playOne en cours
    try {
      await _player?.stop();
    } catch (_) {}
    _setState(PlayerState.idle);
  }

  Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (_) {}
    _setState(PlayerState.paused);
  }

  Future<void> resume() async {
    try {
      await _player?.play();
    } catch (_) {}
    _setState(PlayerState.playing);
  }

  // ── Jouer une URL simple (adhan, iqamah, etc.) ────────────────────────
  Future<void> playUrl(String url) async {
    await stop();
    _cancelled = false;
    _mode = PlayMode.single;
    final session = ++_sessionId;
    await _playOne(url, 1.0, session: session);
  }

  // ── Lecture continue d'une sourate entière ────────────────────────────
  Future<void> playSurahContinuous({
    required List<String> audioUrls,
    required double speed,
    int startIndex = 0,
  }) async {
    await stop();
    _cancelled = false;
    _mode = PlayMode.continuous;
    _setState(PlayerState.loading);

    try {
      // Créer une playlist avec tous les versets
      final sources =
          audioUrls.map((url) => AudioSource.uri(Uri.parse(url))).toList();
      _playlist = ConcatenatingAudioSource(children: sources);

      await _player!.setAudioSource(_playlist!, initialIndex: startIndex);
      await _player!.setSpeed(speed);
      await _player!.setLoopMode(LoopMode.off);
      _setState(PlayerState.playing);
      await _player!.play();
    } catch (e) {
      _setState(PlayerState.error);
    }
  }

  // ── Sauter à un verset spécifique dans la playlist ────────────────────
  Future<void> seekToAyah(int index) async {
    try {
      await _player?.seek(Duration.zero, index: index);
    } catch (_) {}
  }

  // ── Moteur Takrar (répétition) ────────────────────────────────────────
  Future<void> startTakrar({
    required List<Ayah> ayahs,
    required RecitationSettings settings,
    required AudioUrlGetter getAudioUrl,
    AudioUrlGetter? getFallbackUrl,
    AudioUrlListGetter? getExtraFallbacks,
    int startIndex = 0,
  }) async {
    await stop();
    _cancelled = false;
    _mode = PlayMode.takrar;
    final session = ++_sessionId;
    _setState(PlayerState.playing);

    for (int cycle = 0;
        cycle < settings.repetitionsTotal &&
            !_cancelled &&
            session == _sessionId;
        cycle++) {
      for (int i = startIndex;
          i < ayahs.length && !_cancelled && session == _sessionId;
          i++) {
        final ayah = ayahs[i];
        _ayahCtrl.add(ayah.numberInSurah);

        for (int rep = 0;
            rep < settings.repetitionsPerAyah &&
                !_cancelled &&
                session == _sessionId;
            rep++) {
          _progressCtrl.add(TakrarProgress(
            currentAyahIndex: i,
            currentRepetition: rep + 1,
            totalRepetitions: settings.repetitionsPerAyah,
            totalCycleRepetition: cycle + 1,
            totalCycles: settings.repetitionsTotal,
          ));
          final url = getAudioUrl(ayah.numberInSurah, settings.reciterId);
          final fallback = getFallbackUrl != null
              ? getFallbackUrl(ayah.numberInSurah, settings.reciterId)
              : null;
          final extras = getExtraFallbacks != null
              ? getExtraFallbacks(ayah.numberInSurah, settings.reciterId)
              : <String>[];
          await _playOne(url, settings.playbackSpeed,
              fallbackUrl: fallback, extraUrls: extras, session: session);
          if (!_cancelled &&
              session == _sessionId &&
              rep < settings.repetitionsPerAyah - 1) {
            await _delay((settings.delayBetweenAyahs * 400).clamp(0, 2000));
          }
        }
        if (!_cancelled && session == _sessionId && i < ayahs.length - 1) {
          await _delay((settings.delayBetweenAyahs * 600).clamp(0, 2500));
        }
      }
    }
    if (!_cancelled && session == _sessionId) {
      _setState(PlayerState.completed);
    }
  }

  Future<void> _playOne(String url, double speed,
      {String? fallbackUrl,
      List<String> extraUrls = const [],
      int session = 0}) async {
    if (_cancelled || _player == null || session != _sessionId) return;
    final urls = [
      url,
      if (fallbackUrl != null && fallbackUrl != url) fallbackUrl,
      ...extraUrls.where((u) => u != url && u != fallbackUrl),
    ];
    bool played = false;

    for (final tryUrl in urls) {
      if (_cancelled || session != _sessionId) return;
      try {
        _setState(PlayerState.loading);
        // Utiliser le cache local si disponible (hors ligne sur mobile)
        final cachedPath = await AudioCacheService.getCachedOrDownload(tryUrl);
        if (_cancelled || session != _sessionId) return;
        if (cachedPath != tryUrl && !cachedPath.startsWith('http')) {
          // Fichier local mis en cache
          await _player!.setFilePath(cachedPath);
        } else {
          // URL distante avec timeout
          await _player!.setUrl(tryUrl).timeout(const Duration(seconds: 12),
              onTimeout: () => throw Exception('timeout'));
        }
        if (_cancelled || session != _sessionId) return;
        await _player!.setSpeed(speed.clamp(0.5, 2.0));
        _setState(PlayerState.playing);
        await _player!.play();
        // Attendre la fin avec timeout global
        await _player!.processingStateStream
            .firstWhere((s) =>
                s == ProcessingState.completed || s == ProcessingState.idle)
            .timeout(const Duration(seconds: 90),
                onTimeout: () => ProcessingState.idle);
        played = true;
        break;
      } on Exception catch (e) {
        // URL échouée (CORS, 403, timeout, interruption) → tenter le fallback
        if (session != _sessionId) return;
        _errorCtrl.add('Échec: $tryUrl — $e');
        try {
          await _player!.stop();
        } catch (_) {}
      } catch (e) {
        if (session != _sessionId) return;
        _errorCtrl.add('Échec: $tryUrl — $e');
        try {
          await _player!.stop();
        } catch (_) {}
      }
    }
    if (!played && !_cancelled && session == _sessionId) {
      _errorCtrl.add('Toutes les sources ont échoué pour cet ayah.');
      _setState(PlayerState.idle);
    }
  }

  Future<void> _delay(double ms) async {
    if (_cancelled) return;
    await Future.delayed(Duration(milliseconds: ms.round()));
  }

  void _setState(PlayerState s) {
    _state = s;
    if (!_stateCtrl.isClosed) {
      _stateCtrl.add(s);
    }
  }

  PlayerState get currentState => _state;
  PlayMode get playMode => _mode;

  // Position actuelle dans la playlist
  int get currentIndex => _player?.currentIndex ?? 0;
  Duration get position => _player?.position ?? Duration.zero;
  Duration? get duration => _player?.duration;

  Future<void> dispose() async {
    _cancelled = true;
    await _player?.dispose();
    _player = null;
    await _stateCtrl.close();
    await _ayahCtrl.close();
    await _progressCtrl.close();
    await _indexCtrl.close();
  }
}

class TakrarProgress {
  final int currentAyahIndex;
  final int currentRepetition;
  final int totalRepetitions;
  final int totalCycleRepetition;
  final int totalCycles;
  const TakrarProgress({
    required this.currentAyahIndex,
    required this.currentRepetition,
    required this.totalRepetitions,
    required this.totalCycleRepetition,
    required this.totalCycles,
  });
}
