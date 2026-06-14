import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class TasbihScreen extends StatefulWidget {
  const TasbihScreen({super.key});
  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  int _count = 0;
  int _total = 0;
  int _target = 33;
  int _cycles = 0;
  String _dhikr = 'سُبْحَانَ اللَّهِ';
  String _dhikrFr = 'Gloire à Allah';

  final List<Map<String, String>> _dhikrList = [
    {'ar': 'سُبْحَانَ اللَّهِ', 'fr': 'Gloire à Allah (Subhanallah)'},
    {'ar': 'الْحَمْدُ لِلَّهِ', 'fr': 'Louange à Allah (Alhamdulillah)'},
    {'ar': 'اللَّهُ أَكْبَرُ', 'fr': 'Allah est le Plus Grand (Allahu Akbar)'},
    {'ar': 'لَا إِلَهَ إِلَّا اللَّهُ', 'fr': 'Il n\'y a de dieu qu\'Allah (La ilaha illallah)'},
    {'ar': 'أَسْتَغْفِرُ اللَّهَ', 'fr': 'Je demande pardon à Allah (Astaghfirullah)'},
    {'ar': 'لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', 'fr': 'Il n\'y a de force qu\'en Allah (Hawqala)'},
  ];

  void _tap() {
    HapticFeedback.lightImpact();
    setState(() {
      _count++;
      _total++;
      if (_count >= _target) {
        _count = 0;
        _cycles++;
        HapticFeedback.heavyImpact();
      }
    });
  }

  void _reset() => setState(() { _count = 0; _total = 0; _cycles = 0; });

  @override
  Widget build(BuildContext context) {
    final progress = _count / _target;
    return Scaffold(
      appBar: AppBar(title: const Text('Tasbih - تسبيح'), actions: [
        IconButton(icon: const Icon(Icons.refresh_rounded), onPressed: _reset),
      ]),
      body: Column(children: [
        // Sélection dhikr
        SizedBox(height: 48, child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: _dhikrList.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final d = _dhikrList[i];
            final sel = d['ar'] == _dhikr;
            return GestureDetector(
              onTap: () => setState(() { _dhikr = d['ar']!; _dhikrFr = d['fr']!; _count = 0; }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary : AppTheme.primarySurface,
                  borderRadius: BorderRadius.circular(20)),
                child: Text(d['ar']!, style: TextStyle(fontFamily: 'Amiri', fontSize: 14, color: sel ? Colors.white : AppTheme.primary))),
            );
          },
        )),
        const SizedBox(height: 8),

        Expanded(child: GestureDetector(
          onTap: _tap,
          child: Container(
            color: Colors.transparent,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              // Texte dhikr
              Text(_dhikr, style: const TextStyle(fontFamily: 'Amiri', fontSize: 32, color: AppTheme.primary, height: 2)),
              Text(_dhikrFr, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
              const SizedBox(height: 40),

              // Cercle compteur
              Stack(alignment: Alignment.center, children: [
                SizedBox(width: 200, height: 200,
                  child: CircularProgressIndicator(value: progress, strokeWidth: 8,
                    backgroundColor: AppTheme.primarySurface, color: AppTheme.primary)),
                Column(children: [
                  Text('$_count', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                  Text('/ $_target', style: const TextStyle(fontSize: 18, color: AppTheme.textSecondary)),
                ]),
              ]),
              const SizedBox(height: 32),

              // Stats
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                _StatPill(label: 'Total', value: '$_total'),
                const SizedBox(width: 16),
                _StatPill(label: 'Cycles', value: '$_cycles'),
              ]),
              const SizedBox(height: 32),

              // Objectif
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('Objectif: ', style: TextStyle(fontWeight: FontWeight.w600)),
                ...[33, 99, 100].map((t) => GestureDetector(
                  onTap: () => setState(() => _target = t),
                  child: Container(margin: const EdgeInsets.only(left: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _target == t ? AppTheme.primary : AppTheme.primarySurface,
                      borderRadius: BorderRadius.circular(12)),
                    child: Text('$t', style: TextStyle(fontWeight: FontWeight.w700, color: _target == t ? Colors.white : AppTheme.primary))),
                )),
              ]),
            ]),
          ),
        )),

        // Bouton taper
        Padding(
          padding: const EdgeInsets.fromLTRB(40, 0, 40, 32),
          child: GestureDetector(
            onTap: _tap,
            child: Container(
              height: 72,
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(36),
                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha: 0.4), blurRadius: 20, offset: const Offset(0, 8))]),
              child: const Center(child: Text('ذِكْر', style: TextStyle(fontFamily: 'Amiri', fontSize: 28, color: Colors.white)))),
          ),
        ),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  final String label, value;
  const _StatPill({required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(12)),
    child: Column(children: [
      Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.primary)),
      Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
    ]));
}
