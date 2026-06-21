import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../data/reciters_data.dart';
import '../data/surahs_data.dart';
import 'package:go_router/go_router.dart';

/// Écran de configuration — reproduit la mise en page Al-Muqri :
/// récitateur, sourate + plage de versets, et compteurs
/// "tout" / "aya" / "pause" (répétitions globales / par verset / délai).
/// Palette grise minimaliste au lieu du beige original.
class RecitationSetupScreen extends ConsumerStatefulWidget {
  const RecitationSetupScreen({super.key});
  @override
  ConsumerState<RecitationSetupScreen> createState() =>
      _RecitationSetupScreenState();
}

class _RecitationSetupScreenState extends ConsumerState<RecitationSetupScreen> {
  int _startAyah = 1;
  int _endAyah = 1;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);
    final surah = ref.watch(selectedSurahProvider) ??
        Surah(
            number: 1,
            nameArabic: kSurahsData[0]['name'],
            nameTranslit: kSurahsData[0]['translit'],
            nameFr: kSurahsData[0]['fr'],
            totalAyahs: kSurahsData[0]['ayahs'],
            revelationType: kSurahsData[0]['type']);

    if (_endAyah == 1 && surah.totalAyahs > 1) {
      _endAyah = surah.totalAyahs;
    }
    if (_endAyah > surah.totalAyahs) _endAyah = surah.totalAyahs;
    if (_startAyah > _endAyah) _startAyah = _endAyah;

    final reciter = kRecitersInfo.firstWhere((r) => r.id == settings.reciterId,
        orElse: () => kRecitersInfo.first);

    return Scaffold(
      appBar: AppBar(title: const Text('Lecture')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          // ── Bouton play central ──────────────────────────────────────
          GestureDetector(
            onTap: () => _startReading(context, surah),
            child: Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.primary, width: 2)),
                child: const Icon(Icons.play_arrow_rounded,
                    size: 48, color: AppTheme.primary)),
          ),
          const SizedBox(height: 28),

          // ── Récitateur ───────────────────────────────────────────────
          _DropdownField<String>(
            value: reciter.id,
            items: kRecitersInfo
                .map(
                    (r) => DropdownMenuItem(value: r.id, child: Text(r.nameFr)))
                .toList(),
            onChanged: (v) {
              if (v != null) notifier.setReciter(v);
            },
          ),
          const SizedBox(height: 24),

          const Align(
              alignment: Alignment.centerLeft,
              child: Text('sourate et verset',
                  style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600))),
          const SizedBox(height: 8),

          // ── Sourate ──────────────────────────────────────────────────
          _DropdownField<int>(
            value: surah.number,
            items: kSurahsData
                .map((s) => DropdownMenuItem(
                    value: s['number'] as int,
                    child: Text('${s['number']}- ${s['translit']}')))
                .toList(),
            onChanged: (v) {
              if (v == null) return;
              final data = kSurahsData.firstWhere((s) => s['number'] == v);
              final newSurah = Surah(
                  number: data['number'],
                  nameArabic: data['name'],
                  nameTranslit: data['translit'],
                  nameFr: data['fr'],
                  totalAyahs: data['ayahs'],
                  revelationType: data['type']);
              ref.read(selectedSurahProvider.notifier).state = newSurah;
              setState(() {
                _startAyah = 1;
                _endAyah = newSurah.totalAyahs;
              });
            },
          ),
          const SizedBox(height: 14),

          // ── Plage de versets : du / au ──────────────────────────────
          Row(children: [
            Expanded(
                child: _Counter(
                    label: 'verset début',
                    value: _startAyah,
                    min: 1,
                    max: _endAyah,
                    onChanged: (v) => setState(() => _startAyah = v))),
            const SizedBox(width: 16),
            Expanded(
                child: _Counter(
                    label: 'verset fin',
                    value: _endAyah,
                    min: _startAyah,
                    max: surah.totalAyahs,
                    onChanged: (v) => setState(() => _endAyah = v))),
          ]),
          const SizedBox(height: 28),

          // ── tout / aya / pause ───────────────────────────────────────
          Row(children: [
            Expanded(
                child: _Counter(
                    label: 'tout',
                    value: settings.repetitionsTotal,
                    min: 1,
                    max: 50,
                    onChanged: notifier.setRepetitionsTotal)),
            const SizedBox(width: 12),
            Expanded(
                child: _Counter(
                    label: 'aya',
                    value: settings.repetitionsPerAyah,
                    min: 1,
                    max: 50,
                    onChanged: notifier.setRepetitionsPerAyah)),
            const SizedBox(width: 12),
            Expanded(
                child: _Counter(
                    label: 'pause',
                    value: settings.delayBetweenAyahs.round(),
                    min: 0,
                    max: 10,
                    suffix: 'x',
                    onChanged: (v) => notifier.setDelay(v.toDouble()))),
          ]),
        ]),
      ),
    );
  }

  void _startReading(BuildContext context, Surah surah) {
    context.push('/surah/${surah.number}?start=$_startAyah&end=$_endAyah');
  }
}

// ── Widgets ───────────────────────────────────────────────────────────────

/// Champ déroulant sobre, soulignement gris (comme Al-Muqri).
class _DropdownField<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  const _DropdownField(
      {required this.value, required this.items, required this.onChanged});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.only(bottom: 4),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppTheme.border))),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<T>(
            value: value,
            isExpanded: true,
            icon: const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textSecondary),
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary),
            items: items,
            onChanged: onChanged,
          ),
        ),
      );
}

/// Compteur "- valeur +" comme dans Al-Muqri (tout / aya / pause / versets).
class _Counter extends StatelessWidget {
  final String label;
  final int value, min, max;
  final String suffix;
  final ValueChanged<int> onChanged;
  const _Counter(
      {required this.label,
      required this.value,
      required this.min,
      required this.max,
      this.suffix = '',
      required this.onChanged});

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label,
            style:
                const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        Row(children: [
          _RoundIconBtn(
              icon: Icons.remove_rounded,
              onTap: value > min ? () => onChanged(value - 1) : null),
          Expanded(
              child: Center(
                  child: Text('$value$suffix',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w700)))),
          _RoundIconBtn(
              icon: Icons.add_rounded,
              onTap: value < max ? () => onChanged(value + 1) : null),
        ]),
      ]);
}

class _RoundIconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  const _RoundIconBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
                  onTap == null ? AppTheme.surfaceVariant : AppTheme.primary),
          child: Icon(icon,
              size: 16,
              color: onTap == null ? AppTheme.textSecondary : Colors.white),
        ),
      );
}
