import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

/// Liste des sourates — style minimaliste Al-Muqri :
/// numéro dans un cercle, nom arabe, translitération, nombre de versets.
class SurahListScreen extends ConsumerWidget {
  const SurahListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final surahsAsync = ref.watch(filteredSurahsProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
          title: const Text('Le Saint Coran'),
          automaticallyImplyLeading: false),
      body: Column(children: [
        // ── Barre de recherche ────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: TextField(
            onChanged: (v) => ref.read(searchQueryProvider.notifier).state = v,
            style: const TextStyle(fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Rechercher une sourate...',
              hintStyle:
                  const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded,
                  color: AppTheme.textSecondary, size: 20),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () =>
                          ref.read(searchQueryProvider.notifier).state = '')
                  : null,
              filled: true,
              fillColor: AppTheme.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none),
            ),
          ),
        ),

        // ── Liste ────────────────────────────────────────────────────────
        Expanded(
          child: surahsAsync.when(
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppTheme.primary)),
            error: (e, _) => Center(child: Text('Erreur: $e')),
            data: (surahs) => _buildList(context, ref, surahs),
          ),
        ),
      ]),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Surah> surahs) {
    return ListView.separated(
      itemCount: surahs.length,
      separatorBuilder: (_, __) => const Divider(height: 1, indent: 70),
      itemBuilder: (context, index) {
        final surah = surahs[index];
        return _SurahTile(surah: surah);
      },
    );
  }
}

class _SurahTile extends ConsumerWidget {
  final Surah surah;
  const _SurahTile({required this.surah});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        ref.read(selectedSurahProvider.notifier).state = surah;
        context.push('/setup');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          // Numéro dans un cercle
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.border, width: 1.5)),
            child: Center(
                child: Text('${surah.number}',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary))),
          ),
          const SizedBox(width: 16),

          // Nom translit + type
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(surah.nameTranslit,
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary)),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(
                      surah.revelationType == 'Meccan'
                          ? Icons.location_city_rounded
                          : Icons.mosque_rounded,
                      size: 12,
                      color: AppTheme.textSecondary),
                  const SizedBox(width: 4),
                  Text(
                      '${surah.revelationType == 'Meccan' ? 'Mecquoise' : 'Médinoise'} • ${surah.totalAyahs} versets',
                      style: const TextStyle(
                          fontSize: 11, color: AppTheme.textSecondary)),
                ]),
              ])),

          // Nom arabe
          Text(surah.nameArabic,
              style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 22,
                  color: AppTheme.textArabic)),
        ]),
      ),
    );
  }
}
