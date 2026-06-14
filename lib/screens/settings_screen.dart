import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import '../services/audio_cache_service.dart';
import '../services/notification_service.dart';
import '../data/reciters_data.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _section('Récitateur'),
          ...kRecitersInfo.map((r) {
            final selected = s.reciterId == r.id;
            return GestureDetector(
              onTap: () => n.setReciter(r.id),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                    color: selected ? AppTheme.primary : AppTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: selected ? AppTheme.primary : AppTheme.border,
                        width: selected ? 2 : 1)),
                child: Row(children: [
                  Text(r.flag, style: const TextStyle(fontSize: 26)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(r.nameFr,
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: selected
                                    ? Colors.white
                                    : AppTheme.textPrimary)),
                        Text(r.nameAr,
                            style: TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 14,
                                color: selected
                                    ? Colors.white70
                                    : AppTheme.textSecondary)),
                        Text(r.country,
                            style: TextStyle(
                                fontSize: 11,
                                color: selected
                                    ? Colors.white60
                                    : AppTheme.textSecondary)),
                      ])),
                  Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.surfaceVariant
                              : AppTheme.primarySurface,
                          borderRadius: BorderRadius.circular(6)),
                      child: Text(r.style,
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color:
                                  selected ? Colors.white : AppTheme.primary))),
                  if (selected) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.check_circle_rounded,
                        color: Colors.white, size: 20)
                  ],
                ]),
              ),
            );
          }),
          const SizedBox(height: 24),
          _section('Lecture'),
          _slider(
              'Répétitions par verset',
              '${s.repetitionsPerAyah}×',
              s.repetitionsPerAyah.toDouble(),
              1,
              10,
              9,
              (v) => n.setRepetitionsPerAyah(v.round())),
          _slider(
              'Délai entre versets',
              '${s.delayBetweenAyahs.toStringAsFixed(1)}s',
              s.delayBetweenAyahs,
              0.5,
              5,
              9,
              n.setDelay),
          _slider(
              'Vitesse de lecture',
              '×${s.playbackSpeed.toStringAsFixed(1)}',
              s.playbackSpeed,
              0.5,
              1.5,
              4,
              n.setSpeed),
          _slider('Taille texte arabe', '${s.arabicFontSize.round()}px',
              s.arabicFontSize, 20, 44, 6, n.setFontSize),
          const SizedBox(height: 24),
          _section('Affichage'),
          _switchTile(
              label: 'Mode page',
              subtitle:
                  "Afficher la page entière au lieu d'un verset à la fois",
              icon: Icons.menu_book_rounded,
              value: s.pageMode,
              onChanged: (v) => n.togglePageMode()),
          _switchTile(
              label: 'Couleurs Tajwid',
              subtitle: 'Coloration approximative des règles de récitation',
              icon: Icons.format_color_text_rounded,
              value: s.tajwidEnabled,
              onChanged: (v) => n.update(s.copyWith(tajwidEnabled: v))),
          const SizedBox(height: 24),
          _section('Traduction'),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _chip('🚫 Aucune', !s.showTranslation,
                () => n.update(s.copyWith(showTranslation: false))),
            _chip(
                '🇫🇷 Français',
                s.showTranslation && s.translationLang == 'fr',
                () => n.setTranslationLang('fr')),
            _chip(
                '🇬🇧 English',
                s.showTranslation && s.translationLang == 'en',
                () => n.setTranslationLang('en')),
            _chip('🇸🇳 Wolof', s.showTranslation && s.translationLang == 'wo',
                () => n.setTranslationLang('wo')),
          ]),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _switchTile(
          {required String label,
          required String subtitle,
          required IconData icon,
          required bool value,
          required ValueChanged<bool> onChanged}) =>
      Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border)),
          child: SwitchListTile(
            secondary: Icon(icon, color: AppTheme.primary, size: 22),
            title: Text(label,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            subtitle: Text(subtitle,
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary)),
            value: value,
            onChanged: onChanged,
          ));

  Widget _section(String title) => Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppTheme.primary)));

  Widget _slider(String label, String val, double value, double min, double max,
          int div, ValueChanged<double> fn) =>
      Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border)),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(
                      color: AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(8)),
                  child: Text(val,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primary,
                          fontSize: 13))),
            ]),
            Slider(
                value: value,
                min: min,
                max: max,
                divisions: div,
                activeColor: AppTheme.primary,
                onChanged: fn),
          ]));

  Widget _chip(String label, bool selected, VoidCallback onTap) =>
      GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                  color: selected ? AppTheme.primary : AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(20)),
              child: Text(label,
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: selected ? Colors.white : AppTheme.primary))));
}
