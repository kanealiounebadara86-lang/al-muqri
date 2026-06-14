import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class NamesScreen extends StatefulWidget {
  const NamesScreen({super.key});
  @override
  State<NamesScreen> createState() => _NamesScreenState();
}

const List<Map<String, String>> kNames = [
  {'ar': 'اللَّهُ', 'fr': 'Allah', 'en': 'Allah'},
  {'ar': 'الرَّحْمَٰنُ', 'fr': 'Le Tout Miséricordieux', 'en': 'The Most Gracious'},
  {'ar': 'الرَّحِيمُ', 'fr': 'Le Très Miséricordieux', 'en': 'The Most Merciful'},
  {'ar': 'الْمَلِكُ', 'fr': 'Le Roi', 'en': 'The King'},
  {'ar': 'الْقُدُّوسُ', 'fr': 'Le Très Saint', 'en': 'The Most Holy'},
  {'ar': 'السَّلَامُ', 'fr': 'La Source de Paix', 'en': 'The Source of Peace'},
  {'ar': 'الْمُؤْمِنُ', 'fr': 'Le Garant de Sécurité', 'en': 'The Granter of Security'},
  {'ar': 'الْمُهَيْمِنُ', 'fr': 'Le Gardien Vigilant', 'en': 'The Guardian'},
  {'ar': 'الْعَزِيزُ', 'fr': 'Le Tout-Puissant', 'en': 'The Almighty'},
  {'ar': 'الْجَبَّارُ', 'fr': 'Le Réparateur', 'en': 'The Compeller'},
  {'ar': 'الْمُتَكَبِّرُ', 'fr': 'Le Suprême Majestueux', 'en': 'The Supreme'},
  {'ar': 'الْخَالِقُ', 'fr': 'Le Créateur', 'en': 'The Creator'},
  {'ar': 'الْبَارِئُ', 'fr': 'L\'Évoluteur', 'en': 'The Originator'},
  {'ar': 'الْمُصَوِّرُ', 'fr': 'Le Façonneur', 'en': 'The Shaper'},
  {'ar': 'الْغَفَّارُ', 'fr': 'Le Grand Pardonneur', 'en': 'The Ever-Forgiving'},
  {'ar': 'الْقَهَّارُ', 'fr': 'Le Dominateur', 'en': 'The Subduer'},
  {'ar': 'الْوَهَّابُ', 'fr': 'Le Donateur', 'en': 'The Giver of Gifts'},
  {'ar': 'الرَّزَّاقُ', 'fr': 'Le Pourvoyeur', 'en': 'The Provider'},
  {'ar': 'الْفَتَّاحُ', 'fr': 'L\'Ouvreur', 'en': 'The Opener'},
  {'ar': 'الْعَلِيمُ', 'fr': 'L\'Omniscient', 'en': 'The All-Knowing'},
  {'ar': 'الْقَابِضُ', 'fr': 'Celui qui Retient', 'en': 'The Restrainer'},
  {'ar': 'الْبَاسِطُ', 'fr': 'Celui qui Donne', 'en': 'The Extender'},
  {'ar': 'الْخَافِضُ', 'fr': 'Celui qui Abaisse', 'en': 'The Abaser'},
  {'ar': 'الرَّافِعُ', 'fr': 'Celui qui Élève', 'en': 'The Exalter'},
  {'ar': 'الْمُعِزُّ', 'fr': 'Celui qui Honore', 'en': 'The Bestower of Honor'},
  {'ar': 'الْمُذِلُّ', 'fr': 'Celui qui Humilie', 'en': 'The Humiliator'},
  {'ar': 'السَّمِيعُ', 'fr': 'Celui qui Entend Tout', 'en': 'The All-Hearing'},
  {'ar': 'الْبَصِيرُ', 'fr': 'Celui qui Voit Tout', 'en': 'The All-Seeing'},
  {'ar': 'الْحَكَمُ', 'fr': 'Le Juge', 'en': 'The Judge'},
  {'ar': 'الْعَدْلُ', 'fr': 'Le Juste', 'en': 'The Just'},
  {'ar': 'اللَّطِيفُ', 'fr': 'Le Doux Bienveillant', 'en': 'The Subtle One'},
  {'ar': 'الْخَبِيرُ', 'fr': 'Le Connaisseur', 'en': 'The All-Aware'},
  {'ar': 'الْحَلِيمُ', 'fr': 'Le Doux Clément', 'en': 'The Forbearing'},
  {'ar': 'الْعَظِيمُ', 'fr': 'Le Très Grand', 'en': 'The Magnificent'},
  {'ar': 'الْغَفُورُ', 'fr': 'Le Pardonneur', 'en': 'The Forgiving'},
  {'ar': 'الشَّكُورُ', 'fr': 'Celui qui Récompense', 'en': 'The Appreciative'},
  {'ar': 'الْعَلِيُّ', 'fr': 'Le Très Haut', 'en': 'The Most High'},
  {'ar': 'الْكَبِيرُ', 'fr': 'Le Grand', 'en': 'The Great'},
  {'ar': 'الْحَفِيظُ', 'fr': 'Le Préservateur', 'en': 'The Preserver'},
  {'ar': 'الْمُقِيتُ', 'fr': 'Le Nourricier', 'en': 'The Sustainer'},
  {'ar': 'الْحَسِيبُ', 'fr': 'Celui qui Suffit', 'en': 'The Reckoner'},
  {'ar': 'الْجَلِيلُ', 'fr': 'Le Sublime', 'en': 'The Majestic'},
  {'ar': 'الْكَرِيمُ', 'fr': 'Le Généreux', 'en': 'The Generous'},
  {'ar': 'الرَّقِيبُ', 'fr': 'Le Vigilant', 'en': 'The Watchful'},
  {'ar': 'الْمُجِيبُ', 'fr': 'Celui qui Répond', 'en': 'The Responsive'},
  {'ar': 'الْوَاسِعُ', 'fr': 'Le Vaste', 'en': 'The All-Encompassing'},
  {'ar': 'الْحَكِيمُ', 'fr': 'Le Sage', 'en': 'The Wise'},
  {'ar': 'الْوَدُودُ', 'fr': 'Celui qui Aime', 'en': 'The Loving'},
  {'ar': 'الْمَجِيدُ', 'fr': 'Le Glorieux', 'en': 'The Glorious'},
  {'ar': 'الْبَاعِثُ', 'fr': 'Celui qui Ressuscite', 'en': 'The Resurrector'},
  {'ar': 'الشَّهِيدُ', 'fr': 'Le Témoin', 'en': 'The Witness'},
  {'ar': 'الْحَقُّ', 'fr': 'La Vérité', 'en': 'The Truth'},
  {'ar': 'الْوَكِيلُ', 'fr': 'Le Garant', 'en': 'The Trustee'},
  {'ar': 'الْقَوِيُّ', 'fr': 'Le Fort', 'en': 'The Strong'},
  {'ar': 'الْمَتِينُ', 'fr': 'Le Solide', 'en': 'The Firm'},
  {'ar': 'الْوَلِيُّ', 'fr': 'L\'Allié', 'en': 'The Protecting Friend'},
  {'ar': 'الْحَمِيدُ', 'fr': 'Le Digne de Louange', 'en': 'The Praiseworthy'},
  {'ar': 'الْمُحْصِي', 'fr': 'Le Dénombreur', 'en': 'The Accounter'},
  {'ar': 'الْمُبْدِئُ', 'fr': 'L\'Initiateur', 'en': 'The Originator'},
  {'ar': 'الْمُعِيدُ', 'fr': 'Le Restaurateur', 'en': 'The Restorer'},
  {'ar': 'الْمُحْيِي', 'fr': 'Celui qui Vivifie', 'en': 'The Giver of Life'},
  {'ar': 'الْمُمِيتُ', 'fr': 'Celui qui Fait Mourir', 'en': 'The Bringer of Death'},
  {'ar': 'الْحَيُّ', 'fr': 'Le Vivant', 'en': 'The Ever-Living'},
  {'ar': 'الْقَيُّومُ', 'fr': 'Le Subsistant', 'en': 'The Self-Subsisting'},
  {'ar': 'الْوَاجِدُ', 'fr': 'Celui qui Trouve', 'en': 'The Finder'},
  {'ar': 'الْمَاجِدُ', 'fr': 'Le Noble', 'en': 'The Noble'},
  {'ar': 'الْوَاحِدُ', 'fr': 'L\'Unique', 'en': 'The One'},
  {'ar': 'الْأَحَدُ', 'fr': 'L\'Indivisible', 'en': 'The Singular'},
  {'ar': 'الصَّمَدُ', 'fr': 'Le Soutien de Tous', 'en': 'The Eternal'},
  {'ar': 'الْقَادِرُ', 'fr': 'Le Capable', 'en': 'The Capable'},
  {'ar': 'الْمُقْتَدِرُ', 'fr': 'Le Tout-Puissant', 'en': 'The Powerful'},
  {'ar': 'الْمُقَدِّمُ', 'fr': 'Celui qui Avance', 'en': 'The Expediter'},
  {'ar': 'الْمُؤَخِّرُ', 'fr': 'Celui qui Reporte', 'en': 'The Delayer'},
  {'ar': 'الْأَوَّلُ', 'fr': 'Le Premier', 'en': 'The First'},
  {'ar': 'الْآخِرُ', 'fr': 'Le Dernier', 'en': 'The Last'},
  {'ar': 'الظَّاهِرُ', 'fr': 'L\'Apparent', 'en': 'The Manifest'},
  {'ar': 'الْبَاطِنُ', 'fr': 'Le Caché', 'en': 'The Hidden'},
  {'ar': 'الْوَالِي', 'fr': 'Le Gouverneur', 'en': 'The Governor'},
  {'ar': 'الْمُتَعَالِي', 'fr': 'Le Très Exalté', 'en': 'The Most Exalted'},
  {'ar': 'الْبَرُّ', 'fr': 'La Source de Tout Bien', 'en': 'The Good'},
  {'ar': 'التَّوَّابُ', 'fr': 'Celui qui Accepte le Repentir', 'en': 'The Ever-Pardoning'},
  {'ar': 'الْمُنْتَقِمُ', 'fr': 'Le Vengeur', 'en': 'The Avenger'},
  {'ar': 'الْعَفُوُّ', 'fr': 'Celui qui Efface', 'en': 'The Pardoner'},
  {'ar': 'الرَّؤُوفُ', 'fr': 'Le Doux Compatissant', 'en': 'The Compassionate'},
  {'ar': 'مَالِكُ الْمُلْكِ', 'fr': 'Maître du Royaume', 'en': 'Owner of Sovereignty'},
  {'ar': 'ذُو الْجَلَالِ وَالْإِكْرَامِ', 'fr': 'Seigneur de Majesté', 'en': 'Lord of Majesty'},
  {'ar': 'الْمُقْسِطُ', 'fr': 'L\'Équitable', 'en': 'The Equitable'},
  {'ar': 'الْجَامِعُ', 'fr': 'Le Rassembleur', 'en': 'The Gatherer'},
  {'ar': 'الْغَنِيُّ', 'fr': 'Le Riche', 'en': 'The Self-Sufficient'},
  {'ar': 'الْمُغْنِي', 'fr': 'Celui qui Enrichit', 'en': 'The Enricher'},
  {'ar': 'الْمَانِعُ', 'fr': 'Celui qui Empêche', 'en': 'The Preventer'},
  {'ar': 'الضَّارُّ', 'fr': 'Celui qui Éprouve', 'en': 'The Distresser'},
  {'ar': 'النَّافِعُ', 'fr': 'Celui qui Profite', 'en': 'The Propitious'},
  {'ar': 'النُّورُ', 'fr': 'La Lumière', 'en': 'The Light'},
  {'ar': 'الْهَادِي', 'fr': 'Le Guide', 'en': 'The Guide'},
  {'ar': 'الْبَدِيعُ', 'fr': 'L\'Incomparable', 'en': 'The Incomparable'},
  {'ar': 'الْبَاقِي', 'fr': 'L\'Éternel', 'en': 'The Everlasting'},
  {'ar': 'الْوَارِثُ', 'fr': 'L\'Héritier', 'en': 'The Inheritor'},
  {'ar': 'الرَّشِيدُ', 'fr': 'Le Sage Directeur', 'en': 'The Guide to the Right Path'},
  {'ar': 'الصَّبُورُ', 'fr': 'Le Patient', 'en': 'The Forbearing'},
];

class _NamesScreenState extends State<NamesScreen> {
  String _lang = 'fr';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Les 99 Noms d\'Allah'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _lang = _lang == 'fr' ? 'en' : 'fr'),
            child: Text(_lang == 'fr' ? '🇬🇧 EN' : '🇫🇷 FR',
              style: const TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.3),
        itemCount: kNames.length,
        itemBuilder: (_, i) {
          final name = kNames[i];
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade100),
              boxShadow: [BoxShadow(blurRadius: 4, color: Colors.black.withValues(alpha: 0.04))],
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                width: 28, height: 28,
                decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(8)),
                child: Center(child: Text('${i + 1}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w800)))),
              const SizedBox(height: 8),
              Text(name['ar']!, textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Amiri', fontSize: 18, color: AppTheme.primary, height: 1.5)),
              const SizedBox(height: 4),
              Text(name[_lang]!, textAlign: TextAlign.center,
                maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary, height: 1.3)),
            ]),
          );
        },
      ),
    );
  }
}
