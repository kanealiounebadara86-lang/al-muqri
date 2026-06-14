import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_theme.dart';

/// Menu "Plus" — accès aux fonctions secondaires, style sobre.
class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Plus'), automaticallyImplyLeading: false),
      body: ListView(
        children: [
          _MenuTile(
              icon: Icons.mosque_rounded,
              label: 'Adhan & Iqama',
              onTap: () => context.push('/adhan')),
          _MenuTile(
              icon: Icons.menu_book_rounded,
              label: 'Hadiths',
              onTap: () => context.push('/hadiths')),
          _MenuTile(
              icon: Icons.front_hand_rounded,
              label: 'Douas',
              onTap: () => context.push('/duas')),
          _MenuTile(
              icon: Icons.radio_button_checked_rounded,
              label: 'Tasbih',
              onTap: () => context.push('/tasbih')),
          _MenuTile(
              icon: Icons.nightlight_round,
              label: "99 Noms d'Allah",
              onTap: () => context.push('/names')),
          const Divider(height: 1),
          _MenuTile(
              icon: Icons.settings_outlined,
              label: 'Paramètres',
              onTap: () => context.push('/settings')),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _MenuTile(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primary, size: 22),
      title: Text(label,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppTheme.textSecondary, size: 20),
      onTap: onTap,
    );
  }
}
