import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Affiche un texte arabe avec coloration Tajwid APPROXIMATIVE.
/// Ce n'est pas un moteur Tajwid complet (qui nécessite une base de données
/// de règles validée par des spécialistes) mais une coloration indicative
/// basée sur des motifs de caractères courants, en niveaux de gris/noir
/// (différenciés par poids de police et soulignement plutôt que par
/// couleurs vives, pour rester cohérent avec la palette minimaliste).
///
/// Règles approximées :
/// - Madd (allongement) : alif/waw/yaa précédés d'une voyelle longue → gras
/// - Ghunna (noun/mim doublés ou avec shadda + tanwin) → souligné
/// - Lam shamsiya (lam suivi de lettres solaires) → italique
/// - Reste du texte → normal
class TajwidText extends StatelessWidget {
  final String text;
  final double fontSize;
  final TextAlign textAlign;
  final bool enabled;

  const TajwidText({
    super.key,
    required this.text,
    required this.fontSize,
    this.textAlign = TextAlign.right,
    this.enabled = true,
  });

  // Lettres solaires (lam shamsiya)
  static const _sunLetters = {
    'ت',
    'ث',
    'د',
    'ذ',
    'ر',
    'ز',
    'س',
    'ش',
    'ص',
    'ض',
    'ط',
    'ظ',
    'ل',
    'ن'
  };

  // Diacritiques d'allongement et tanwin
  static const _maddMarks = {'\u0670'}; // alif khanjariya
  static const _tanwinMarks = {
    '\u064B',
    '\u064C',
    '\u064D'
  }; // fatha/damma/kasra tanwin
  static const _shaddaMark = '\u0651';

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return Text(text,
          textAlign: textAlign,
          textDirection: TextDirection.rtl,
          style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: fontSize,
              color: AppTheme.textArabic,
              height: 2.0));
    }

    final spans = <TextSpan>[];
    final chars = text.runes.map((r) => String.fromCharCode(r)).toList();

    for (int i = 0; i < chars.length; i++) {
      final ch = chars[i];
      final next = i + 1 < chars.length ? chars[i + 1] : '';
      final prev = i > 0 ? chars[i - 1] : '';

      _Rule rule = _Rule.normal;

      // Tanwin -> ghunna légère (souligné fin)
      if (_tanwinMarks.contains(ch)) {
        rule = _Rule.ghunna;
      }
      // Shadda sur noun/mim -> ghunna marquée (souligné gras)
      else if (ch == _shaddaMark && (prev == 'ن' || prev == 'م')) {
        rule = _Rule.ghunnaStrong;
      }
      // Madd : alif khanjariya ou lettre madd précédée de fatha/damma/kasra longue
      else if (_maddMarks.contains(ch)) {
        rule = _Rule.madd;
      } else if ((ch == 'ا' || ch == 'و' || ch == 'ي') &&
          i > 0 &&
          _isVowel(prev)) {
        rule = _Rule.madd;
      }
      // Lam suivi d'une lettre solaire -> lam shamsiya
      else if (ch == 'ل' && _sunLetters.contains(next)) {
        rule = _Rule.shamsiya;
      }

      spans.add(_styledSpan(ch, rule));
    }

    return RichText(
      textAlign: textAlign,
      textDirection: TextDirection.rtl,
      text: TextSpan(
        style: TextStyle(
            fontFamily: 'Amiri',
            fontSize: fontSize,
            color: AppTheme.textArabic,
            height: 2.0),
        children: spans,
      ),
    );
  }

  bool _isVowel(String ch) =>
      ch == '\u064E' || ch == '\u064F' || ch == '\u0650'; // fatha, damma, kasra

  TextSpan _styledSpan(String ch, _Rule rule) {
    switch (rule) {
      case _Rule.madd:
        return TextSpan(
            text: ch,
            style: const TextStyle(
                fontWeight: FontWeight.w900, color: AppTheme.textPrimary));
      case _Rule.ghunna:
        return TextSpan(
            text: ch,
            style: const TextStyle(
                decoration: TextDecoration.underline,
                decorationColor: AppTheme.textSecondary,
                color: AppTheme.textArabic));
      case _Rule.ghunnaStrong:
        return TextSpan(
            text: ch,
            style: const TextStyle(
                decoration: TextDecoration.underline,
                decorationThickness: 2,
                decorationColor: AppTheme.textPrimary,
                fontWeight: FontWeight.w700,
                color: AppTheme.textArabic));
      case _Rule.shamsiya:
        return TextSpan(
            text: ch,
            style: const TextStyle(
                fontStyle: FontStyle.italic, color: AppTheme.textSecondary));
      case _Rule.normal:
        return TextSpan(text: ch);
    }
  }
}

enum _Rule { normal, madd, ghunna, ghunnaStrong, shamsiya }

/// Légende explicative pour l'utilisateur (à afficher dans les paramètres
/// ou un tooltip d'aide).
class TajwidLegend extends StatelessWidget {
  const TajwidLegend({super.key});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(10)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Indications Tajwid (approximatives)',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
          const SizedBox(height: 8),
          _legendRow('ا', 'Gras', 'Madd — allongement de la voyelle',
              FontWeight.w900, false),
          _legendRow('نّ', 'Souligné', 'Ghunna — résonance nasale (noun/mim)',
              FontWeight.normal, true),
          _legendRow('ل', 'Italique', 'Lam shamsiya — lam assimilé',
              FontWeight.normal, false,
              italic: true),
        ]),
      );

  Widget _legendRow(String sample, String style, String desc, FontWeight w,
          bool underline,
          {bool italic = false}) =>
      Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(children: [
            SizedBox(
                width: 36,
                child: Text(sample,
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 20,
                        fontWeight: w,
                        fontStyle: italic ? FontStyle.italic : FontStyle.normal,
                        decoration:
                            underline ? TextDecoration.underline : null))),
            const SizedBox(width: 8),
            Expanded(
                child: Text('$style — $desc',
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary))),
          ]));
}
