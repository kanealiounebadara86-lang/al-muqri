import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

/// Cache audio local — télécharge les MP3 au premier chargement,
/// puis les joue hors ligne. Fonctionne sur Android/iOS.
/// Sur Web, retourne l'URL directe (pas de système de fichiers).
class AudioCacheService {
  static String? _cacheDir;

  static Future<String?> getCacheDir() async {
    if (kIsWeb) return null;
    _cacheDir ??=
        (await getApplicationDocumentsDirectory()).path + '/audio_cache';
    await Directory(_cacheDir!).create(recursive: true);
    return _cacheDir;
  }

  /// Retourne l'URL locale si le fichier est en cache,
  /// sinon télécharge et met en cache, puis retourne le chemin local.
  /// Sur Web, retourne l'URL distante directement.
  static Future<String> getCachedOrDownload(String url) async {
    if (kIsWeb) return url;
    try {
      final dir = await getCacheDir();
      if (dir == null) return url;
      // Nom de fichier unique basé sur l'URL
      final filename = Uri.parse(url).pathSegments.last;
      final surahPart =
          Uri.parse(url).pathSegments.where((s) => s.isNotEmpty).join('_');
      final safeName = surahPart.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final file = File('$dir/$safeName');

      if (await file.exists() && await file.length() > 1000) {
        return file.path; // Déjà en cache
      }

      // Télécharger
      final response = await http.get(Uri.parse(url), headers: {
        'User-Agent': 'ApprendreCoran/1.0'
      }).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200 && response.bodyBytes.length > 1000) {
        await file.writeAsBytes(response.bodyBytes);
        debugPrint(
            'AudioCache: saved $safeName (${response.bodyBytes.length} bytes)');
        return file.path;
      }
    } catch (e) {
      debugPrint('AudioCache error: $e');
    }
    return url; // Fallback vers URL distante
  }

  /// Vide le cache audio.
  static Future<void> clearCache() async {
    if (kIsWeb) return;
    try {
      final dir = await getCacheDir();
      if (dir == null) return;
      final directory = Directory(dir);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        await directory.create();
      }
    } catch (e) {
      debugPrint('AudioCache clearCache: $e');
    }
  }

  /// Taille du cache en Mo.
  static Future<double> getCacheSizeMB() async {
    if (kIsWeb) return 0;
    try {
      final dir = await getCacheDir();
      if (dir == null) return 0;
      final directory = Directory(dir);
      if (!await directory.exists()) return 0;
      double total = 0;
      await for (final f in directory.list()) {
        if (f is File) total += await f.length();
      }
      return total / (1024 * 1024);
    } catch (_) {
      return 0;
    }
  }
}
