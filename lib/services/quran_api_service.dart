import 'package:dio/dio.dart';
import '../models/models.dart';
import '../data/surahs_data.dart';
import '../data/fatiha_data.dart';

class QuranApiService {
  static const String _api = 'https://api.alquran.cloud/v1';

  // URLs audio avec CORS proxy pour Flutter Web
  // everyayah.com fonctionne sur Android/iOS mais pas sur Flutter Web (CORS)
  // Solution: utiliser le CDN islamic.network qui a les headers CORS
  static const String _audioCdn = 'https://cdn.islamic.network/quran/audio/128';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
  ));

  Future<List<Surah>> getSurahs() async => kSurahsData
      .map((e) => Surah(
            number: e['number'],
            nameArabic: e['name'],
            nameTranslit: e['translit'],
            nameFr: e['fr'],
            totalAyahs: e['ayahs'],
            revelationType: e['type'],
          ))
      .toList();

  Future<List<Ayah>> getSurahAyahs(
    int surahNumber, {
    String reciterId = 'alafasy',
    String translationLang = 'none',
  }) async {
    if (surahNumber == 1) return _fatiha(reciterId, translationLang);
    try {
      final ar = await _dio.get('$_api/surah/$surahNumber/ar.quran-uthmani');
      final List ayahs = ar.data['data']['ayahs'];

      List? fr;
      List? en;
      if (translationLang == 'fr') {
        try {
          final r = await _dio.get('$_api/surah/$surahNumber/fr.hamidullah');
          fr = r.data['data']['ayahs'];
        } catch (_) {}
      }
      if (translationLang == 'en') {
        try {
          final r = await _dio.get('$_api/surah/$surahNumber/en.sahih');
          en = r.data['data']['ayahs'];
        } catch (_) {}
      }

      return ayahs
          .asMap()
          .entries
          .map((e) => Ayah(
                number: e.value['number'],
                numberInSurah: e.value['numberInSurah'],
                text: e.value['text'],
                translationFr: fr != null ? fr[e.key]['text'] : null,
                translationEn: en != null ? en[e.key]['text'] : null,
                surahNumber: surahNumber,
                audioUrl: getAudioUrlBySurah(
                    surahNumber, e.value['numberInSurah'], reciterId),
              ))
          .toList();
    } catch (_) {
      return _fallback(surahNumber, reciterId);
    }
  }

  List<Ayah> _fatiha(String reciterId, String lang) => kFatihaTranslations
      .map((a) => Ayah(
            number: a.number,
            numberInSurah: a.number,
            text: a.arabic,
            translationFr: a.french,
            translationEn: a.english,
            translationWo: a.wolof,
            surahNumber: 1,
            audioUrl: getAudioUrlBySurah(1, a.number, reciterId),
          ))
      .toList();

  List<Ayah> _fallback(int surahNumber, String reciterId) {
    final s = kSurahsData.firstWhere((s) => s['number'] == surahNumber);
    return List.generate(
        s['ayahs'],
        (i) => Ayah(
              number: i + 1,
              numberInSurah: i + 1,
              text: 'يَتَطَلَّبُ اتِّصَالاً بِالإِنْتَرْنِت',
              surahNumber: surahNumber,
              audioUrl: getAudioUrlBySurah(surahNumber, i + 1, reciterId),
            ));
  }

  // ── URL Audio avec DEUX sources (fallback automatique) ────────────────
  String getAudioUrlBySurah(
      int surahNumber, int ayahInSurah, String reciterId) {
    // Source principale: cdn.islamic.network (CORS ouvert ✅)
    final edition = _islamicNetworkEdition(reciterId);
    // Calculer le numéro global de l'ayah
    final globalAyah = _globalAyahNumber(surahNumber, ayahInSurah);
    return '$_audioCdn/$edition/$globalAyah.mp3';
  }

  // URL secondaire: everyayah.com (marche sur Android/iOS, pas Web)
  String getEveryayahUrl(int surahNumber, int ayahInSurah, String reciterId) {
    final s = surahNumber.toString().padLeft(3, '0');
    final a = ayahInSurah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/${_everyayahCode(reciterId)}/$s$a.mp3';
  }

  // Liste complète d'une sourate pour lecture continue
  List<String> getSurahAudioUrls(int surahNumber, String reciterId) {
    final surah = kSurahsData.firstWhere((s) => s['number'] == surahNumber);
    final totalAyahs = surah['ayahs'] as int;
    return List.generate(
        totalAyahs, (i) => getAudioUrlBySurah(surahNumber, i + 1, reciterId));
  }

  // Calcul numéro global d'un verset
  int _globalAyahNumber(int surahNumber, int ayahInSurah) {
    int count = 0;
    for (final s in kSurahsData) {
      if (s['number'] == surahNumber) return count + ayahInSurah;
      count += s['ayahs'] as int;
    }
    return ayahInSurah;
  }

  // Identifiants islamic.network (CORS ouvert, fonctionne sur Web)
  String _islamicNetworkEdition(String reciterId) {
    const map = {
      'alafasy': 'ar.alafasy',
      'sudais': 'ar.abdurrahmaansudais', // ✅ Vérifié
      'shuraim': 'ar.saoodshuraym', // ✅ Vérifié
      'husary': 'ar.husary', // ✅ Vérifié
      'minshawi': 'ar.minshawi', // ✅ Vérifié
      'basit_murattal': 'ar.abdulbasitmurattal',
      // Récitateurs non vérifiés sur ce CDN -> fallback Alafasy pour éviter audio cassé
      'basit_mujawwad': 'ar.alafasy',
      'ghamdi': 'ar.alafasy',
      'shaatree': 'ar.alafasy',
      'ajamy': 'ar.alafasy',
      'tablawi': 'ar.alafasy',
    };
    return map[reciterId] ?? 'ar.alafasy';
  }

  // Codes everyayah (pour Android/iOS)
  String _everyayahCode(String id) {
    const map = {
      'alafasy': 'Alafasy_128kbps',
      'sudais': 'Abdurrahmaan_As-Sudais_192kbps',
      'shuraim': 'Saud_ash-Shuraym_128kbps',
      'husary': 'Husary_128kbps',
      'basit_murattal': 'Abdul_Basit_Murattal_192kbps',
      'basit_mujawwad': 'Abdul_Basit_Mujawwad_128kbps',
      'minshawi': 'Minshawy_Murattal_128kbps',
      'ghamdi': 'Saad_Al-Ghamdi_128kbps',
      'shaatree': 'Abu_Bakr_Ash-Shaatree_128kbps',
      'ajamy': 'Ahmad_ibn_Ali_al-Ajamy_128kbps_ketaballah',
      'tablawi': 'Mohammad_al_Tablawi_128kbps',
    };
    return map[id] ?? 'Alafasy_128kbps';
  }
}
