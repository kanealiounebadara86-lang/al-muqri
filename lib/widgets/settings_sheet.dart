import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../data/reciters_data.dart';

class SettingsSheet extends ConsumerWidget {
  const SettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(24, 16, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      child: SingleChildScrollView(child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(child: Container(width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 20),
          const Text('Paramètres', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 20),

          // ── Récitateur ──────────────────────────────────────────────
          const Text('Récitateur', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          ...kRecitersInfo.map((r) {
            final selected = s.reciterId == r.id;
            return GestureDetector(
              onTap: () => n.setReciter(r.id), // appliqué immédiatement
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: selected ? AppTheme.primary : Colors.grey.shade200,
                    width: selected ? 2 : 1,
                  ),
                ),
                child: Row(children: [
                  Text(r.flag, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(r.nameFr, style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700,
                      color: selected ? Colors.white : AppTheme.textPrimary)),
                    Text(r.nameAr, style: TextStyle(
                      fontFamily: 'Amiri', fontSize: 14,
                      color: selected ? Colors.white.withValues(alpha: 0.85) : AppTheme.textSecondary)),
                  ])),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(r.country, style: TextStyle(
                      fontSize: 11, color: selected ? Colors.white70 : AppTheme.textSecondary)),
                    Text(r.style, style: TextStyle(
                      fontSize: 11, fontWeight: FontWeight.w600,
                      color: selected ? Colors.white70 : AppTheme.primary)),
                  ]),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  ]
                ]),
              ),
            );
          }),

          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),

          // ── Répétitions (appliquées immédiatement) ──────────────────
          const Text('Répétitions par verset', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 8),
          Row(children: [1, 2, 3, 5, 7, 10].map((v) =>
            GestureDetector(
              onTap: () => n.setRepetitionsPerAyah(v), // immédiat
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 46, height: 46, margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  color: s.repetitionsPerAyah == v ? AppTheme.primary : AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text('$v', style: TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 16,
                  color: s.repetitionsPerAyah == v ? Colors.white : AppTheme.primary)))),
            )
          ).toList()),
          const SizedBox(height: 16),

          // ── Délai ───────────────────────────────────────────────────
          _SliderTile(
            label: 'Délai entre versets',
            valueLabel: '${s.delayBetweenAyahs.toStringAsFixed(1)}s',
            value: s.delayBetweenAyahs, min: 0.5, max: 5, divisions: 9,
            onChanged: n.setDelay),

          _SliderTile(
            label: 'Vitesse de lecture',
            valueLabel: '×${s.playbackSpeed.toStringAsFixed(1)}',
            value: s.playbackSpeed, min: 0.5, max: 1.5, divisions: 4,
            onChanged: n.setSpeed),

          _SliderTile(
            label: 'Taille du texte arabe',
            valueLabel: '${s.arabicFontSize.round()}px',
            value: s.arabicFontSize, min: 20, max: 44, divisions: 6,
            onChanged: n.setFontSize),

          const Divider(),
          const SizedBox(height: 8),

          // ── Traduction ──────────────────────────────────────────────
          const Text('Traduction', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _LangChip(label: 'Aucune', emoji: '🚫',
              selected: !s.showTranslation,
              onTap: () => n.update(s.copyWith(showTranslation: false))),
            _LangChip(label: 'Français', emoji: '🇫🇷',
              selected: s.showTranslation && s.translationLang == 'fr',
              onTap: () => n.setTranslationLang('fr')),
            _LangChip(label: 'English', emoji: '🇬🇧',
              selected: s.showTranslation && s.translationLang == 'en',
              onTap: () => n.setTranslationLang('en')),
            _LangChip(label: 'Wolof', emoji: '🇸🇳',
              selected: s.showTranslation && s.translationLang == 'wo',
              onTap: () => n.setTranslationLang('wo')),
          ]),
          const SizedBox(height: 8),
        ],
      )),
    );
  }
}

class _SliderTile extends StatelessWidget {
  final String label, valueLabel;
  final double value, min, max;
  final int divisions;
  final ValueChanged<double> onChanged;
  const _SliderTile({required this.label, required this.valueLabel,
    required this.value, required this.min, required this.max,
    required this.divisions, required this.onChanged});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(8)),
          child: Text(valueLabel, style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary, fontSize: 13))),
      ]),
      Slider(value: value, min: min, max: max, divisions: divisions,
        activeColor: AppTheme.primary, onChanged: onChanged),
      const SizedBox(height: 4),
    ]);
}

class _LangChip extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;
  const _LangChip({required this.label, required this.emoji, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary : AppTheme.primarySurface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: selected ? AppTheme.primary : Colors.transparent)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Text(emoji, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 6),
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppTheme.primary)),
      ])));
}
