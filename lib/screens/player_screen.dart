import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../models/hive_models.dart';
import '../services/audio_service.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../data/surahs_data.dart';
import '../widgets/tajwid_text.dart';
import 'speech_to_text_screen.dart';

/// Lecteur principal — fidèle à Al-Muqri :
/// gros bouton play rond, infos "Ayas : X à Y", sélecteurs de plage,
/// et UN SEUL VERSET affiché à la fois avec sa traduction en dessous.
/// Navigation verset par verset (◀ ▶) + micro de récitation (valeur ajoutée).
class PlayerScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int? initialStart;
  final int? initialEnd;
  const PlayerScreen(
      {super.key,
      required this.surahNumber,
      this.initialStart,
      this.initialEnd});
  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen> {
  int _currentIdx = 0;
  TakrarProgress? _progress;
  PlayerState _playerState = PlayerState.idle;
  int _startAyah = 0;
  int _endAyah = 0;
  bool _initialized = false;
  bool _showOptions = false;
  late AudioService _audio;
  DateTime? _sessionStart;
  String? _lastReciterId;
  // Cache local des favoris pour mise à jour immédiate de l'icône
  final Map<int, bool> _favCache = {};

  @override
  void initState() {
    super.initState();
    _audio = ref.read(audioServiceProvider);
    _audio.stateStream.listen((s) {
      if (mounted) setState(() => _playerState = s);
    });
    _audio.currentAyahStream.listen((i) {
      if (mounted) setState(() => _currentIdx = i - 1);
    });
    _audio.progressStream.listen((p) {
      if (mounted) setState(() => _progress = p);
    });
    _sessionStart = DateTime.now();
  }

  @override
  void dispose() {
    _saveSession();
    _audio.stop();
    super.dispose();
  }

  void _saveSession() {
    if (_sessionStart == null) return;
    final duration = DateTime.now().difference(_sessionStart!).inMinutes;
    if (duration < 1) return;
    final surah = ref.read(selectedSurahProvider);
    if (surah == null) return;
    final settings = ref.read(settingsProvider);
    ref.read(localStorageProvider).saveSession(StudySession(
          surahNumber: surah.number,
          surahName: surah.nameTranslit,
          startAyah: _startAyah + 1,
          endAyah: _endAyah + 1,
          repetitionsUsed: settings.repetitionsPerAyah,
          date: DateTime.now(),
          durationMinutes: duration,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final surah = ref.watch(selectedSurahProvider);

    if (_lastReciterId != null && _lastReciterId != settings.reciterId) {
      _audio.stop();
    }
    _lastReciterId = settings.reciterId;

    final ayahsAsync = ref.watch(ayahsProvider(AyahParams(
      surahNumber: widget.surahNumber,
      reciterId: settings.reciterId,
      translationLang:
          settings.showTranslation ? settings.translationLang : 'none',
    )));

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: ayahsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => _buildError(),
        data: (ayahs) {
          if (!_initialized) {
            _startAyah = (widget.initialStart != null)
                ? (widget.initialStart! - 1).clamp(0, ayahs.length - 1)
                : 0;
            _endAyah = (widget.initialEnd != null)
                ? (widget.initialEnd! - 1).clamp(_startAyah, ayahs.length - 1)
                : ayahs.length - 1;
            _currentIdx = _startAyah;
            _initialized = true;
          }
          return SafeArea(
              child: Column(children: [
            _topBar(surah),
            _playButton(ayahs, settings),
            _infoBar(ayahs, settings),
            Expanded(
                child: settings.pageMode
                    ? _pageView(ayahs, surah, settings)
                    : _singleAyahView(ayahs, surah, settings)),
            _voiceButton(ayahs),
          ]));
        },
      ),
    );
  }

  // ── Barre du haut ─────────────────────────────────────────────────────
  Widget _topBar(Surah? surah) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
        child: Row(children: [
          IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded,
                  size: 18, color: AppTheme.textSecondary),
              onPressed: () {
                _audio.stop();
                Navigator.pop(context);
              }),
          Expanded(
              child: Center(
                  child: Text(surah?.nameTranslit ?? '',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppTheme.textPrimary)))),
          IconButton(
              icon: const Icon(Icons.settings_outlined,
                  size: 20, color: AppTheme.textSecondary),
              onPressed: () => setState(() => _showOptions = !_showOptions)),
          IconButton(
              icon: const Icon(Icons.close_rounded,
                  size: 20, color: AppTheme.textSecondary),
              onPressed: () {
                _audio.stop();
                Navigator.pop(context);
              }),
        ]),
      );

  // ── Gros bouton play rond, centré ────────────────────────────────────
  Widget _playButton(List<Ayah> ayahs, RecitationSettings settings) {
    final isPlaying = _playerState == PlayerState.playing;
    final isLoading = _playerState == PlayerState.loading;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(children: [
        GestureDetector(
          onTap: () => _togglePlay(ayahs, settings),
          child: Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primary, width: 2)),
              child: isLoading
                  ? const Padding(
                      padding: EdgeInsets.all(22),
                      child: CircularProgressIndicator(
                          color: AppTheme.primary, strokeWidth: 2.5))
                  : Icon(
                      isPlaying
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      size: 40,
                      color: AppTheme.primary)),
        ),
        if (_showOptions) ...[
          const SizedBox(height: 14),
          _optionsPanel(ayahs, settings),
        ],
      ]),
    );
  }

  // ── Panneau options : vitesse, traduction, Tajwid ────────────────────
  Widget _optionsPanel(List<Ayah> ayahs, RecitationSettings settings) {
    final notifier = ref.read(settingsProvider.notifier);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.border)),
      child: Column(children: [
        // Vitesse ◀◀ x.xx ▶▶
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          IconButton(
              icon: const Icon(Icons.fast_rewind_rounded,
                  size: 20, color: AppTheme.textSecondary),
              onPressed: () => notifier
                  .setSpeed((settings.playbackSpeed - 0.1).clamp(0.5, 2.0))),
          SizedBox(
              width: 56,
              child: Center(
                  child: Text('${settings.playbackSpeed.toStringAsFixed(2)}x',
                      style: const TextStyle(fontWeight: FontWeight.w700)))),
          IconButton(
              icon: const Icon(Icons.fast_forward_rounded,
                  size: 20, color: AppTheme.textSecondary),
              onPressed: () => notifier
                  .setSpeed((settings.playbackSpeed + 0.1).clamp(0.5, 2.0))),
        ]),
        const Divider(height: 1),
        // Toggle Page — comme Al-Muqri
        SwitchListTile(
          dense: true,
          title: const Text('Page',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          secondary: const Icon(Icons.menu_book_outlined,
              size: 20, color: AppTheme.textSecondary),
          value: settings.pageMode,
          onChanged: (v) => notifier.togglePageMode(),
        ),
        const Divider(height: 1),
        // Toggle Tajwid — comme Al-Muqri
        SwitchListTile(
          dense: true,
          title: const Text('Tajwid',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          secondary: const Icon(Icons.format_color_text_rounded,
              size: 20, color: AppTheme.textSecondary),
          value: settings.tajwidEnabled,
          onChanged: (v) =>
              notifier.update(settings.copyWith(tajwidEnabled: v)),
        ),
        const Divider(height: 1),
        // Lien vers paramètres complets
        ListTile(
          dense: true,
          leading: const Icon(Icons.settings_outlined,
              size: 20, color: AppTheme.textSecondary),
          title: const Text('Paramètres',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          trailing: const Icon(Icons.chevron_right_rounded,
              size: 18, color: AppTheme.textSecondary),
          onTap: () {
            setState(() => _showOptions = false);
            context.push('/settings');
          },
        ),
      ]),
    );
  }

  // ── Barre info : "Ayas : X à Y" + plage + répétitions ────────────────
  Widget _infoBar(List<Ayah> ayahs, RecitationSettings settings) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text('Ayas : ${_startAyah + 1} à ${_endAyah + 1}',
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary)),
          const SizedBox(width: 12),
          Icon(Icons.repeat_rounded, size: 14, color: AppTheme.textSecondary),
          const SizedBox(width: 2),
          Text('${settings.repetitionsPerAyah}/${settings.repetitionsTotal}',
              style:
                  const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
          if (_progress != null) ...[
            const SizedBox(width: 12),
            Text(
                'Rép. ${_progress!.currentRepetition}/${_progress!.totalRepetitions}',
                style: const TextStyle(
                    fontSize: 12, color: AppTheme.textSecondary)),
          ],
        ]),
        const SizedBox(height: 8),
        Row(children: [
          const Text('De ',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Expanded(
              child: _Stepper(
                  value: _startAyah + 1,
                  min: 1,
                  max: _endAyah + 1,
                  onChanged: (v) => setState(() {
                        _startAyah = v - 1;
                        if (_currentIdx < _startAyah) _currentIdx = _startAyah;
                      }))),
          const Text(' à ',
              style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
          Expanded(
              child: _Stepper(
                  value: _endAyah + 1,
                  min: _startAyah + 1,
                  max: ayahs.length,
                  onChanged: (v) => setState(() {
                        _endAyah = v - 1;
                        if (_currentIdx > _endAyah) _currentIdx = _endAyah;
                      }))),
        ]),
      ]),
    );
  }

  // ── Mode page : tous les versets en continu ─────────────────────────
  Widget _pageView(
      List<Ayah> ayahs, Surah? surah, RecitationSettings settings) {
    final activeAyah = ayahs[_currentIdx.clamp(_startAyah, _endAyah)];
    final translation = activeAyah.translationFor(settings.translationLang);
    final rangeAyahs = ayahs.sublist(_startAyah, _endAyah + 1);

    return Column(children: [
      // ── Zone de texte scrollable ─────────────────────────────────────
      Expanded(
          child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border)),
          child: Column(children: [
            if (surah?.number != 9 && surah?.number != 1) ...[
              const Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      color: AppTheme.primary,
                      height: 2)),
              const Divider(),
            ],
            // Texte Coran : chaque verset est un span, actif en rouge
            RichText(
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: settings.arabicFontSize,
                    color: AppTheme.textArabic,
                    height: 2.2),
                children: rangeAyahs.map((a) {
                  final isActive = a.numberInSurah == activeAyah.numberInSurah;
                  return TextSpan(
                      text: '${a.text} ﴿${a.numberInSurah}﴾  ',
                      style: TextStyle(
                        color: isActive
                            ? const Color(0xFFCC0000)
                            : AppTheme.textArabic,
                        fontWeight:
                            isActive ? FontWeight.bold : FontWeight.normal,
                        background: isActive
                            ? (Paint()..color = const Color(0xFFFFEEEE))
                            : null,
                      ));
                }).toList(),
              ),
            ),
          ]),
        ),
      )),

      // ── Traduction du verset actif, fixée en bas ─────────────────────
      if (settings.showTranslation && translation != null)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          decoration: const BoxDecoration(
              color: AppTheme.surface,
              border: Border(top: BorderSide(color: AppTheme.border))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
                width: 24,
                height: 24,
                margin: const EdgeInsets.only(right: 8, top: 2),
                decoration: const BoxDecoration(
                    color: Color(0xFFCC0000), shape: BoxShape.circle),
                child: Center(
                    child: Text('${activeAyah.numberInSurah}',
                        style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.bold)))),
            Expanded(
                child: Text(translation,
                    style: const TextStyle(
                        fontSize: 13,
                        height: 1.6,
                        color: AppTheme.textSecondary))),
          ]),
        ),
    ]);
  }

  // ── UN SEUL VERSET affiché, avec sa traduction ───────────────────────
  Widget _singleAyahView(
      List<Ayah> ayahs, Surah? surah, RecitationSettings settings) {
    final idx = _currentIdx.clamp(_startAyah, _endAyah);
    final ayah = ayahs[idx];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border)),
          child: Column(children: [
            // Bismillah si premier verset de la sourate (sauf At-Tawba)
            if (ayah.numberInSurah == 1 &&
                surah?.number != 9 &&
                surah?.number != 1) ...[
              const Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      color: AppTheme.primary,
                      height: 2)),
              const Divider(),
            ],
            // Numéro du verset
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              // Favori + numéro
              GestureDetector(
                  onTap: () => _toggleFav(ayah, surah),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Builder(builder: (context) {
                      final storage = ref.read(localStorageProvider);
                      final isFav = _favCache.containsKey(ayah.numberInSurah)
                          ? _favCache[ayah.numberInSurah]!
                          : storage.isFavorite(
                              widget.surahNumber, ayah.numberInSurah);
                      return Icon(
                          isFav
                              ? Icons.bookmark_rounded
                              : Icons.bookmark_outline_rounded,
                          color:
                              isFav ? AppTheme.primary : AppTheme.textSecondary,
                          size: 20);
                    }),
                    const SizedBox(width: 8),
                    _AyahNum(ayah.numberInSurah),
                  ])),
              // Bouton copier verset + traduction
              GestureDetector(
                  onTap: () => _copyAyah(ayah, settings),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(8)),
                      child:
                          const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.copy_rounded,
                            size: 14, color: AppTheme.textSecondary),
                        SizedBox(width: 4),
                        Text('Copier',
                            style: TextStyle(
                                fontSize: 12, color: AppTheme.textSecondary)),
                      ]))),
            ]),
            const SizedBox(height: 12),
            // Texte arabe (un seul verset)
            TajwidText(
              text: ayah.text,
              fontSize: settings.arabicFontSize,
              enabled: settings.tajwidEnabled,
            ),
            // Traduction
            if (settings.showTranslation &&
                ayah.translationFor(settings.translationLang) != null) ...[
              const Divider(height: 28),
              Text(ayah.translationFor(settings.translationLang)!,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                      fontSize: 14,
                      color: AppTheme.textSecondary,
                      height: 1.7)),
            ],
          ]),
        ),
        const SizedBox(height: 16),
        // Navigation verset précédent / suivant
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          _NavBtn(
              icon: Icons.chevron_left_rounded,
              label: 'Précédent',
              onTap: idx > _startAyah
                  ? () => setState(() => _currentIdx--)
                  : null),
          Text('${idx + 1} / ${_endAyah + 1}',
              style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600)),
          _NavBtn(
              icon: Icons.chevron_right_rounded,
              label: 'Suivant',
              reversed: true,
              onTap:
                  idx < _endAyah ? () => setState(() => _currentIdx++) : null),
        ]),
      ]),
    );
  }

  // ── Bouton récitation — valeur ajoutée, fixé en bas ──────────────────
  Widget _voiceButton(List<Ayah> ayahs) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 14),
      decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border))),
      child: SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
              icon: const Icon(Icons.mic_rounded, size: 18),
              label: const Text('Réciter ce verset à voix haute'),
              style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(color: AppTheme.primary)),
              onPressed: () => _openVoiceTest(
                  ayahs[_currentIdx.clamp(_startAyah, _endAyah)]
                      .numberInSurah))),
    );
  }

  void _togglePlay(List<Ayah> ayahs, RecitationSettings settings) {
    if (_playerState == PlayerState.playing) {
      _audio.pause();
      return;
    }
    if (_playerState == PlayerState.paused) {
      _audio.resume();
      return;
    }
    final currentSettings = ref.read(settingsProvider);
    final surahNum = widget.surahNumber;
    final selected = ayahs.sublist(_startAyah, _endAyah + 1);
    _audio.startTakrar(
      ayahs: selected,
      settings: currentSettings,
      getAudioUrl: (ayahInSurah, reciterId) => ref
          .read(quranApiProvider)
          .getAudioUrlBySurah(surahNum, ayahInSurah, reciterId),
      getFallbackUrl: (ayahInSurah, reciterId) => ref
          .read(quranApiProvider)
          .getEveryayahUrl(surahNum, ayahInSurah, reciterId),
      startIndex: _currentIdx > _startAyah ? _currentIdx - _startAyah : 0,
    );
    final surah =
        ref.read(selectedSurahProvider) ?? _surahFromNumber(widget.surahNumber);
    for (int i = _startAyah; i <= _endAyah; i++) {
      ref.read(localStorageProvider).markAyahMemorized(
          surah.number, surah.nameTranslit, i, surah.totalAyahs);
    }
  }

  void _openVoiceTest(int ayahNumber) {
    _audio.stop();
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SpeechToTextScreen(
                  surahNumber: widget.surahNumber,
                  ayahNumber: ayahNumber,
                  rangeStart: _startAyah + 1,
                  rangeEnd: _endAyah + 1,
                )));
  }

  void _copyAyah(Ayah ayah, RecitationSettings settings) async {
    final surah =
        ref.read(selectedSurahProvider) ?? _surahFromNumber(widget.surahNumber);
    final parts = <String>[];
    parts.add(ayah.text);
    final translation = ayah.translationFor(settings.translationLang);
    if (translation != null && translation.isNotEmpty) {
      parts.add('');
      parts.add('${ayah.numberInSurah}. $translation');
    }
    if (surah != null) {
      parts.add('');
      parts.add(
          '[${surah.nameTranslit} - ${surah.nameArabic}, verset ${ayah.numberInSurah}]');
    }
    await Clipboard.setData(ClipboardData(text: parts.join('\n')));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Verset copié dans le presse-papiers'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  void _toggleFav(Ayah ayah, Surah? surah) async {
    final effectiveSurah = surah ?? _surahFromNumber(widget.surahNumber);
    final storage = ref.read(localStorageProvider);
    final wasAlreadyFav = _favCache.containsKey(ayah.numberInSurah)
        ? _favCache[ayah.numberInSurah]!
        : storage.isFavorite(widget.surahNumber, ayah.numberInSurah);

    await storage.toggleFavorite(
        surahNumber: effectiveSurah.number,
        surahName: effectiveSurah.nameTranslit,
        ayahNumber: ayah.numberInSurah,
        ayahText: ayah.text);

    // Mise à jour immédiate du cache local
    final isNowFav = !wasAlreadyFav;
    if (mounted) {
      setState(() => _favCache[ayah.numberInSurah] = isNowFav);
      ref.read(favoritesRefreshProvider.notifier).state++;

      // SnackBar avec possibilité d'annuler
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isNowFav ? '✦ Ajouté aux favoris' : 'Retiré des favoris'),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
            label: 'Annuler',
            onPressed: () async {
              // Ré-toggle pour annuler
              await storage.toggleFavorite(
                  surahNumber: effectiveSurah.number,
                  surahName: effectiveSurah.nameTranslit,
                  ayahNumber: ayah.numberInSurah,
                  ayahText: ayah.text);
              if (mounted) {
                setState(() => _favCache[ayah.numberInSurah] = wasAlreadyFav);
                ref.read(favoritesRefreshProvider.notifier).state++;
              }
            }),
      ));
    }
  }

  Surah _surahFromNumber(int number) {
    final data = kSurahsData.firstWhere((s) => s['number'] == number,
        orElse: () => kSurahsData.first);
    return Surah(
        number: data['number'],
        nameArabic: data['name'],
        nameTranslit: data['translit'],
        nameFr: data['fr'],
        totalAyahs: data['ayahs'],
        revelationType: data['type']);
  }

  Widget _buildError() => Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.wifi_off_rounded,
            size: 56, color: AppTheme.textSecondary),
        const SizedBox(height: 16),
        const Text('Connexion requise',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ElevatedButton.icon(
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Réessayer'),
            onPressed: () {
              setState(() {
                _initialized = false;
              });
              ref.invalidate(ayahsProvider);
            }),
      ]));
}

