class Surah {
  final int number;
  final String nameArabic;
  final String nameTranslit;
  final String nameFr;
  final int totalAyahs;
  final String revelationType;
  const Surah(
      {required this.number,
      required this.nameArabic,
      required this.nameTranslit,
      required this.nameFr,
      required this.totalAyahs,
      required this.revelationType});
}

class Ayah {
  final int number;
  final int numberInSurah;
  final String text;
  final String? translationFr;
  final String? translationEn;
  final String? translationWo;
  final int surahNumber;
  final String? audioUrl;
  const Ayah(
      {required this.number,
      required this.numberInSurah,
      required this.text,
      this.translationFr,
      this.translationEn,
      this.translationWo,
      required this.surahNumber,
      this.audioUrl});

  String? translationFor(String lang) {
    if (lang == 'fr') return translationFr;
    if (lang == 'en') return translationEn;
    if (lang == 'wo') return translationWo;
    return null;
  }
}

class RecitationSettings {
  final int repetitionsPerAyah;
  final int repetitionsTotal;
  final double delayBetweenAyahs;
  final double playbackSpeed;
  final String reciterId;
  final bool showTranslation;
  final String translationLang;
  final double arabicFontSize;
  final bool pageMode; // true = page entière, false = verset par verset
  final bool tajwidEnabled; // coloration Tajwid approximative

  const RecitationSettings({
    this.repetitionsPerAyah = 1,
    this.repetitionsTotal = 1,
    this.delayBetweenAyahs = 1.5,
    this.playbackSpeed = 1.0,
    this.reciterId = 'alafasy',
    this.showTranslation = true,
    this.translationLang = 'fr',
    this.arabicFontSize = 28,
    this.pageMode = false,
    this.tajwidEnabled = false,
  });

  RecitationSettings copyWith({
    int? repetitionsPerAyah,
    int? repetitionsTotal,
    double? delayBetweenAyahs,
    double? playbackSpeed,
    String? reciterId,
    bool? showTranslation,
    String? translationLang,
    double? arabicFontSize,
    bool? pageMode,
    bool? tajwidEnabled,
  }) =>
      RecitationSettings(
        repetitionsPerAyah: repetitionsPerAyah ?? this.repetitionsPerAyah,
        repetitionsTotal: repetitionsTotal ?? this.repetitionsTotal,
        delayBetweenAyahs: delayBetweenAyahs ?? this.delayBetweenAyahs,
        playbackSpeed: playbackSpeed ?? this.playbackSpeed,
        reciterId: reciterId ?? this.reciterId,
        showTranslation: showTranslation ?? this.showTranslation,
        translationLang: translationLang ?? this.translationLang,
        arabicFontSize: arabicFontSize ?? this.arabicFontSize,
        pageMode: pageMode ?? this.pageMode,
        tajwidEnabled: tajwidEnabled ?? this.tajwidEnabled,
      );
}
