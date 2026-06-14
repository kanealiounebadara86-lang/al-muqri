import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute favoritesRefreshProvider pour se reconstruire à chaque changement
    ref.watch(favoritesRefreshProvider);
    final storage = ref.read(localStorageProvider);
    final favorites = storage.getFavorites();

    return Scaffold(
      appBar: AppBar(title: const Text('Mes Favoris')),
      body: favorites.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: favorites.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final fav = favorites[i];
                return Dismissible(
                  key: Key('${fav.surahNumber}_${fav.ayahNumber}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(14)),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppTheme.textSecondary),
                  ),
                  onDismissed: (_) async {
                    await storage.toggleFavorite(
                      surahNumber: fav.surahNumber,
                      surahName: fav.surahName,
                      ayahNumber: fav.ayahNumber,
                      ayahText: fav.ayahText,
                    );
                    // Déclencher la reconstruction de cet écran ET du lecteur
                    ref.read(favoritesRefreshProvider.notifier).state++;
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppTheme.border)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Bouton naviguer vers la sourate
                            GestureDetector(
                              onTap: () {
                                final surah = ref.read(selectedSurahProvider);
                                // Si la sourate correspond, aller directement
                                if (surah != null &&
                                    surah.number == fav.surahNumber) {
                                  context.push(
                                      '/surah/${fav.surahNumber}?start=${fav.ayahNumber}&end=${fav.ayahNumber}');
                                } else {
                                  context.push(
                                      '/surah/${fav.surahNumber}?start=${fav.ayahNumber}&end=${fav.ayahNumber}');
                                }
                              },
                              child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                        Icons.play_circle_outline_rounded,
                                        size: 16,
                                        color: AppTheme.primary),
                                    const SizedBox(width: 4),
                                    Text(
                                        '${fav.surahName} • Verset ${fav.ayahNumber}',
                                        style: const TextStyle(
                                            color: AppTheme.primary,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13)),
                                  ]),
                            ),
                            Row(mainAxisSize: MainAxisSize.min, children: [
                              // Bouton copier
                              GestureDetector(
                                  onTap: () async {
                                    await Clipboard.setData(ClipboardData(
                                        text:
                                            '${fav.ayahText}\n\n[${fav.surahName}, verset ${fav.ayahNumber}]'));
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(const SnackBar(
                                              content: Text('Verset copié'),
                                              duration: Duration(seconds: 2),
                                              behavior:
                                                  SnackBarBehavior.floating));
                                    }
                                  },
                                  child: const Icon(Icons.copy_rounded,
                                      size: 16, color: AppTheme.textSecondary)),
                              const SizedBox(width: 10),
                              const Icon(Icons.bookmark_rounded,
                                  color: AppTheme.accent, size: 18),
                            ]),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(fav.ayahText,
                            textAlign: TextAlign.right,
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontSize: 20,
                                color: AppTheme.textArabic,
                                height: 1.8)),
                      ],
                    ),
                  )
                      .animate(delay: Duration(milliseconds: i * 50))
                      .fadeIn()
                      .slideX(begin: 0.05),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_border_rounded,
              size: 64, color: AppTheme.textSecondary),
          SizedBox(height: 16),
          Text('Aucun favori',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          SizedBox(height: 8),
          Text('Appuyez sur ♡ dans le lecteur\npour sauvegarder un verset',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppTheme.textSecondary, height: 1.5)),
        ],
      ),
    );
  }
}
