import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive_models.dart';

class LocalStorageService {
  static const String _progressBox = 'surah_progress';
  static const String _favoritesBox = 'favorites';
  static const String _sessionsBox = 'study_sessions';
  static const String _settingsBox = 'user_settings';
  static const String _settingsKey = 'settings';

  // ── Initialisation (appelé dans main.dart) ────────────────────────────
  static Future<void> init() async {
    await Hive.initFlutter();

    // Enregistrer les adapters
    Hive.registerAdapter(SurahProgressAdapter());
    Hive.registerAdapter(FavoriteAyahAdapter());
    Hive.registerAdapter(StudySessionAdapter());
    Hive.registerAdapter(UserSettingsAdapter());

    // Ouvrir les boîtes
    await Hive.openBox<SurahProgress>(_progressBox);
    await Hive.openBox<FavoriteAyah>(_favoritesBox);
    await Hive.openBox<StudySession>(_sessionsBox);
    await Hive.openBox<UserSettings>(_settingsBox);
  }

  // ── Progression ───────────────────────────────────────────────────────
  Box<SurahProgress> get _progress => Hive.box<SurahProgress>(_progressBox);

  SurahProgress? getProgress(int surahNumber) =>
      _progress.get('surah_$surahNumber');

  Future<void> saveProgress(SurahProgress progress) =>
      _progress.put('surah_${progress.surahNumber}', progress);

  Future<void> markAyahMemorized(int surahNumber, String surahName,
      int ayahIndex, int totalAyahs) async {
    final existing = getProgress(surahNumber);
    if (existing != null) {
      if (!existing.memorizedAyahs.contains(ayahIndex)) {
        existing.memorizedAyahs.add(ayahIndex);
        existing.lastStudied = DateTime.now();
        await existing.save();
      }
    } else {
      await saveProgress(SurahProgress(
        surahNumber: surahNumber,
        surahName: surahName,
        memorizedAyahs: [ayahIndex],
        totalAyahs: totalAyahs,
        lastStudied: DateTime.now(),
      ));
    }
  }

  List<SurahProgress> getAllProgress() => _progress.values.toList()
    ..sort((a, b) => b.lastStudied.compareTo(a.lastStudied));

  // Stats globales
  int get totalMemorizedAyahs =>
      _progress.values.fold(0, (sum, p) => sum + p.memorizedAyahs.length);

  int get totalSurahsStudied => _progress.values.length;

  // ── Favoris ───────────────────────────────────────────────────────────
  Box<FavoriteAyah> get _favorites => Hive.box<FavoriteAyah>(_favoritesBox);

  List<FavoriteAyah> getFavorites() => _favorites.values.toList()
    ..sort((a, b) => b.savedAt.compareTo(a.savedAt));

  bool isFavorite(int surahNumber, int ayahNumber) =>
      _favorites.containsKey('${surahNumber}_$ayahNumber');

  Future<void> toggleFavorite({
    required int surahNumber,
    required String surahName,
    required int ayahNumber,
    required String ayahText,
  }) async {
    final key = '${surahNumber}_$ayahNumber';
    if (_favorites.containsKey(key)) {
      await _favorites.delete(key);
    } else {
      await _favorites.put(key, FavoriteAyah(
        surahNumber: surahNumber,
        surahName: surahName,
        ayahNumber: ayahNumber,
        ayahText: ayahText,
        savedAt: DateTime.now(),
      ));
    }
  }

  // ── Sessions d'étude ──────────────────────────────────────────────────
  Box<StudySession> get _sessions => Hive.box<StudySession>(_sessionsBox);

  Future<void> saveSession(StudySession session) async {
    await _sessions.add(session);

    // Mettre à jour les stats de la sourate
    final progress = getProgress(session.surahNumber);
    if (progress != null) {
      progress.totalSessions++;
      progress.totalMinutesStudied += session.durationMinutes;
      progress.lastStudied = session.date;
      await progress.save();
    }
  }

  List<StudySession> getRecentSessions({int limit = 10}) {
    final all = _sessions.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
    return all.take(limit).toList();
  }

  // Série actuelle (jours consécutifs)
  int get currentStreak {
    final sessions = getRecentSessions(limit: 365);
    if (sessions.isEmpty) return 0;

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime checkDate = DateTime(today.year, today.month, today.day);

    for (int i = 0; i < 365; i++) {
      final hasSession = sessions.any((s) {
        final d = DateTime(s.date.year, s.date.month, s.date.day);
        return d == checkDate;
      });
      if (hasSession) {
        streak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }

  // ── Paramètres ────────────────────────────────────────────────────────
  Box<UserSettings> get _settingsBox2 => Hive.box<UserSettings>(_settingsBox);

  UserSettings getSettings() =>
      _settingsBox2.get(_settingsKey) ?? UserSettings();

  Future<void> saveSettings(UserSettings settings) =>
      _settingsBox2.put(_settingsKey, settings);
}
