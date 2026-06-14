import 'package:hive/hive.dart';

part 'hive_models.g.dart';

// ── Progression par sourate ───────────────────────────────────────────────
@HiveType(typeId: 0)
class SurahProgress extends HiveObject {
  @HiveField(0)
  int surahNumber;

  @HiveField(1)
  String surahName;

  @HiveField(2)
  List<int> memorizedAyahs; // indices des ayahs mémorisées

  @HiveField(3)
  int totalAyahs;

  @HiveField(4)
  DateTime lastStudied;

  @HiveField(5)
  int totalMinutesStudied;

  @HiveField(6)
  int totalSessions;

  SurahProgress({
    required this.surahNumber,
    required this.surahName,
    required this.memorizedAyahs,
    required this.totalAyahs,
    required this.lastStudied,
    this.totalMinutesStudied = 0,
    this.totalSessions = 0,
  });

  double get progressPercent =>
      totalAyahs > 0 ? (memorizedAyahs.length / totalAyahs) * 100 : 0;

  bool get isCompleted => memorizedAyahs.length >= totalAyahs;
}

// ── Favori ────────────────────────────────────────────────────────────────
@HiveType(typeId: 1)
class FavoriteAyah extends HiveObject {
  @HiveField(0)
  int surahNumber;

  @HiveField(1)
  String surahName;

  @HiveField(2)
  int ayahNumber;

  @HiveField(3)
  String ayahText;

  @HiveField(4)
  DateTime savedAt;

  @HiveField(5)
  String? note;

  FavoriteAyah({
    required this.surahNumber,
    required this.surahName,
    required this.ayahNumber,
    required this.ayahText,
    required this.savedAt,
    this.note,
  });
}

// ── Session d'étude ───────────────────────────────────────────────────────
@HiveType(typeId: 2)
class StudySession extends HiveObject {
  @HiveField(0)
  int surahNumber;

  @HiveField(1)
  String surahName;

  @HiveField(2)
  int startAyah;

  @HiveField(3)
  int endAyah;

  @HiveField(4)
  int repetitionsUsed;

  @HiveField(5)
  DateTime date;

  @HiveField(6)
  int durationMinutes;

  StudySession({
    required this.surahNumber,
    required this.surahName,
    required this.startAyah,
    required this.endAyah,
    required this.repetitionsUsed,
    required this.date,
    required this.durationMinutes,
  });
}

// ── Paramètres utilisateur ────────────────────────────────────────────────
@HiveType(typeId: 3)
class UserSettings extends HiveObject {
  @HiveField(0)
  String reciterId;

  @HiveField(1)
  int repetitionsPerAyah;

  @HiveField(2)
  double delayBetweenAyahs;

  @HiveField(3)
  double playbackSpeed;

  @HiveField(4)
  double arabicFontSize;

  @HiveField(5)
  bool showTranslation;

  @HiveField(6)
  bool isDarkMode;

  @HiveField(7)
  String translationLanguage;

  UserSettings({
    this.reciterId = 'ar.alafasy',
    this.repetitionsPerAyah = 3,
    this.delayBetweenAyahs = 1.5,
    this.playbackSpeed = 1.0,
    this.arabicFontSize = 28,
    this.showTranslation = false,
    this.isDarkMode = false,
    this.translationLanguage = 'fr.hamidullah',
  });
}
