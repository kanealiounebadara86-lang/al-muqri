class AdhanInfo {
  final String id;
  final String name;
  final String nameAr;
  final String assetPath; // assets/audio/xxx.mp3 (à placer dans le projet)
  final String fallbackUrl; // URL de secours si l'asset n'existe pas encore
  const AdhanInfo(
      {required this.id,
      required this.name,
      required this.nameAr,
      required this.assetPath,
      required this.fallbackUrl});
}

const List<AdhanInfo> kAdhans = [
  AdhanInfo(
      id: 'makkah',
      name: 'Adhan de La Mecque',
      nameAr: 'أذان مكة المكرمة',
      assetPath: 'assets/audio/adhan_makkah.mp3',
      fallbackUrl: 'https://download.quranicaudio.com/adhans/Makkah.mp3'),
  AdhanInfo(
      id: 'madinah',
      name: 'Adhan de Médine',
      nameAr: 'أذان المدينة المنورة',
      assetPath: 'assets/audio/adhan_madinah.mp3',
      fallbackUrl: 'https://download.quranicaudio.com/adhans/Madinah.mp3'),
  AdhanInfo(
      id: 'egypt',
      name: 'Adhan Égyptien',
      nameAr: 'أذان مصري',
      assetPath: 'assets/audio/adhan_egypt.mp3',
      fallbackUrl: 'https://download.quranicaudio.com/adhans/Cairo.mp3'),
  AdhanInfo(
      id: 'turkey',
      name: 'Adhan Turc',
      nameAr: 'الأذان التركي',
      assetPath: 'assets/audio/adhan_turkey.mp3',
      fallbackUrl: 'https://download.quranicaudio.com/adhans/Turkey.mp3'),
];

const List<AdhanInfo> kIqamahs = [
  AdhanInfo(
      id: 'iqamah1',
      name: 'Iqama classique',
      nameAr: 'إقامة الصلاة',
      assetPath: 'assets/audio/iqamah.mp3',
      fallbackUrl: 'https://download.quranicaudio.com/adhans/Iqamah.mp3'),
];

const String kAdhanTextAr = 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ\n'
    'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ\n'
    'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ\n'
    'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ\n'
    'أَشْهَدُ أَنَّ مُحَمَّداً رَسُولُ اللَّهِ\n'
    'أَشْهَدُ أَنَّ مُحَمَّداً رَسُولُ اللَّهِ\n'
    'حَيَّ عَلَى الصَّلَاةِ • حَيَّ عَلَى الصَّلَاةِ\n'
    'حَيَّ عَلَى الْفَلَاحِ • حَيَّ عَلَى الْفَلَاحِ\n'
    'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ\n'
    'لَا إِلَهَ إِلَّا اللَّهُ';

const String kAdhanTextFr = 'Allah est le Plus Grand (×4)\n'
    "J'atteste qu'il n'y a de dieu qu'Allah (×2)\n"
    "J'atteste que Muhammad est le Messager d'Allah (×2)\n"
    'Venez à la prière (×2)\n'
    'Venez au salut (×2)\n'
    'Allah est le Plus Grand (×2)\n'
    "Il n'y a de dieu qu'Allah";

const String kIqamahTextAr = 'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ\n'
    'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ\n'
    'أَشْهَدُ أَنَّ مُحَمَّداً رَسُولُ اللَّهِ\n'
    'حَيَّ عَلَى الصَّلَاةِ\n'
    'حَيَّ عَلَى الْفَلَاحِ\n'
    'قَدْ قَامَتِ الصَّلَاةُ • قَدْ قَامَتِ الصَّلَاةُ\n'
    'اللَّهُ أَكْبَرُ اللَّهُ أَكْبَرُ\n'
    'لَا إِلَهَ إِلَّا اللَّهُ';

const String kIqamahTextFr = 'Allah est le Plus Grand (×2)\n'
    "J'atteste qu'il n'y a de dieu qu'Allah\n"
    "J'atteste que Muhammad est le Messager d'Allah\n"
    'Venez à la prière\n'
    'Venez au salut\n'
    'La prière est sur le point de commencer (×2)\n'
    'Allah est le Plus Grand (×2)\n'
    "Il n'y a de dieu qu'Allah";
