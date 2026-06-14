# TODO

## Suivi
- [x] Corriger `use_build_context_synchronously` dans `lib/screens/adhan_screen.dart` (éviter empilement de listeners, guard mounted)
- [x] Corriger `avoid_types_as_parameter_names` dans `lib/screens/progress_screen.dart` (renommer `num` -> `sNum`)
- [x] Corriger `deprecated_member_use` dans `lib/screens/settings_screen.dart` (`activeThumbColor`)

## Reste
- [ ] Refaire `flutter analyze` pour confirmer qu’il ne reste plus de diagnostics Dart
- [ ] Corriger le warning Gradle `android/build.gradle.kts` (phased action / exception)

