import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import '../data/adhan_data.dart';
import '../services/audio_cache_service.dart';
import '../theme/app_theme.dart';

class AdhanScreen extends StatefulWidget {
  const AdhanScreen({super.key});
  @override
  State<AdhanScreen> createState() => _AdhanScreenState();
}

class _AdhanScreenState extends State<AdhanScreen> {
  AudioPlayer? _player;
  String? _playingId;
  bool _isPlaying = false;
  bool _isLoading = false;
  bool _showAdhan = true;

  @override
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  Future<void> _play(AdhanInfo item) async {
    // Pause/reprise si c'est déjà le même audio en cours
    if (_playingId == item.id && _player != null) {
      if (_isPlaying) {
        await _player!.pause();
        if (mounted) setState(() => _isPlaying = false);
      } else {
        await _player!.play();
        if (mounted) setState(() => _isPlaying = true);
      }
      return;
    }

    // Nouvel audio : détruire l'ancien player et en créer un neuf
    // (évite l'erreur "Platform player already exists" sur Web)
    try {
      await _player?.stop();
    } catch (_) {}
    try {
      await _player?.dispose();
    } catch (_) {}
    _player = AudioPlayer();

    if (mounted)
      setState(() {
        _playingId = item.id;
        _isPlaying = false;
        _isLoading = true;
      });

    bool loaded = false;
    String? lastError;

    // 1. Essayer l'asset local en premier (fonctionne hors ligne une fois
    // les fichiers MP3 placés dans assets/audio/)
    try {
      await _player!.setAsset(item.assetPath);
      loaded = true;
    } catch (e) {
      lastError = 'asset: $e';
    }

    // 2. Sinon, essayer chaque URL de la liste, avec cache automatique
    if (!loaded) {
      for (final url in item.urls) {
        try {
          final cachedPath = await AudioCacheService.getCachedOrDownload(url);
          if (cachedPath != url && !cachedPath.startsWith('http')) {
            await _player!.setFilePath(cachedPath);
          } else {
            await _player!.setUrl(url).timeout(const Duration(seconds: 10));
          }
          loaded = true;
          break;
        } catch (e) {
          lastError = 'url $url: $e';
          continue;
        }
      }
    }

    if (!loaded) {
      debugPrint('AdhanScreen: échec chargement audio — $lastError');
      if (mounted) {
        setState(() {
          _isPlaying = false;
          _isLoading = false;
          _playingId = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Audio indisponible. Vérifiez votre connexion internet.'),
            duration: Duration(seconds: 3)));
      }
      return;
    }

    if (mounted)
      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });
    try {
      await _player!.play();
    } catch (_) {
      if (mounted)
        setState(() {
          _isPlaying = false;
        });
      return;
    }
    _player!.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted)
          setState(() {
            _isPlaying = false;
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final list = _showAdhan ? kAdhans : kIqamahs;
    return Scaffold(
      appBar: AppBar(title: const Text('Adhan & Iqama')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
                color: AppTheme.primarySurface,
                borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Expanded(
                  child: _TabBtn(
                      label: 'Adhan',
                      selected: _showAdhan,
                      onTap: () => setState(() => _showAdhan = true))),
              Expanded(
                  child: _TabBtn(
                      label: 'Iqama',
                      selected: !_showAdhan,
                      onTap: () => setState(() => _showAdhan = false))),
            ]),
          ),
          const SizedBox(height: 20),
          ...list.map((item) {
            final isThis = _playingId == item.id;
            final loading = isThis && _isLoading;
            final playing = isThis && _isPlaying;
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: isThis
                      ? AppTheme.primary.withValues(alpha: 0.06)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: isThis ? AppTheme.primary : AppTheme.border)),
              child: Row(children: [
                GestureDetector(
                  onTap: () => _play(item),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                          color: isThis
                              ? AppTheme.primary
                              : AppTheme.primarySurface,
                          shape: BoxShape.circle),
                      child: loading
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                          : Icon(
                              playing
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: isThis ? Colors.white : AppTheme.primary,
                              size: 30)),
                ),
                const SizedBox(width: 14),
                Expanded(
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                      Text(item.nameAr,
                          style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 18,
                              color: AppTheme.primary)),
                      Text(item.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14)),
                    ])),
                if (playing)
                  const Icon(Icons.volume_up_rounded,
                      color: AppTheme.primary, size: 20),
              ]),
            );
          }),
          const SizedBox(height: 24),
          Text(_showAdhan ? "Texte de l'Adhan" : "Texte de l'Iqamah",
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.border)),
            child: Column(children: [
              Text(_showAdhan ? kAdhanTextAr : kIqamahTextAr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 20,
                      color: AppTheme.textArabic,
                      height: 2.2)),
              const Divider(height: 32),
              Text(_showAdhan ? kAdhanTextFr : kIqamahTextFr,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      height: 1.8)),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _TabBtn(
      {required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: selected ? AppTheme.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(10)),
          child: Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : AppTheme.primary))));
}
