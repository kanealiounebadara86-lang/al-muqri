import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service hadiths — utilise l'API fawazahmed0 (GitHub Raw, CORS ouvert).
/// Bukhari en français : jusqu'à 7563 hadiths répartis en 97 chapitres.
class HadithService {
  static const _base =
      'https://raw.githubusercontent.com/fawazahmed0/hadith-api/1/editions/fra-bukhari';

  // Chapitres disponibles (1 à 97 pour Bukhari)
  static const int _totalBooks = 97;

  // Cache simple en mémoire
  static final Map<int, List<Map<String, dynamic>>> _cache = {};

  /// Charge les hadiths d'un chapitre donné.
  static Future<List<Map<String, dynamic>>> fetchChapter(int book) async {
    if (_cache.containsKey(book)) return _cache[book]!;
    try {
      final resp = await http.get(
        Uri.parse('$_base/$book.json'),
        headers: {'User-Agent': 'ApprendreCoran/1.0'},
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) return [];
      final data = json.decode(resp.body);
      final hadiths = (data['hadiths'] as List)
          .map((h) => {
                'number': h['hadithnumber'],
                'text': h['text'] as String,
                'book': book,
              })
          .toList();
      _cache[book] = hadiths;
      return hadiths;
    } catch (e) {
      debugPrint('HadithService error: $e');
      return [];
    }
  }

  /// Retourne un hadith aléatoire (choisit un chapitre aléatoire puis un hadith dedans).
  static Future<Map<String, dynamic>?> randomHadith() async {
    final rand = Random();
    final book = rand.nextInt(_totalBooks) + 1;
    final hadiths = await fetchChapter(book);
    if (hadiths.isEmpty) return null;
    return hadiths[rand.nextInt(hadiths.length)];
  }
}
