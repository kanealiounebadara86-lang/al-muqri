import 'package:go_router/go_router.dart';
import 'screens/splash_screen.dart';
import 'screens/main_scaffold.dart';
import 'screens/player_screen.dart';
import 'screens/recitation_setup_screen.dart';
import 'screens/speech_to_text_screen.dart';
import 'screens/adhan_screen.dart';
import 'screens/hadith_screen.dart';
import 'screens/tasbih_screen.dart';
import 'screens/names_screen.dart';
import 'screens/duas_screen.dart';
import 'screens/settings_screen.dart';

/// Routes essentielles — app simplifiée style Al-Muqri.
final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (c, s) => const SplashScreen()),
    GoRoute(path: '/home', builder: (c, s) => const MainScaffold()),
    GoRoute(path: '/setup', builder: (c, s) => const RecitationSetupScreen()),
    GoRoute(
        path: '/surah/:number',
        builder: (c, s) {
          final start = s.uri.queryParameters['start'];
          final end = s.uri.queryParameters['end'];
          return PlayerScreen(
            surahNumber: int.parse(s.pathParameters['number']!),
            initialStart: start != null ? int.parse(start) : null,
            initialEnd: end != null ? int.parse(end) : null,
          );
        }),
    GoRoute(
        path: '/speech/:surah/:ayah',
        builder: (c, s) => SpeechToTextScreen(
              surahNumber: int.parse(s.pathParameters['surah']!),
              ayahNumber: int.parse(s.pathParameters['ayah']!),
            )),
    GoRoute(path: '/adhan', builder: (c, s) => const AdhanScreen()),
    GoRoute(path: '/hadiths', builder: (c, s) => const HadithScreen()),
    GoRoute(path: '/tasbih', builder: (c, s) => const TasbihScreen()),
    GoRoute(path: '/duas', builder: (c, s) => const DuasScreen()),
    GoRoute(path: '/names', builder: (c, s) => const NamesScreen()),
    GoRoute(path: '/settings', builder: (c, s) => const SettingsScreen()),
  ],
);
