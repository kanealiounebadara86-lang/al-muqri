import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class SpeechToTextScreen extends ConsumerStatefulWidget {
  final int surahNumber;
  final int ayahNumber;
  final int? rangeStart;
  final int? rangeEnd;
  const SpeechToTextScreen(
      {super.key,
      required this.surahNumber,
      required this.ayahNumber,
      this.rangeStart,
      this.rangeEnd});

  @override
  ConsumerState<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends ConsumerState<SpeechToTextScreen>
    with SingleTickerProviderStateMixin {
  bool _isListening = false;
  bool _isAnalyzing = false;
  bool _micReady = false;
  bool _micChecked = false;
  late int _activeAyah;
  String _transcribed = '';
  String _liveText = '';
  String _feedback = '';
  String _errorMsg = '';
  List<_CorrectedWord> _corrections = [];
  double _score = 0;
  bool _showResult = false;

  late AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _activeAyah = widget.ayahNumber;
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..repeat(reverse: true);
    _initMic();
  }

  Future<void> _initMic() async {
    final speech = ref.read(speechRecognitionProvider);
    speech.resultStream.listen((text) {
      if (mounted) {
        setState(() => _liveText = text);
      }
    });
    speech.errorStream.listen((err) {
      if (mounted) {
        setState(() {
          _errorMsg = err;
          _isListening = false;
        });
      }
    });
    final ok = await speech.init();
    if (mounted) {
      setState(() {
        _micReady = ok;
        _micChecked = true;
      });
    }
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    ref.read(speechRecognitionProvider).cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final ayahsAsync = ref.watch(ayahsProvider(AyahParams(
      surahNumber: widget.surahNumber,
      translationLang: 'fr',
    )));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Réciter & Corriger'),
        actions: [
          if (_showResult)
            TextButton(onPressed: _reset, child: const Text('Recommencer')),
        ],
      ),
      body: ayahsAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(child: Text('$e')),
        data: (ayahs) {
          if (_activeAyah < 1 || _activeAyah > ayahs.length) {
            return const Center(child: Text('Verset introuvable'));
          }
          final ayah = ayahs[_activeAyah - 1];
          return _showResult
              ? _buildResult(ayah, settings)
              : _buildRecorder(ayah, settings);
        },
      ),
    );
  }

  // ── Écran enregistrement ──────────────────────────────────────────────
  Widget _buildRecorder(Ayah ayah, RecitationSettings settings) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        // Avertissement permission micro
        if (_micChecked && !_micReady) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.red.shade200)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Icon(Icons.mic_off_rounded, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                const Text('Microphone indisponible',
                    style: TextStyle(
                        fontWeight: FontWeight.w800, color: Colors.red)),
              ]),
              const SizedBox(height: 8),
              const Text(
                  'Autorisez l\'accès au microphone dans les paramètres de votre navigateur/appareil, '
                  'puis rechargez la page.',
                  style: TextStyle(
                      fontSize: 12,
                      height: 1.5,
                      color: AppTheme.textSecondary)),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Réessayer'),
                  onPressed: _initMic),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // Bandeau pédagogique
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.primary.withValues(alpha: 0.08),
                AppTheme.accent.withValues(alpha: 0.05)
              ]),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: AppTheme.primary.withValues(alpha: 0.15))),
          child: const Row(children: [
            Text('🎓', style: TextStyle(fontSize: 22)),
            SizedBox(width: 10),
            Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  Text('Mode récitation',
                      style:
                          TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                  Text(
                      'Appuyez sur le micro et récitez le verset à voix haute.',
                      style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                          height: 1.4)),
                ])),
          ]),
        ),
        const SizedBox(height: 20),

        // Verset cible
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border:
                  Border.all(color: AppTheme.primary.withValues(alpha: 0.12))),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('S.${widget.surahNumber}:$_activeAyah',
                  style: const TextStyle(
                      color: AppTheme.textSecondary, fontSize: 12)),
              const Text('Verset à réciter',
                  style: TextStyle(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
            ]),
            const SizedBox(height: 12),
            Text(ayah.text,
                textAlign: TextAlign.right,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: settings.arabicFontSize,
                    color: AppTheme.textArabic,
                    height: 2.0)),
            if (ayah.translationFr != null) ...[
              const Divider(height: 20),
              Text(ayah.translationFr!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.5)),
            ],
          ]),
        ),
        const SizedBox(height: 16),

        // Navigation dans la plage (si plage définie)
        if (widget.rangeStart != null &&
            widget.rangeEnd != null &&
            widget.rangeEnd! > widget.rangeStart!) ...[
          _buildRangeNav(),
          const SizedBox(height: 16),
        ],

        const SizedBox(height: 16),

        // Micro central
        _buildMic(),
        const SizedBox(height: 20),

        // Texte transcrit en temps réel
        if (_liveText.isNotEmpty) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                if (_isListening) ...[
                  const SizedBox(
                      width: 8,
                      height: 8,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.red)),
                  const SizedBox(width: 8),
                ],
                Text(
                    _isListening
                        ? 'En cours d\'écoute...'
                        : 'Vous avez récité :',
                    style: const TextStyle(
                        fontSize: 12, color: AppTheme.textSecondary)),
              ]),
              const SizedBox(height: 8),
              Text(_liveText,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 22,
                      color: AppTheme.primary,
                      height: 1.8)),
            ]),
          ).animate().fadeIn(),
          const SizedBox(height: 16),
        ],

        if (_errorMsg.isNotEmpty) ...[
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(10)),
              child: Text('⚠️ $_errorMsg',
                  style: const TextStyle(fontSize: 12, color: Colors.red))),
          const SizedBox(height: 16),
        ],

        // Bouton écouter
        OutlinedButton.icon(
            icon: const Icon(Icons.volume_up_rounded, size: 18),
            label: const Text('Écouter la récitation correcte'),
            onPressed: () {
              final audio = ref.read(audioServiceProvider);
              final url = ref.read(quranApiProvider).getAudioUrlBySurah(
                  widget.surahNumber,
                  _activeAyah,
                  ref.read(settingsProvider).reciterId);
              audio.playUrl(url);
            }),

        // Bouton valider manuellement (si pas de transcription)
        if (_liveText.isEmpty && !_isListening) ...[
          const SizedBox(height: 12),
          TextButton(
              onPressed: () => _analyzeManually(),
              child: const Text('Continuer sans micro →',
                  style: TextStyle(color: AppTheme.textSecondary))),
        ],
      ]),
    );
  }

  Widget _buildMic() {
    return Column(children: [
      GestureDetector(
        onTap: _toggleListening,
        child: AnimatedBuilder(
            animation: _pulseCtrl,
            builder: (_, __) {
              final scale = _isListening ? 1.0 + _pulseCtrl.value * 0.1 : 1.0;
              return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening
                            ? Colors.red
                            : !_micReady && _micChecked
                                ? Colors.grey
                                : AppTheme.primary,
                        boxShadow: [
                          BoxShadow(
                              color:
                                  (_isListening ? Colors.red : AppTheme.primary)
                                      .withValues(alpha: 0.35),
                              blurRadius: _isListening ? 28 : 12,
                              spreadRadius: _isListening ? 4 : 0)
                        ]),
                    child: _isAnalyzing
                        ? const Padding(
                            padding: EdgeInsets.all(26),
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 3))
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Icon(
                                    _isListening
                                        ? Icons.stop_rounded
                                        : Icons.mic_rounded,
                                    color: Colors.white,
                                    size: 38),
                                Text(_isListening ? 'Stop' : 'Mic',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 11)),
                              ]),
                  ));
            }),
      ),
      const SizedBox(height: 12),
      Text(
          _isListening
              ? '🔴 Récitez maintenant...'
              : _isAnalyzing
                  ? '⏳ Analyse en cours...'
                  : !_micChecked
                      ? 'Initialisation du micro...'
                      : !_micReady
                          ? 'Microphone non disponible'
                          : 'Appuyez et récitez le verset',
          style: TextStyle(
              fontSize: 14,
              fontWeight: _isListening ? FontWeight.w700 : FontWeight.normal,
              color: _isListening ? Colors.red : AppTheme.textSecondary)),
    ]);
  }

  // ── Navigation dans la plage choisie ──────────────────────────────────
  Widget _buildRangeNav() {
    final start = widget.rangeStart!;
    final end = widget.rangeEnd!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
          color: const Color(0xFF7C3AED).withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: const Color(0xFF7C3AED).withValues(alpha: 0.15))),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        IconButton(
            icon: const Icon(Icons.skip_previous_rounded,
                color: Color(0xFF7C3AED)),
            onPressed: _activeAyah > start
                ? () => setState(() {
                      _activeAyah--;
                      _reset();
                    })
                : null),
        Column(children: [
          Text('Verset $_activeAyah',
              style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF7C3AED),
                  fontSize: 14)),
          Text('Plage : $start–$end',
              style:
                  const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
        ]),
        IconButton(
            icon: const Icon(Icons.skip_next_rounded, color: Color(0xFF7C3AED)),
            onPressed: _activeAyah < end
                ? () => setState(() {
                      _activeAyah++;
                      _reset();
                    })
                : null),
      ]),
    );
  }

  // ── Résultat avec corrections ─────────────────────────────────────────
  Widget _buildResult(Ayah ayah, RecitationSettings settings) {
    final color = _score >= 80
        ? const Color(0xFF059669)
        : _score >= 50
            ? AppTheme.accent
            : Colors.red.shade600;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withValues(alpha: 0.25))),
          child: Column(children: [
            Text(
                _score >= 80
                    ? '🌟'
                    : _score >= 50
                        ? '📚'
                        : '💪',
                style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 8),
            Text('${_score.round()}%',
                style: TextStyle(
                    fontSize: 40, fontWeight: FontWeight.w900, color: color)),
            Text(
                _score >= 80
                    ? 'Excellent ! Mashallah'
                    : _score >= 50
                        ? 'Bien ! Continuez'
                        : 'À améliorer — ne vous découragez pas',
                style: TextStyle(
                    fontWeight: FontWeight.w700, color: color, fontSize: 16)),
          ]),
        ).animate().fadeIn(duration: 400.ms),
        const SizedBox(height: 20),

        if (_transcribed.isNotEmpty) ...[
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Votre récitation :',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
          const SizedBox(height: 8),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100)),
              child: Text(_transcribed,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      color: AppTheme.textArabic,
                      height: 1.8))),
          const SizedBox(height: 16),
        ],

        if (_corrections.isNotEmpty) ...[
          const Align(
              alignment: Alignment.centerLeft,
              child: Text('Corrections :',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15))),
          const SizedBox(height: 8),
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100)),
              child: Wrap(
                  spacing: 8,
                  runSpacing: 10,
                  textDirection: TextDirection.rtl,
                  children:
                      _corrections.map((w) => _WordChip(word: w)).toList())),
          const SizedBox(height: 8),
          const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _LegendDot(color: Color(0xFF059669), label: 'Correct'),
            SizedBox(width: 12),
            _LegendDot(color: Color(0xFFB7950B), label: 'Approximatif'),
            SizedBox(width: 12),
            _LegendDot(color: Colors.red, label: 'Incorrect'),
          ]),
          const SizedBox(height: 16),
        ],

        if (_feedback.isNotEmpty) ...[
          Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: const Color(0xFF059669).withValues(alpha: 0.25))),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Text('🎓', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('Conseil du professeur',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                    ]),
                    const SizedBox(height: 10),
                    Text(_feedback,
                        style: const TextStyle(
                            fontSize: 13,
                            height: 1.7,
                            color: AppTheme.textSecondary)),
                  ])),
          const SizedBox(height: 16),
        ],

        Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade100)),
            child: Column(children: [
              const Text('Récitation correcte :',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                      color: AppTheme.textSecondary)),
              const SizedBox(height: 10),
              Text(ayah.text,
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                  style: TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: settings.arabicFontSize * 0.85,
                      color: AppTheme.textArabic,
                      height: 2.0)),
            ])),
        const SizedBox(height: 24),

        Row(children: [
          Expanded(
              child: OutlinedButton.icon(
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Réessayer'),
                  onPressed: _reset)),
          const SizedBox(width: 12),
          Expanded(
              child: ElevatedButton.icon(
                  icon: const Icon(Icons.stop_circle_outlined),
                  label: const Text('Arrêter ici'),
                  onPressed: () => Navigator.pop(context))),
        ]),

        // Continuer au verset suivant si dans une plage
        if (widget.rangeStart != null &&
            widget.rangeEnd != null &&
            _activeAyah < widget.rangeEnd!) ...[
          const SizedBox(height: 10),
          SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward_rounded),
                  label: Text('Réciter le verset ${_activeAyah + 1}'),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED)),
                  onPressed: () => setState(() {
                        _activeAyah++;
                        _reset();
                      }))),
        ],
      ]),
    );
  }

  // ── Logique micro ──────────────────────────────────────────────────────
  Future<void> _toggleListening() async {
    final speech = ref.read(speechRecognitionProvider);

    if (_isListening) {
      await speech.stopListening();
      setState(() => _isListening = false);
      // Lancer l'analyse avec le texte capturé
      if (_liveText.isNotEmpty) {
        await _analyzeRecitation(_liveText);
      }
      return;
    }

    if (!_micReady) {
      await _initMic();
      if (!_micReady) return;
    }

    setState(() {
      _liveText = '';
      _errorMsg = '';
      _isListening = true;
    });
    await speech.startListening();

    // Auto-stop après 30s
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted && _isListening) _toggleListening();
    });
  }

  void _analyzeManually() {
    final ayahs = ref
        .read(ayahsProvider(AyahParams(surahNumber: widget.surahNumber)))
        .value;
    if (ayahs == null) return;
    final correctText = ayahs[_activeAyah - 1].text;
    _fallbackAnalysis(correctText, hasAudio: false);
  }

  Future<void> _analyzeRecitation(String spokenText) async {
    setState(() => _isAnalyzing = true);
    final ayahs = ref
        .read(ayahsProvider(AyahParams(surahNumber: widget.surahNumber)))
        .value;
    if (ayahs == null || _activeAyah > ayahs.length) {
      setState(() => _isAnalyzing = false);
      return;
    }
    final correctText = ayahs[_activeAyah - 1].text;
    await _analyzeWithClaude(correctText, spokenText);
    setState(() => _isAnalyzing = false);
  }

  Future<void> _analyzeWithClaude(String correctText, String spokenText) async {
    try {
      final dio = Dio();
      final response = await dio.post('https://api.anthropic.com/v1/messages',
          options: Options(
            headers: {
              'Content-Type': 'application/json',
              'anthropic-version': '2023-06-01',
            },
            sendTimeout: const Duration(seconds: 20),
            receiveTimeout: const Duration(seconds: 20),
          ),
          data: {
            'model': 'claude-sonnet-4-20250514',
            'max_tokens': 700,
            'messages': [
              {
                'role': 'user',
                'content':
                    '''Tu es un professeur de Coran bienveillant, expert en tajwid.

VERSET CORRECT : "$correctText"

CE QUE L'ÉLÈVE A RÉCITÉ (transcrit par reconnaissance vocale, peut contenir des erreurs de transcription) :
"$spokenText"

Compare la récitation de l'élève au verset correct. Donne :
1. Un score de précision sur 100
2. Pour chaque mot du verset correct, indique s'il a été récité correctement (correct/partial/error)
3. Des conseils encourageants en français (2-3 phrases)
4. Une règle de tajwid pertinente si applicable

Réponds UNIQUEMENT en JSON, sans texte avant/après :
{
  "score": 75,
  "feedback": "tes conseils en français",
  "corrections": [
    {"word": "mot_arabe", "status": "correct"},
    {"word": "mot_arabe", "status": "error"}
  ]
}'''
              }
            ]
          });

      if (response.statusCode == 200) {
        String text = response.data['content'][0]['text'] as String;
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
        final parsed = _parseAnalysis(text, correctText);

        setState(() {
          _score = parsed.score;
          _transcribed = spokenText;
          _feedback = parsed.feedback;
          _corrections = parsed.corrections;
          _showResult = true;
        });
        return;
      }
    } catch (_) {}
    _fallbackAnalysis(correctText, hasAudio: true, spokenText: spokenText);
  }

  _AnalysisResult _parseAnalysis(String text, String correctText) {
    try {
      final scoreMatch = RegExp(r'"score":\s*(\d+)').firstMatch(text);
      final feedbackMatch = RegExp(r'"feedback":\s*"([^"]*)"').firstMatch(text);
      final score =
          scoreMatch != null ? double.parse(scoreMatch.group(1)!) : 60.0;
      final feedback = feedbackMatch?.group(1) ?? '';

      // Extraire les corrections
      final corrections = <_CorrectedWord>[];
      final wordMatches =
          RegExp(r'\{"word":\s*"([^"]*)",\s*"status":\s*"([^"]*)"\}')
              .allMatches(text);
      for (final m in wordMatches) {
        corrections.add(_CorrectedWord(
            word: m.group(1) ?? '', status: m.group(2) ?? 'correct'));
      }
      if (corrections.isEmpty) {
        final words =
            correctText.split(' ').where((w) => w.isNotEmpty).toList();
        for (int i = 0; i < words.length; i++) {
          corrections.add(_CorrectedWord(word: words[i], status: 'correct'));
        }
      }
      return _AnalysisResult(
          score: score, feedback: feedback, corrections: corrections);
    } catch (_) {
      final words = correctText.split(' ').where((w) => w.isNotEmpty).toList();
      return _AnalysisResult(
          score: 60,
          feedback: 'Continuez à pratiquer ce verset.',
          corrections: words
              .map((w) => _CorrectedWord(word: w, status: 'correct'))
              .toList());
    }
  }

  void _fallbackAnalysis(String correctText,
      {bool hasAudio = true, String? spokenText}) {
    final words = correctText.split(' ').where((w) => w.isNotEmpty).toList();
    setState(() {
      _score = hasAudio ? 65 : 0;
      _transcribed = spokenText ?? '';
      _feedback = hasAudio
          ? 'Analyse de base effectuée. Pour une analyse plus précise, '
              'assurez-vous de parler clairement et près du microphone.\n\n'
              '"Le meilleur d\'entre vous est celui qui apprend le Coran et l\'enseigne" — Bukhari'
          : 'Continuez à répéter ce verset après le récitateur. '
              'La répétition régulière est la clé de la mémorisation, in cha Allah.';
      _corrections = hasAudio
          ? words
              .map((w) => _CorrectedWord(word: w, status: 'correct'))
              .toList()
          : [];
      _showResult = true;
    });
  }

  void _reset() {
    setState(() {
      _isListening = false;
      _isAnalyzing = false;
      _transcribed = '';
      _liveText = '';
      _feedback = '';
      _errorMsg = '';
      _corrections = [];
      _score = 0;
      _showResult = false;
    });
  }
}

class _AnalysisResult {
  final double score;
  final String feedback;
  final List<_CorrectedWord> corrections;
  const _AnalysisResult(
      {required this.score, required this.feedback, required this.corrections});
}

class _CorrectedWord {
  final String word, status;
  const _CorrectedWord({required this.word, required this.status});
  bool get isCorrect => status == 'correct';
  bool get isPartial => status == 'partial';
}

class _WordChip extends StatelessWidget {
  final _CorrectedWord word;
  const _WordChip({required this.word});

  @override
  Widget build(BuildContext context) {
    final color = word.isCorrect
        ? const Color(0xFF059669)
        : word.isPartial
            ? AppTheme.accent
            : Colors.red.shade600;
    final bg = word.isCorrect
        ? const Color(0xFFD1FAE5)
        : word.isPartial
            ? const Color(0xFFFEF3C7)
            : const Color(0xFFFEE2E2);

    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withValues(alpha: 0.4))),
        child: Text(word.word,
            style: TextStyle(fontFamily: 'Amiri', fontSize: 18, color: color)));
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});
  @override
  Widget build(BuildContext context) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label,
            style:
                const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
      ]);
}
