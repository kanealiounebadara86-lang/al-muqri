class Hadith {
  final int id;
  final String arabic;
  final String french;
  final String english;
  final String source;
  final String narrator;

  const Hadith({
    required this.id,
    required this.arabic,
    required this.french,
    required this.english,
    required this.source,
    required this.narrator,
  });
}

const List<Hadith> kHadiths = [
  Hadith(
    id: 1,
    arabic: 'إِنَّمَا الْأَعْمَالُ بِالنِّيَّاتِ',
    french: 'Les actes ne valent que par les intentions.',
    english: 'Actions are judged by intentions.',
    source: 'Sahih Al-Bukhari',
    narrator: 'Omar ibn Al-Khattab',
  ),
  Hadith(
    id: 2,
    arabic: 'الدِّينُ النَّصِيحَةُ',
    french: 'La religion, c\'est la sincérité.',
    english: 'Religion is sincerity.',
    source: 'Sahih Muslim',
    narrator: 'Tamim Ad-Dari',
  ),
  Hadith(
    id: 3,
    arabic: 'مَنْ كَانَ يُؤْمِنُ بِاللَّهِ وَالْيَوْمِ الآخِرِ فَلْيَقُلْ خَيْرًا أَوْ لِيَصْمُتْ',
    french: 'Que celui qui croit en Allah et au Jour dernier dise une bonne parole ou qu\'il se taise.',
    english: 'Whoever believes in Allah and the Last Day should speak good or remain silent.',
    source: 'Sahih Al-Bukhari',
    narrator: 'Abu Hurayra',
  ),
  Hadith(
    id: 4,
    arabic: 'لاَ يُؤْمِنُ أَحَدُكُمْ حَتَّى يُحِبَّ لأَخِيهِ مَا يُحِبُّ لِنَفْسِهِ',
    french: 'Aucun de vous ne croit vraiment tant qu\'il n\'aime pas pour son frère ce qu\'il aime pour lui-même.',
    english: 'None of you truly believes until he loves for his brother what he loves for himself.',
    source: 'Sahih Al-Bukhari',
    narrator: 'Anas ibn Malik',
  ),
  Hadith(
    id: 5,
    arabic: 'الْمُسْلِمُ مَنْ سَلِمَ الْمُسْلِمُونَ مِنْ لِسَانِهِ وَيَدِهِ',
    french: 'Le musulman est celui dont les autres musulmans sont à l\'abri de sa langue et de sa main.',
    english: 'A Muslim is the one from whose tongue and hands the Muslims are safe.',
    source: 'Sahih Al-Bukhari',
    narrator: 'Abdullah ibn Amr',
  ),
  Hadith(
    id: 6,
    arabic: 'طَلَبُ الْعِلْمِ فَرِيضَةٌ عَلَى كُلِّ مُسْلِمٍ',
    french: 'La recherche du savoir est une obligation pour tout musulman.',
    english: 'Seeking knowledge is an obligation upon every Muslim.',
    source: 'Ibn Majah',
    narrator: 'Anas ibn Malik',
  ),
  Hadith(
    id: 7,
    arabic: 'خَيْرُكُمْ مَنْ تَعَلَّمَ الْقُرْآنَ وَعَلَّمَهُ',
    french: 'Le meilleur d\'entre vous est celui qui apprend le Coran et l\'enseigne.',
    english: 'The best of you are those who learn the Quran and teach it.',
    source: 'Sahih Al-Bukhari',
    narrator: 'Uthman ibn Affan',
  ),
  Hadith(
    id: 8,
    arabic: 'إِنَّ اللَّهَ لاَ يَنْظُرُ إِلَى صُوَرِكُمْ وَأَمْوَالِكُمْ وَلَكِنْ يَنْظُرُ إِلَى قُلُوبِكُمْ وَأَعْمَالِكُمْ',
    french: 'Allah ne regarde pas vos formes ni vos richesses, mais Il regarde vos cœurs et vos actes.',
    english: 'Allah does not look at your forms and wealth, but He looks at your hearts and deeds.',
    source: 'Sahih Muslim',
    narrator: 'Abu Hurayra',
  ),
  Hadith(
    id: 9,
    arabic: 'الصَّلَوَاتُ الْخَمْسُ وَالْجُمْعَةُ إِلَى الْجُمْعَةِ كَفَّارَةٌ لِمَا بَيْنَهُنَّ',
    french: 'Les cinq prières et d\'un vendredi à l\'autre sont une expiation pour ce qui se passe entre elles.',
    english: 'The five prayers and Friday to Friday are expiation for what is between them.',
    source: 'Sahih Muslim',
    narrator: 'Abu Hurayra',
  ),
  Hadith(
    id: 10,
    arabic: 'مَنْ صَامَ رَمَضَانَ إِيمَانًا وَاحْتِسَابًا غُفِرَ لَهُ مَا تَقَدَّمَ مِنْ ذَنْبِهِ',
    french: 'Celui qui jeûne le Ramadan par foi et dans l\'espoir de la récompense divine, ses péchés passés lui seront pardonnés.',
    english: 'Whoever fasts Ramadan out of faith and hoping for reward, his past sins will be forgiven.',
    source: 'Sahih Al-Bukhari',
    narrator: 'Abu Hurayra',
  ),
  Hadith(
    id: 11,
    arabic: 'أَحَبُّ الأَعْمَالِ إِلَى اللَّهِ أَدْوَمُهَا وَإِنْ قَلَّ',
    french: 'Les actes les plus aimés d\'Allah sont ceux qui sont les plus réguliers, même s\'ils sont peu nombreux.',
    english: 'The most beloved deeds to Allah are the most regular, even if they are few.',
    source: 'Sahih Al-Bukhari',
    narrator: 'Aisha',
  ),
  Hadith(
    id: 12,
    arabic: 'اتَّقِ اللَّهَ حَيْثُمَا كُنْتَ وَأَتْبِعِ السَّيِّئَةَ الْحَسَنَةَ تَمْحُهَا',
    french: 'Crains Allah où que tu sois, et fais suivre la mauvaise action d\'une bonne, elle l\'effacera.',
    english: 'Fear Allah wherever you are, and follow up a bad deed with a good one to erase it.',
    source: 'At-Tirmidhi',
    narrator: 'Abu Dhar Al-Ghifari',
  ),
  Hadith(
    id: 13,
    arabic: 'مَنْ دَلَّ عَلَى خَيْرٍ فَلَهُ مِثْلُ أَجْرِ فَاعِلِهِ',
    french: 'Celui qui guide vers un bien aura une récompense similaire à celle de celui qui l\'accomplit.',
    english: 'Whoever guides to something good will have a reward similar to the one who does it.',
    source: 'Sahih Muslim',
    narrator: 'Abu Masud Al-Ansari',
  ),
  Hadith(
    id: 14,
    arabic: 'الْبِرُّ حُسْنُ الْخُلُقِ',
    french: 'La piété, c\'est la bonne conduite.',
    english: 'Righteousness is good character.',
    source: 'Sahih Muslim',
    narrator: 'An-Nawwas ibn Saman',
  ),
  Hadith(
    id: 15,
    arabic: 'تَبَسُّمُكَ فِي وَجْهِ أَخِيكَ صَدَقَةٌ',
    french: 'Ton sourire envers ton frère est une aumône.',
    english: 'Your smile in the face of your brother is charity.',
    source: 'At-Tirmidhi',
    narrator: 'Abu Dhar Al-Ghifari',
  ),
];
