/// Türkçe metinlerde diakritik duyarsız arama, kök kırpma ve yazım hatası
/// toleranslı (fuzzy) token üretimi.
///
/// Kapsamlı bir morfoloji motoru değildir; arama ve dini bilgi tabanı
/// eşleştirmesi için hızlı ve bağımlılıksız bir yardımcıdır.
abstract final class TextNormalizer {
  static const Map<String, String> _charMap = <String, String>{
    'İ': 'i',
    'I': 'i',
    'ı': 'i',
    'Ş': 's',
    'ş': 's',
    'Ğ': 'g',
    'ğ': 'g',
    'Ü': 'u',
    'ü': 'u',
    'Ö': 'o',
    'ö': 'o',
    'Ç': 'c',
    'ç': 'c',
    'Â': 'a',
    'â': 'a',
    'á': 'a',
    'à': 'a',
    'ä': 'a',
    'Î': 'i',
    'î': 'i',
    'í': 'i',
    'ì': 'i',
    'ï': 'i',
    'Û': 'u',
    'û': 'u',
    'ú': 'u',
    'ù': 'u',
    '’': '',
    '‘': '',
    '`': '',
    "'": '',
    '´': '',
    '“': ' ',
    '”': ' ',
    '"': ' ',
    '…': ' ',
    '–': ' ',
    '—': ' ',
  };

  /// Küçük harfe indirip aksanları ve Türkçe karakterleri ASCII'ye sadeleştirir.
  ///
  /// Birleşik (combining) işaretler de atılır: kimi kaynaklarda "İ" harfi
  /// "i" + birleşik nokta olarak küçültülür ve arama bunu eşleştiremez.
  static String normalize(String value) {
    final StringBuffer pre = StringBuffer();
    for (final int rune in value.runes) {
      if (_isCombiningMark(rune)) continue;
      final String ch = String.fromCharCode(rune);
      pre.write(_charMap[ch] ?? ch);
    }
    final String lower = pre.toString().toLowerCase();
    final StringBuffer buffer = StringBuffer();
    for (final int rune in lower.runes) {
      if (_isCombiningMark(rune)) continue;
      final String ch = String.fromCharCode(rune);
      buffer.write(_charMap[ch] ?? ch);
    }
    return buffer.toString();
  }

  /// Unicode birleşik işaret aralıkları (aksan, nokta, şapka vb.).
  static bool _isCombiningMark(int rune) =>
      (rune >= 0x0300 && rune <= 0x036f) ||
      (rune >= 0x1ab0 && rune <= 0x1aff) ||
      (rune >= 0x1dc0 && rune <= 0x1dff) ||
      (rune >= 0xfe20 && rune <= 0xfe2f);

  /// Normalize edilip kelimelere ayrılmış hâli (2+ harfli kelimeler ve rakamlar).
  static List<String> tokens(String value) {
    final String normalized = normalize(value);
    final String cleaned = normalized.replaceAll(
      RegExp(r'[^a-z0-9\u0600-\u06ff ]'),
      ' ',
    );
    return cleaned
        .split(RegExp(r'\s+'))
        .where(
          (String token) =>
              token.length >= 2 || (token.length == 1 && _isDigit(token)),
        )
        .toList(growable: false);
  }

  static bool _isDigit(String s) =>
      s.codeUnitAt(0) >= 0x30 && s.codeUnitAt(0) <= 0x39;

  /// Türkçe ekleri kaba biçimde kırpar (arama için yeterli, dilbilgisel değil).
  static String stem(String token) {
    if (token.length <= 4) return token;
    for (final String suffix in _suffixes) {
      if (token.length - suffix.length >= 4 && token.endsWith(suffix)) {
        return token.substring(0, token.length - suffix.length);
      }
    }
    return token;
  }

  static const List<String> _suffixes = <String>[
    'larindan',
    'lerinden',
    'larini',
    'lerini',
    'lariyla',
    'leriyle',
    'larimiz',
    'lerimiz',
    'mizdan',
    'mizden',
    'larin',
    'lerin',
    'lari',
    'leri',
    'lardan',
    'lerden',
    'sini',
    'yisi',
    'inin',
    'unun',
    'imin',
    'umun',
    'imiz',
    'iniz',
    'ndan',
    'nden',
    'dan',
    'den',
    'tan',
    'ten',
    'nin',
    'nun',
    'dir',
    'dur',
    'tir',
    'tur',
    'lar',
    'ler',
    'si',
    'im',
    'in',
    'un',
    'iz',
    'ya',
    'ye',
    'da',
    'de',
    'ta',
    'te',
    'mi',
    'mu',
  ];

