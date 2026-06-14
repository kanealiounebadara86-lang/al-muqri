import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';
import '../providers/providers.dart';
import '../services/local_storage_service.dart';
import '../models/hive_models.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final storage = ref.watch(localStorageProvider);
    final recentSessions = storage.getRecentSessions(limit: 1);

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeader(context, ref, isDark)),
            SliverToBoxAdapter(child: _buildQuickActions(context, ref)),
            SliverToBoxAdapter(child: _buildLastStudied(context, ref, recentSessions, storage)),
            SliverToBoxAdapter(child: _buildStats(context, storage)),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryLight],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text('ق', style: TextStyle(fontFamily: 'Amiri', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(width: 10),
            const Text('المُقري', style: TextStyle(fontFamily: 'Amiri', color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ]),
          IconButton(
            icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, color: Colors.white),
            onPressed: () => ref.read(isDarkModeProvider.notifier).state = !isDark,
          ),
        ]),
        const SizedBox(height: 20),
        const Text('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          style: TextStyle(fontFamily: 'Amiri', color: Colors.white, fontSize: 22, height: 2),
          textAlign: TextAlign.right),
        const SizedBox(height: 4),
        Text("Au nom d'Allah, le Tout Miséricordieux",
          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
      ]),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.05);
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Commencer', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _ActionCard(
            icon: Icons.menu_book_rounded, label: 'Choisir\nune Sourate',
            color: AppTheme.primary,
            onTap: () => ref.read(currentTabProvider.notifier).state = 1,
          )),
          const SizedBox(width: 10),
          Expanded(child: _ActionCard(
            icon: Icons.repeat_rounded, label: 'Continuer\nl\'apprentissage',
            color: AppTheme.accent,
            onTap: () => ref.read(currentTabProvider.notifier).state = 1,
          )),
          const SizedBox(width: 10),
          Expanded(child: _ActionCard(
            icon: Icons.grid_view_rounded, label: 'Explorer\nplus',
            color: const Color(0xFF7C3AED),
            onTap: () => ref.read(currentTabProvider.notifier).state = 4,
          )),
        ]).animate().fadeIn(delay: 200.ms),
      ]),
    );
  }

  Widget _buildLastStudied(BuildContext context, WidgetRef ref,
      List<StudySession> sessions, LocalStorageService storage) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Dernière session', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 12),
        sessions.isEmpty
          ? _buildNoSession(context, ref)
          : _buildSessionCard(context, ref, sessions.first, storage),
      ]).animate().fadeIn(delay: 300.ms),
    );
  }

  Widget _buildNoSession(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () => ref.read(currentTabProvider.notifier).state = 1,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.2)),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.play_arrow_rounded, color: AppTheme.primary, size: 28)),
          const SizedBox(width: 14),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text("Commencer à apprendre", style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            SizedBox(height: 4),
            Text('Choisissez une sourate pour débuter', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
          ])),
          const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.primary),
        ]),
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, WidgetRef ref,
      StudySession session, LocalStorageService storage) {
    final progress = storage.getProgress(session.surahNumber);
    final pct = progress != null
      ? (progress.memorizedAyahs.length / progress.totalAyahs.clamp(1, 999))
      : 0.0;
    return GestureDetector(
      onTap: () => ref.read(currentTabProvider.notifier).state = 1,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            AppTheme.primary.withValues(alpha: 0.06),
            AppTheme.accent.withValues(alpha: 0.04)]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.primary.withValues(alpha: 0.12)),
        ),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.play_circle_filled_rounded, color: AppTheme.primary, size: 30)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(session.surahName, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
            const SizedBox(height: 2),
            Text('Versets ${session.startAyah}-${session.endAyah}',
              style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: pct, backgroundColor: Colors.grey.shade200,
                color: AppTheme.primary, minHeight: 6)),
          ])),
          const SizedBox(width: 10),
          Text('${(pct * 100).round()}%',
            style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w800, fontSize: 16)),
        ]),
      ),
    );
  }

  Widget _buildStats(BuildContext context, LocalStorageService storage) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('Ma progression', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _StatCard(value: '${storage.totalMemorizedAyahs}', label: 'Versets\nmémorisés', icon: Icons.auto_stories_rounded, color: AppTheme.primary)),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(value: '${storage.totalSurahsStudied}', label: 'Sourates\nétudiées', icon: Icons.menu_book_rounded, color: const Color(0xFF7C3AED))),
          const SizedBox(width: 10),
          Expanded(child: _StatCard(value: '${storage.currentStreak}j', label: 'Série\nactuelle', icon: Icons.local_fire_department_rounded, color: AppTheme.accent)),
        ]),
      ]).animate().fadeIn(delay: 500.ms),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _ActionCard({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center,
            style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600, height: 1.4)),
        ]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.12)),
      ),
      child: Column(children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        Text(label, textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, height: 1.3)),
      ]),
    );
  }
}
