import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class DuasScreen extends StatefulWidget {
  const DuasScreen({super.key});
  @override
  State<DuasScreen> createState() => _DuasScreenState();
}

const List<Map<String, String>> kDuas = [
  {'cat': 'Matin', 'ar': 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ', 'fr': 'Nous voici au matin, et c\'est Allah qui règne sur toute chose.', 'source': 'Muslim'},
  {'cat': 'Matin', 'ar': 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا وَبِكَ نَحْيَا وَبِكَ نَمُوتُ وَإِلَيْكَ النُّشُورُ', 'fr': 'Ô Allah, c\'est grâce à Toi que nous entrons dans le matin, grâce à Toi que nous entrons dans le soir, grâce à Toi que nous vivons, que nous mourons, et vers Toi est le retour.', 'source': 'Tirmidhi'},
  {'cat': 'Soir', 'ar': 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ', 'fr': 'Nous voici au soir, et c\'est Allah qui règne sur toute chose.', 'source': 'Muslim'},
  {'cat': 'Repas', 'ar': 'بِسْمِ اللَّهِ', 'fr': 'Au nom d\'Allah.', 'source': 'Bukhari'},
  {'cat': 'Repas', 'ar': 'الْحَمْدُ لِلَّهِ الَّذِي أَطْعَمَنَا وَسَقَانَا وَجَعَلَنَا مُسْلِمِينَ', 'fr': 'Louange à Allah qui nous a nourris, abreuvés et faits musulmans.', 'source': 'Abu Dawud'},
  {'cat': 'Sommeil', 'ar': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا', 'fr': 'En Ton nom, ô Allah, je meurs et je vis.', 'source': 'Bukhari'},
  {'cat': 'Sortie', 'ar': 'بِسْمِ اللَّهِ تَوَكَّلْتُ عَلَى اللَّهِ وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ', 'fr': 'Au nom d\'Allah, je place ma confiance en Allah, il n\'y a de force qu\'en Allah.', 'source': 'Abu Dawud'},
  {'cat': 'Entrée', 'ar': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَ الْمَوْلِجِ وَخَيْرَ الْمَخْرَجِ', 'fr': 'Ô Allah, je Te demande le bien à l\'entrée et le bien à la sortie.', 'source': 'Abu Dawud'},
  {'cat': 'Voyage', 'ar': 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَٰذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ', 'fr': 'Gloire à Celui qui nous a soumis ceci, alors que nous n\'étions pas capables de le faire.', 'source': 'Muslim'},
  {'cat': 'Protection', 'ar': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ', 'fr': 'Je cherche refuge dans les paroles parfaites d\'Allah contre le mal de ce qu\'Il a créé.', 'source': 'Muslim'},
];

class _DuasScreenState extends State<DuasScreen> {
  String _selectedCat = 'Tous';
  final cats = ['Tous', 'Matin', 'Soir', 'Repas', 'Sommeil', 'Sortie', 'Entrée', 'Voyage', 'Protection'];

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCat == 'Tous' ? kDuas : kDuas.where((d) => d['cat'] == _selectedCat).toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Douas & Invocations')),
      body: Column(children: [
        SizedBox(height: 52,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: cats.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (_, i) {
              final sel = cats[i] == _selectedCat;
              return GestureDetector(
                onTap: () => setState(() => _selectedCat = cats[i]),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : AppTheme.primarySurface,
                    borderRadius: BorderRadius.circular(20)),
                  child: Text(cats[i], style: TextStyle(fontWeight: FontWeight.w600,
                    color: sel ? Colors.white : AppTheme.primary, fontSize: 13))),
              );
            },
          )),
        Expanded(child: ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final dua = filtered[i];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade100)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(6)),
                      child: Text(dua['cat']!, style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600))),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: '${dua['ar']}\n\n${dua['fr']}'));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copié !')));
                      },
                      child: const Icon(Icons.copy_rounded, size: 16, color: AppTheme.textSecondary)),
                  ]),
                  Text(dua['source']!, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                ]),
                const SizedBox(height: 10),
                Text(dua['ar']!, textAlign: TextAlign.right, textDirection: TextDirection.rtl,
                  style: const TextStyle(fontFamily: 'Amiri', fontSize: 20, color: AppTheme.textArabic, height: 1.8)),
                const Divider(height: 16),
                Text(dua['fr']!, textAlign: TextAlign.left,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.6)),
              ]),
            );
          },
        )),
      ]),
    );
  }
}
