class LessonStrings {
  static const String title = "Panimula sa Wikang Cuyonon";
  static const String introductionTitle = 'Panimula';
  static const String introductionText =
      'Ang alpabhet ng Cuyonon ay mayroong 20 letra: '
      'a, b, d, e, g, h, i, k, m, n, o, p, r, s, t, w, '
      'y, ng at \' (tuldok-kuwit). Pakisuyo na tandaan '
      'na ang \'ng\' ay isang salita.';

  static const String consonantsTitle =
      'Mga Katinig - narito ang 16 na katinig, kasama ang mga halimbawa:';

  static const String vowelsTitle = 'Mga Patinig - Narito ang 6 na patinig:';
  static const List<String> vowelsList = [
    'a - (Ito ay matatagpuan lamang sa mga anyong may panlapi) Hal. nagaadal',
    'e - kaen, baeg, bael, laem',
    'i - babai, bait',
    'o - kot-kot, onod, bok, oto',
  ];

  static const String clustersTitle = 'Mga Klaster ng Patinig';
  static const List<String> clustersList = [
    'ae - (mga anyong may panlapi) Hal. karakean, te\'mean',
    'ai - (mga anyong may panlapi) Hal. karakean, te\'mean',
    'ao - laod, bao, daon, kaoy, baog',
    'ia - siak, biak, bagiaw, liabi',
    'ie - piet, lieg, sied',
    'io - tio, limpio, liolio',
    'oa - boat, loa, boawi',
    'oi - dispois, noibi, koilio, doindi, boin',
  ];

  static String getVowelsText() {
    return vowelsList.join('\n\n');
  }

  static String getClustersText() {
    return clustersList.join('\n\n');
  }

  static String getConsonantsText() {
    return consonantsExamples.join('\n\n');
  }

  static const String glottalStopTitle =
      'Glottal Stop o pahinga sa lalamunan/bibig';
  static const String glottalStopText =
      'Ito ay isang pagkahinto sa lalamunan na karaniwan sa Cuyonon, '
      'na nagdudulot ng maikling paghinto. '
      'Maaaring lumabas ito sa simula ng mga salita na '
      'nagsisimula sa patinig, sa gitna ng mga salita, at sa dulo '
      'ng mga salita pagkatapos ng patinig o kumbinasyon ng mga patinig.';

  static const String glottalStopExamples =
      '- be\'ras, be\'na, te\'me, to\'bol';

  static const List<String> consonantsExamples = [
    'b - baboy, babai, boawi, lobiok, koyab, boi',
    'd - doto, kadkad, doadoa, Dios, dadi',
    'g - gusto, dagat, goapo, bagiaw, libag',
    'h - irihis, kahil, bihon, sotanghon',
    'k - kawayan, bakawan, koago, bakia, apok',
    'p - paray, apat, teptep, poas, mapiet, akep',
    'r - rabotrabot, rokrok, tanggar, riabriab, barot, piar',
    's - sarok, boslit, tabas, soay, siansi, baras',
    't - todlo, litson, litgi, toak, tian, paragt, toad',
    'w - way, way-way, bo\'w, kawil, kawil-kawil, karabaw',
    'y - yaya, ayat, cayab, sa\'t',
    'ng - ngiti, bayang, ngamal, sangkal, ngang',
  ];
}
