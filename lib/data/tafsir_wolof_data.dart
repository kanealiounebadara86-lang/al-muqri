/// Tafsir audio en wolof par Assane Sarr (2008), hébergé sur Internet Archive.
/// Couvre les sourates 48 à 114 uniquement (source libre la plus complète trouvée).
/// Ce n'est pas une traduction verset par verset mais une explication par sourate.
const String _base = 'https://archive.org/download/TafsirAssaneSarr';

const Map<int, String> kTafsirWolofUrls = {
  48: '$_base/048_al-fath.mp3',
  49: '$_base/049_al-hujurat.mp3',
  50: '$_base/050_qaf.mp3',
  51: '$_base/051_adh-dhariyat.mp3',
  52: '$_base/052_at-tur.mp3',
  54: '$_base/054_al-qamar.mp3',
  55: '$_base/055_ar-rahman.mp3',
  56: '$_base/056_al-waqiah.mp3',
  57: '$_base/057_al-hadid.mp3',
  58: '$_base/058_almujadilah.mp3',
  59: '$_base/059_al-harsh.mp3',
  60: '$_base/060_al-mumtanaah.mp3',
  61: '$_base/061_as-saff.mp3',
  62: '$_base/062_al-jumuah.mp3',
  63: '$_base/063_al-munafiqun.mp3',
  64: '$_base/064_at-taghabun.mp3',
  65: '$_base/065_at-talaq.mp3',
  66: '$_base/066_at-tahrim.mp3',
  67: '$_base/067_al-mulk.mp3',
  68: '$_base/068_al-qalam.mp3',
  69: '$_base/069_al-haqqah.mp3',
  70: '$_base/070_al-maarij.mp3',
  73: '$_base/073_al-muzammil.mp3',
  78: '$_base/078_an-naba.mp3',
  79: '$_base/079_an-naziat.mp3',
  80: '$_base/080_abasa.mp3',
  81: '$_base/081_at-takwir.mp3',
  82: '$_base/082_al-infitar.mp3',
  83: '$_base/083_al-mutaffifin.mp3',
  84: '$_base/084_al-inshiqaq.mp3',
  85: '$_base/085_al-buruj.mp3',
  86: '$_base/086_at-tariq.mp3',
  87: '$_base/087_al-ala.mp3',
  88: '$_base/088_al-ghashiya.mp3',
  89: '$_base/089_al-fajr.mp3',
  90: '$_base/090_al-balad.mp3',
  91: '$_base/091_ash-shams.mp3',
  92: '$_base/092_al-lail.mp3',
  93: '$_base/093_ad-duha.mp3',
  94: '$_base/094_ash-sharh.mp3',
  95: '$_base/095_at-tin.mp3',
  96: '$_base/096_al-alaq.mp3',
  97: '$_base/097_al-qadr.mp3',
  98: '$_base/098_al-baiyyinah.mp3',
  99: '$_base/099_az-zalzalah.mp3',
  100: '$_base/100_al-adiyat.mp3',
  101: '$_base/101_al-qariha.mp3',
  102: '$_base/102_at-takathur.mp3',
  103: '$_base/103_al-asr.mp3',
  104: '$_base/104_al-humaza.mp3',
  105: '$_base/105_al-fil.mp3',
  106: '$_base/106_al-quraish.mp3',
  107: '$_base/107_al-maun.mp3',
  108: '$_base/108_al-kauthar.mp3',
  109: '$_base/109_al-kafirun.mp3',
  110: '$_base/110_an-nasr.mp3',
  111: '$_base/111_al-masad.mp3',
  112: '$_base/112_al-ikhlas.mp3',
  113: '$_base/113_al-falaq.mp3',
  114: '$_base/114_an-nas.mp3',
};

/// Retourne l'URL du tafsir wolof pour une sourate, ou null si indisponible.
String? tafsirWolofUrl(int surahNumber) => kTafsirWolofUrls[surahNumber];

/// Indique si le tafsir wolof est disponible pour cette sourate.
bool hasTafsirWolof(int surahNumber) =>
    kTafsirWolofUrls.containsKey(surahNumber);
