class ReciterInfo {
  final String id;
  final String nameAr;
  final String nameFr;
  final String everyayahCode;
  final String style;
  final String country;
  final String flag;

  const ReciterInfo({
    required this.id,
    required this.nameAr,
    required this.nameFr,
    required this.everyayahCode,
    required this.style,
    required this.country,
    required this.flag,
  });
}

/// Liste réduite aux récitateurs dont l'audio est VÉRIFIÉ et fonctionnel
/// sur le CDN cdn.islamic.network (ayah-level, CORS ouvert).
const List<ReciterInfo> kRecitersInfo = [
  ReciterInfo(
      id: 'alafasy',
      nameAr: 'مشاري راشد العفاسي',
      nameFr: 'Mishary Alafasy',
      everyayahCode: 'Alafasy_128kbps',
      style: 'Murattal',
      country: 'Koweït',
      flag: '🇰🇼'),
  ReciterInfo(
      id: 'sudais',
      nameAr: 'عبد الرحمن السديس',
      nameFr: 'Abdurrahmaan As-Sudais',
      everyayahCode: 'Abdurrahmaan_As-Sudais_192kbps',
      style: 'Murattal',
      country: 'Arabie Saoudite',
      flag: '🇸🇦'),
  ReciterInfo(
      id: 'shuraim',
      nameAr: 'سعود الشريم',
      nameFr: 'Saud Ash-Shuraim',
      everyayahCode: 'Saud_ash-Shuraym_128kbps',
      style: 'Murattal',
      country: 'Arabie Saoudite',
      flag: '🇸🇦'),
  ReciterInfo(
      id: 'husary',
      nameAr: 'محمود خليل الحصري',
      nameFr: 'Mahmoud Al-Husary',
      everyayahCode: 'Husary_128kbps',
      style: 'Murattal',
      country: 'Égypte',
      flag: '🇪🇬'),
  ReciterInfo(
      id: 'minshawi',
      nameAr: 'محمد صديق المنشاوي',
      nameFr: 'Mohamed Al-Minshawi',
      everyayahCode: 'Minshawy_Murattal_128kbps',
      style: 'Murattal',
      country: 'Égypte',
      flag: '🇪🇬'),
];