// ── Widgets ───────────────────────────────────────────────────────────────
class _AyahNum extends StatelessWidget {
  final int n;
  const _AyahNum(this.n);
  @override
  Widget build(BuildContext context) => Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
          border: Border.all(color: AppTheme.border), shape: BoxShape.circle),
      child: Center(
          child: Text('$n',
              style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.bold))));
}

class _Stepper extends StatelessWidget {
  final int value, min, max;
  final ValueChanged<int> onChanged;
  const _Stepper(
      {required this.value,
      required this.min,
      required this.max,
      required this.onChanged});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(8)),
        child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.remove_rounded, size: 16),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: AppTheme.textSecondary,
                  onPressed: value > min ? () => onChanged(value - 1) : null),
              Text('$value',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14)),
              IconButton(
                  icon: const Icon(Icons.add_rounded, size: 16),
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 28, minHeight: 28),
                  color: AppTheme.textSecondary,
                  onPressed: value < max ? () => onChanged(value + 1) : null),
            ]),
      );
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool reversed;
  final VoidCallback? onTap;
  const _NavBtn(
      {required this.icon,
      required this.label,
      required this.onTap,
      this.reversed = false});
  @override
  Widget build(BuildContext context) {
    final color = onTap == null ? AppTheme.border : AppTheme.textPrimary;
    final children = [
      Icon(icon, size: 18, color: color),
      const SizedBox(width: 4),
      Text(label,
          style: TextStyle(
              fontSize: 13, color: color, fontWeight: FontWeight.w600)),
    ];
    return TextButton(
      onPressed: onTap,
      child: Row(children: reversed ? children.reversed.toList() : children),
    );
  }
}