  /// İki kelime arasında en fazla 1 yazım hatası (silme, ekleme, değiştirme
  /// veya komşu iki harfin yer değiştirmesi) olup olmadığını denetler.
  ///
  /// Kısa kelimelerde (4 harften az) yanlış pozitif üretmemek için yalnızca
  /// birebir eşleşme kabul edilir.
  static bool isFuzzyTokenMatch(String a, String b) {
    if (a == b) return true;
    if (a.length < 4 || b.length < 4) return false;
    final int lenDiff = (a.length - b.length).abs();
    if (lenDiff > 1) return false;

    // İlk harf aynı olmalı ("iman" ile "islam" birbirine karışmasın).
    if (a.codeUnitAt(0) != b.codeUnitAt(0)) return false;

    if (a.length == b.length) {
      int diffs = 0;
      int firstDiff = -1;
      for (int i = 0; i < a.length; i++) {
        if (a.codeUnitAt(i) != b.codeUnitAt(i)) {
          diffs++;
          if (firstDiff == -1) {
            firstDiff = i;
          } else if (diffs == 2) {
            // Komşu iki harfin yer değiştirmesi (transposition) kontrolü:
            final bool transposed =
                i == firstDiff + 1 &&
                a.codeUnitAt(firstDiff) == b.codeUnitAt(i) &&
                a.codeUnitAt(i) == b.codeUnitAt(firstDiff);
            if (!transposed) return false;
          } else {
            return false;
          }
        }
      }
      return diffs <= 2;
    }

    // Uzunluk farkı 1: tek harf düşmesi veya eklenmesi.
    final String shorter = a.length < b.length ? a : b;
    final String longer = a.length < b.length ? b : a;
    int i = 0;
    int j = 0;
    bool skipped = false;
    while (i < shorter.length && j < longer.length) {
      if (shorter.codeUnitAt(i) == longer.codeUnitAt(j)) {
        i++;
        j++;
      } else {
        if (skipped) return false;
        skipped = true;
        j++;
      }
    }
    return true;
  }

  /// [haystack] içinde [needle] var mı (diakritik duyarsız, ek ve yazım hatası toleranslı).
  static bool matches(String haystack, String needle) {
    final String h = normalize(haystack);
    final String n = normalize(needle).trim();
    if (n.isEmpty) return false;
    if (h.contains(n)) return true;

    final List<String> haystackTokens = tokens(h);
    final List<String> needleTokens = tokens(n);
    if (needleTokens.isEmpty || haystackTokens.isEmpty) return false;

    int hits = 0;
    for (final String needleToken in needleTokens) {
      final String needleStem = stem(needleToken);
      final bool found = haystackTokens.any((String token) {
        if (token.contains(needleToken) || needleToken.contains(token)) {
          return true;
        }
        final String tokenStem = stem(token);
        if (needleStem == tokenStem) return true;
        return isFuzzyTokenMatch(needleToken, token) ||
            isFuzzyTokenMatch(needleStem, tokenStem);
      });
      if (found) hits++;
    }
    return hits >= needleTokens.length;
  }

  /// Arapça metindeki harekeleri (hareke, şedde, tenvin) kaldırır.
  ///
  /// Kur'an metninde arama yaparken hareke farklarını yok saymak için
  /// kullanılır; yazılı metin bozulmaz, yalnızca karşılaştırma sadeleşir.
  static String stripArabicDiacritics(String value) {
    return value.replaceAll(
      RegExp('[\u0610-\u061a\u064b-\u065f\u0670\u06d6-\u06ed\u0640]'),
      '',
    );
  }

  /// 0-1 arası bir alaka skorunu yüzde metnine çevirir.
  ///
  /// Arama sonuçlarında kullanıcıya "eşleşme: %80" biçiminde gösterilir.
  static String percent(double score) {
    final double clamped = score.isNaN ? 0 : score.clamp(0, 1).toDouble();
    return '%${(clamped * 100).round()}';
  }
}
