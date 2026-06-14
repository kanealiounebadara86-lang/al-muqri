import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../services/quran_api_service.dart';
import '../services/audio_service.dart';
import '../services/local_storage_service.dart';
import '../services/speech_recognition_service.dart';

final quranApiProvider = Provider<QuranApiService>((ref) => QuranApiService());

final audioServiceProvider = Provider<AudioService>((ref) {
  final s = AudioService();
  s.init();
  ref.onDispose(() => s.dispose());
  return s;
});

final localStorageProvider =
    Provider<LocalStorageService>((ref) => LocalStorageService());

// ── Sourates ──────────────────────────────────────────────────────────────
final surahsProvider = FutureProvider<List<Surah>>(
    (ref) => ref.watch(quranApiProvider).getSurahs());

final searchQueryProvider = StateProvider<String>((ref) => '');

final filteredSurahsProvider = Provider<AsyncValue<List<Surah>>>((ref) {
  final surahs = ref.watch(surahsProvider);
  final q = ref.watch(searchQueryProvider).toLowerCase();
  return surahs.whenData((list) => q.isEmpty
      ? list
      : list
          .where((s) =>
              s.nameTranslit.toLowerCase().contains(q) ||
              s.nameFr.toLowerCase().contains(q) ||
              s.number.toString().contains(q))
          .toList());
});

// ── Ayahs ─────────────────────────────────────────────────────────────────
class AyahParams {
  final int surahNumber;
  final String reciterId;
  final String translationLang;
  const AyahParams(
      {required this.surahNumber,
      this.reciterId = 'alafasy',
      this.translationLang = 'none'});
  @override
  bool operator ==(Object other) =>
      other is AyahParams &&
      other.surahNumber == surahNumber &&
      other.reciterId == reciterId &&
      other.translationLang == translationLang;
  @override
  int get hashCode =>
      surahNumber.hashCode ^ reciterId.hashCode ^ translationLang.hashCode;
}

final ayahsProvider = FutureProvider.family<List<Ayah>, AyahParams>((ref, p) =>
    ref.watch(quranApiProvider).getSurahAyahs(p.surahNumber,
        reciterId: p.reciterId, translationLang: p.translationLang));

// ── Settings ──────────────────────────────────────────────────────────────
class SettingsNotifier extends Notifier<RecitationSettings> {
  @override
  RecitationSettings build() => const RecitationSettings();
  void update(RecitationSettings s) => state = s;
  void setRepetitionsPerAyah(int v) =>
      state = state.copyWith(repetitionsPerAyah: v);
  void setRepetitionsTotal(int v) =>
      state = state.copyWith(repetitionsTotal: v);
  void setDelay(double v) => state = state.copyWith(delayBetweenAyahs: v);
  void setSpeed(double v) => state = state.copyWith(playbackSpeed: v);
  void setReciter(String v) => state = state.copyWith(reciterId: v);
  void toggleTranslation() =>
      state = state.copyWith(showTranslation: !state.showTranslation);
  void setTranslationLang(String v) =>
      state = state.copyWith(translationLang: v, showTranslation: true);
  void setFontSize(double v) => state = state.copyWith(arabicFontSize: v);
  void togglePageMode() => state = state.copyWith(pageMode: !state.pageMode);
}

final settingsProvider = NotifierProvider<SettingsNotifier, RecitationSettings>(
    SettingsNotifier.new);

// ── Thème ─────────────────────────────────────────────────────────────────
final isDarkModeProvider = StateProvider<bool>((ref) => false);

// ── Sourate sélectionnée ──────────────────────────────────────────────────
final selectedSurahProvider = StateProvider<Surah?>((ref) => null);

// ── Tab navigation ────────────────────────────────────────────────────────
final currentTabProvider = StateProvider<int>((ref) => 0);

// ── Favoris (refresh trigger) ─────────────────────────────────────────────
final favoritesRefreshProvider = StateProvider<int>((ref) => 0);

final speechRecognitionProvider = Provider<SpeechRecognitionService>((ref) {
  final service = SpeechRecognitionService();
  ref.onDispose(() => service.dispose());
  return service;
});
