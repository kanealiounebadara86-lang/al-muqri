import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'hadith_service.dart';

/// Service de rappels — version compatible Web + Mobile sans plugin natif.
/// Stratégie : au lancement de l'app, vérifie si un rappel doit être affiché
/// (hadith du jour ou verset du jour) et l'expose via un stream.
/// Sur Android/iOS natif, on peut ajouter flutter_local_notifications
/// après `flutter pub add flutter_local_notifications`.
class NotificationService {
  static String? _todayVerse;
  static String? _todayVerseTranslation;
  static String? _todayHadith;
  static bool _checked = false;

  static const _verses = [
    (
      'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      'Au nom d\'Allah, le Tout Miséricordieux.'
    ),
    (
      'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
      'Louange à Allah, Seigneur des mondes.'
    ),
    (
      'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
      'Car avec la difficulté vient la facilité.'
    ),
    (
      'وَبَشِّرِ الصَّابِرِينَ',
      'Et annonce la bonne nouvelle à ceux qui endurent.'
    ),
    (
      'فَاذْكُرُونِي أَذْكُرْكُمْ',
      'Rappelez-vous de Moi et Je Me souviendrai de vous.'
    ),
    (
      'وَهُوَ مَعَكُمْ أَيْنَ مَا كُنتُمْ',
      'Et Il est avec vous où que vous soyez.'
    ),
    (
      'إِنَّ اللَّهَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
      'Certes, Allah est Omnipotent.'
    ),
    ('وَاللَّهُ يُحِبُّ الْمُحْسِنِينَ', 'Et Allah aime les bienfaisants.'),
    (
      'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ',
      'Allah nous suffit, et quel excellent Protecteur !'
    ),
    (
      'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً',
      'Seigneur, accorde-nous du bien en ce monde.'
    ),
    (
      'وَعَسَىٰ أَن تَكْرَهُوا شَيْئًا وَهُوَ خَيْرٌ لَّكُمْ',
      'Il se peut que vous détestiez quelque chose alors que c\'est un bien pour vous.'
    ),
    (
      'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ',
      'Allah ! Pas de divinité à part Lui, le Vivant, Celui qui subsiste par lui-même.'
    ),
    (
      'وَإِن تَعُدُّوا نِعْمَةَ اللَّهِ لَا تُحْصُوهَا',
      'Si vous comptez les bienfaits d\'Allah, vous ne pourrez les dénombrer.'
    ),
    (
      'يَا أَيُّهَا الَّذِينَ آمَنُوا اسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ',
      'Ô croyants ! Cherchez secours dans l\'endurance et la prière.'
    ),
  ];

  /// Charge le verset et hadith du jour (une seule fois par jour).
  static Future<void> checkDailyReminder() async {
    if (_checked) return;
    _checked = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final lastDay = prefs.getString('reminder_last_day') ?? '';

      final dayIndex = DateTime.now().dayOfYear % _verses.length;
      final verse = _verses[dayIndex];
      _todayVerse = verse.$1;
      _todayVerseTranslation = verse.$2;

      // Charger hadith du jour (ou depuis cache)
      if (lastDay != today) {
        await prefs.setString('reminder_last_day', today);
        final h = await HadithService.randomHadith();
        if (h != null) {
          final text = h['text'] as String;
          final truncated =
              text.length > 200 ? '${text.substring(0, 200)}...' : text;
          _todayHadith = truncated;
          await prefs.setString('reminder_hadith', truncated);
        }
      } else {
        _todayHadith = prefs.getString('reminder_hadith');
      }
    } catch (e) {
      debugPrint('NotificationService: $e');
    }
  }

  static String? get todayVerse => _todayVerse;
  static String? get todayVerseTranslation => _todayVerseTranslation;
  static String? get todayHadith => _todayHadith;

  /// Retourne un hadith aléatoire pour affichage immédiat.
  static Future<Map<String, dynamic>?> getRandomHadith() =>
      HadithService.randomHadith();
}

extension _DateTimeDay on DateTime {
  int get dayOfYear => difference(DateTime(year, 1, 1)).inDays;
}
