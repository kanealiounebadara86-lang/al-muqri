import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Service hadiths — utilise l'API fawazahmed0 (GitHub Raw, CORS ouvert).
/// Deux recueils disponibles : Sahih Bukhari et Sahih Muslim, en français.
class HadithService {
  static const String _baseBukhari =
      'https://raw.githubusercontent.com/fawazahmed0/hadith-api/1/editions/fra-bukhari';
  static const String _baseMuslim =
      'https://raw.githubusercontent.com/fawazahmed0/hadith-api/1/editions/fra-muslim';

  static const int _bukhariBooks = 97;
  static const int _muslimBooks = 56;

  static final Map<String, Map<int, List<Map<String, dynamic>>>> _cache = {
    'bukhari': {},
    'muslim': {},
  };

  static String _baseFor(String collection) =>
      collection == 'muslim' ? _baseMuslim : _baseBukhari;

  static int _totalBooksFor(String collection) =>
      collection == 'muslim' ? _muslimBooks : _bukhariBooks;

  static String _labelFor(String collection) =>
      collection == 'muslim' ? 'Sahih Muslim' : 'Sahih Bukhari';

  static Future<List<Map<String, dynamic>>> fetchChapter(int book,
      {String collection = 'bukhari'}) async {
    final cache = _cache[collection]!;
    if (cache.containsKey(book)) return cache[book]!;
    try {
      final base = _baseFor(collection);
      final resp = await http.get(
        Uri.parse('$base/$book.json'),
        headers: {'User-Agent': 'ApprendreCoran/1.0'},
      ).timeout(const Duration(seconds: 15));
      if (resp.statusCode != 200) return [];
      final data = json.decode(resp.body);
      final hadiths = (data['hadiths'] as List)
          .map((h) => {
                'number': h['hadithnumber'],
                'text': h['text'] as String,
                'book': book,
                'collection': collection,
                'collectionLabel': _labelFor(collection),
              })
          .toList();
      cache[book] = hadiths;
      return hadiths;
    } catch (e) {
      debugPrint('HadithService error: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>?> randomHadith(
      {String collection = 'both'}) async {
    final rand = Random();
    final chosen = collection == 'both'
        ? (rand.nextBool() ? 'bukhari' : 'muslim')
        : collection;
    final book = rand.nextInt(_totalBooksFor(chosen)) + 1;
    final hadiths = await fetchChapter(book, collection: chosen);
    if (hadiths.isEmpty) return null;
    return hadiths[rand.nextInt(hadiths.length)];
  }

  static int totalBooks(String collection) => _totalBooksFor(collection);
  static String label(String collection) => _labelFor(collection);
}
