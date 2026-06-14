// Al-Fatiha complète avec traductions FR/EN/Wolof embarquées
class AyahTranslations {
  final int number;
  final String arabic;
  final String french;
  final String english;
  final String wolof;
  const AyahTranslations({required this.number, required this.arabic, required this.french, required this.english, required this.wolof});
}

const List<AyahTranslations> kFatihaTranslations = [
  AyahTranslations(number: 1, arabic: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ', french: 'Au nom d\'Allah, le Tout Miséricordieux, le Très Miséricordieux.', english: 'In the name of Allah, the Entirely Merciful, the Especially Merciful.', wolof: 'Ci turu Yàlla, Boroom xam-xam ak jàmm.'),
  AyahTranslations(number: 2, arabic: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ', french: 'Louange à Allah, Seigneur des mondes.', english: 'All praise is due to Allah, Lord of the worlds.', wolof: 'Hamdu Yàlla, Boroom aalam yi.'),
  AyahTranslations(number: 3, arabic: 'الرَّحْمَٰنِ الرَّحِيمِ', french: 'Le Tout Miséricordieux, le Très Miséricordieux.', english: 'The Entirely Merciful, the Especially Merciful.', wolof: 'Boroom xam-xam, Boroom jàmm.'),
  AyahTranslations(number: 4, arabic: 'مَالِكِ يَوْمِ الدِّينِ', french: 'Maître du Jour de la rétribution.', english: 'Sovereign of the Day of Recompense.', wolof: 'Boroom bés bu ndigël.'),
  AyahTranslations(number: 5, arabic: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ', french: 'C\'est Toi [Seul] que nous adorons, et c\'est Toi [Seul] dont nous implorons le secours.', english: 'It is You we worship and You we ask for help.', wolof: 'Yow rekk la nu sujude, yow rekk la nu dëggël.'),
  AyahTranslations(number: 6, arabic: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ', french: 'Guide-nous dans le droit chemin.', english: 'Guide us to the straight path.', wolof: 'Seetali nu yoon wu dëgg.'),
  AyahTranslations(number: 7, arabic: 'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ', french: 'Le chemin de ceux que Tu as comblés de faveurs, non pas de ceux qui ont encouru Ta colère, ni des égarés.', english: 'The path of those upon whom You have bestowed favor, not of those who have earned anger nor of those who are astray.', wolof: 'Yoon yu ñu yem ñi nga yëgël, du yoon yu ñu yëp ci kaw, du yoon yu ñi dem fey.'),
];
