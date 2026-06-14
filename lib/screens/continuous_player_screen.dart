import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../data/reciters_data.dart';

class ContinuousPlayerScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  const ContinuousPlayerScreen({super.key, required this.surahNumber});

  @override
  ConsumerState<ContinuousPlayerScreen> createState() =>
      _ContinuousPlayerScreenState();
}

class _ContinuousPlayerScreenState
    extends ConsumerState<ContinuousPlayerScreen> {
  int _currentAyah = 1;
  PlayerState _playerState = PlayerState.idle;
  late AudioService _audio;

  @override
  void initState() {
    super.initState();
    _audio = ref.read(audioServiceProvider);
    _audio.stateStream.listen((s) {
      if (mounted) setState(() => _playerState = s);
    });
    _audio.currentIndexStream.listen((i) {
      if (mounted) setState(() => _currentAyah = i + 1);
    });
  }

  @override
  void dispose() {
    _audio.stop();
    super.dispose();
  }

  Future<void> _startContinuous() async {
    final settings = ref.read(settingsProvider);
    final urls = ref
        .read(quranApiProvider)
        .getSurahAudioUrls(widget.surahNumber, settings.reciterId);
    await _audio.playSurahContinuous(
      audioUrls: urls,
      speed: settings.playbackSpeed,
      startIndex: _currentAyah - 1,
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final surah = ref.watch(selectedSurahProvider);
    final ayahsAsync = ref.watch(ayahsProvider(AyahParams(
      surahNumber: widget.surahNumber,
      translationLang:
          settings.showTranslation ? settings.translationLang : 'none',
    )));

    return Scaffold(
      body: ayahsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (ayahs) => _buildPlayer(ayahs, surah, settings),
      ),
    );
  }

  Widget _buildPlayer(List<Ayah> ayahs, Surah? surah, RecitationSettings s) {
    final isPlaying = _playerState == PlayerState.playing;
    final isLoading = _playerState == PlayerState.loading;
    final ayah = _currentAyah > 0 && _currentAyah <= ayahs.length
        ? ayahs[_currentAyah - 1]
        : null;

    return SafeArea(
        child: Column(children: [
      // AppBar
      _buildAppBar(surah),

      // Verset en cours
      Expanded(
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          // Indicateur de progression
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(12)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Verset $_currentAyah / ${ayahs.length}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary)),
                  Text(
                      s.reciterId == 'alafasy'
                          ? 'Alafasy'
                          : kRecitersInfo
                              .firstWhere((r) => r.id == s.reciterId,
                                  orElse: () => kRecitersInfo.first)
                              .nameFr,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ]),
          ),
          const SizedBox(height: 8),
          ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                  value: ayahs.isNotEmpty ? _currentAyah / ayahs.length : 0,
                  backgroundColor: Colors.grey.shade100,
                  color: AppTheme.primary,
                  minHeight: 4)),
          const SizedBox(height: 24),

          // Texte du verset actif
          if (ayah != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: AppTheme.primary.withValues(alpha: 0.15)),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 16,
                        color: Colors.black.withValues(alpha: 0.04))
                  ]),
              child: Column(children: [
                // Numéro
                Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                        color: AppTheme.primarySurface,
                        borderRadius: BorderRadius.circular(20)),
                    child: Text('${surah?.nameArabic ?? ''} — ﴿$_currentAyah﴾',
                        style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 16,
                            color: AppTheme.primary))),
                const SizedBox(height: 16),
                // Texte arabe avec animation
                Text(ayah.text,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: s.arabicFontSize,
                            color: AppTheme.textArabic,
                            height: 2.0))
                    .animate(key: ValueKey(_currentAyah))
                    .fadeIn(duration: 400.ms),

                if (s.showTranslation &&
                    ayah.translationFor(s.translationLang) != null) ...[
                  const Divider(height: 24),
                  Text(ayah.translationFor(s.translationLang)!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                          height: 1.6)),
                ],
              ]),
            ),
          ],

          const SizedBox(height: 20),

          // Navigation versets
          SizedBox(
            height: 50,
            child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: ayahs.length,
                itemBuilder: (_, i) {
                  final num = i + 1;
                  final isActive = num == _currentAyah;
                  return GestureDetector(
                    onTap: () async {
                      setState(() => _currentAyah = num);
                      if (_playerState == PlayerState.playing ||
                          _playerState == PlayerState.paused) {
                        await _audio.seekToAyah(i);
                      }
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primary
                              : AppTheme.primarySurface,
                          shape: BoxShape.circle),
                      child: Center(
                          child: Text('$num',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? Colors.white
                                      : AppTheme.primary))),
                    ),
                  );
                }),
          ),
        ]),
      )),

      // Contrôles
      _buildControls(isPlaying, isLoading, ayahs, s),
    ]));
  }

  Widget _buildAppBar(Surah? surah) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        child: Row(children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () {
                _audio.stop();
                Navigator.pop(context);
              }),
          Expanded(
              child: Column(children: [
            Text(surah?.nameArabic ?? '',
                style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 20,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.bold)),
            Text('${surah?.nameTranslit ?? ''} • Lecture continue',
                style: const TextStyle(
                    color: AppTheme.textSecondary, fontSize: 11)),
          ])),
          const Icon(Icons.queue_music_rounded, color: AppTheme.primary),
        ]),
      );

  Widget _buildControls(
      bool isPlaying, bool isLoading, List<Ayah> ayahs, RecitationSettings s) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
                blurRadius: 20, color: Colors.black.withValues(alpha: 0.07))
          ]),
      child: Column(children: [
        // Barre de temps
        Row(children: [
          const Text('بسم الله',
              style: TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 12,
                  color: AppTheme.textSecondary)),
          Expanded(
              child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                      thumbShape:
                          const RoundSliderThumbShape(enabledThumbRadius: 6),
                      trackHeight: 3,
                      overlayShape:
                          const RoundSliderOverlayShape(overlayRadius: 12)),
                  child: Slider(
                      value: (_currentAyah - 1)
                          .toDouble()
                          .clamp(0, (ayahs.length - 1).toDouble()),
                      min: 0,
                      max: (ayahs.length - 1).toDouble(),
                      activeColor: AppTheme.primary,
                      onChanged: (v) async {
                        final idx = v.round();
                        setState(() => _currentAyah = idx + 1);
                        if (isPlaying) {
                          await _audio.seekToAyah(idx);
                        }
                      }))),
          Text('${ayahs.length}',
              style:
                  const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        ]),
        const SizedBox(height: 8),

        // Boutons
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          // Précédent
          IconButton(
              icon: const Icon(Icons.skip_previous_rounded, size: 32),
              color: AppTheme.textSecondary,
              onPressed: () async {
                if (_currentAyah > 1) {
                  setState(() => _currentAyah--);
                  if (isPlaying) {
                    await _audio.seekToAyah(_currentAyah - 1);
                  }
                }
              }),

          // Rewind 5s
          IconButton(
              icon: const Icon(Icons.replay_5_rounded, size: 28),
              color: AppTheme.textSecondary,
              onPressed: () async {
                try {
                  await _audio.seekToAyah(_currentAyah - 1);
                } catch (_) {}
              }),

          // Play/Pause
          GestureDetector(
              onTap: () async {
                if (isPlaying) {
                  await _audio.pause();
                } else if (_playerState == PlayerState.paused) {
                  await _audio.resume();
                } else {
                  await _startContinuous();
                }
              },
              child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                      color: AppTheme.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: AppTheme.primary
                                .withValues(alpha: isPlaying ? 0.4 : 0.2),
                            blurRadius: isPlaying ? 24 : 10)
                      ]),
                  child: isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2.5))
                      : Icon(
                          isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 36))),

          // Forward
          IconButton(
              icon: const Icon(Icons.forward_5_rounded, size: 28),
              color: AppTheme.textSecondary,
              onPressed: () {}),

          // Suivant
          IconButton(
              icon: const Icon(Icons.skip_next_rounded, size: 32),
              color: AppTheme.textSecondary,
              onPressed: () async {
                if (_currentAyah < ayahs.length) {
                  setState(() => _currentAyah++);
                  if (isPlaying) {
                    await _audio.seekToAyah(_currentAyah - 1);
                  }
                }
              }),
        ]),
        const SizedBox(height: 4),

        // Info background audio
        const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.headphones_rounded,
              size: 14, color: AppTheme.textSecondary),
          SizedBox(width: 4),
          Text('Continue en arrière-plan',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ]),
      ]),
    );
  }
}
