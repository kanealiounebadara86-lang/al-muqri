import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';
import '../theme/app_theme.dart';
import 'recitation_setup_screen.dart';
import 'favorites_screen.dart';
import 'more_screen.dart';

/// Navigation simplifiée — 3 onglets essentiels, comme Al-Muqri :
/// Lecture (configuration + lecteur) / Favoris / Plus.
class MainScaffold extends ConsumerWidget {
  const MainScaffold({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tab = ref.watch(currentTabProvider);
    const screens = [
      RecitationSetupScreen(),
      FavoritesScreen(),
      MoreScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: tab.clamp(0, 2), children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab.clamp(0, 2),
        onDestinationSelected: (i) =>
            ref.read(currentTabProvider.notifier).state = i,
        backgroundColor: AppTheme.surface,
        indicatorColor: AppTheme.surfaceVariant,
        elevation: 0,
        height: 60,
        destinations: const [
          NavigationDestination(
              icon:
                  Icon(Icons.menu_book_outlined, color: AppTheme.textSecondary),
              selectedIcon:
                  Icon(Icons.menu_book_rounded, color: AppTheme.primary),
              label: 'Lecture'),
          NavigationDestination(
              icon: Icon(Icons.bookmark_outline, color: AppTheme.textSecondary),
              selectedIcon:
                  Icon(Icons.bookmark_rounded, color: AppTheme.primary),
              label: 'Favoris'),
          NavigationDestination(
              icon:
                  Icon(Icons.grid_view_outlined, color: AppTheme.textSecondary),
              selectedIcon:
                  Icon(Icons.grid_view_rounded, color: AppTheme.primary),
              label: 'Plus'),
        ],
      ),
    );
  }
}
