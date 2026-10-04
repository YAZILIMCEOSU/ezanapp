/// Türkçe metinlerde diakritik duyarsız arama ve token üretimi.
///
/// Kapsamlı bir morfoloji motoru değildir; arama/kaynak eşleştirme için
/// yeterli, hızlı ve bağımlılıksız bir yardımcıdır.
abstract final class TextNormalizer {
  static const Map<String, String> _charMap = <String, String>{
    'â': 'a', 'á': 'a', 'à': 'a', 'ä': 'a',
    'î': 'i', 'í': 'i', 'ì': 'i', 'ï': 'i',
    'û': 'u', 'ú': 'u', 'ù': 'u', 'ü': 'u',
    'ı': 'i', 'ş': 's', 'ğ': 'g', 'ö': 'o', 'ç': 'c',
    '’': '', '‘': '', '`': '', "'": '', '´': '',
    '“': ' ', '”': ' ', '"': ' ',
    '…': ' ', '–': ' ', '—': ' ',
  };

  /// Küçük harfe indirip aksanları sadeleştirir.
  static String normalize(String value) {
    final String lower = value.toLowerCase();
    final StringBuffer buffer = StringBuffer();
    for (final int rune in lower.runes) {
      final String ch = String.fromCharCode(rune);
      buffer.write(_charMap[ch] ?? ch);
    }
    return buffer.toString();
  }

  /// Normalize edilip kelimelere ayrılmış hâli (2+ harfli kelimeler).
  static List<String> tokens(String value) {
    final String normalized = normalize(value);
    final String cleaned = normalized.replaceAll(RegExp(r'[^a-z0-9\u0600-\u06ff ]'), ' ');
    return cleaned
        .split(RegExp(r'\s+'))
        .where((String token) => token.length >= 2)
        .toList(growable: false);
  }

  /// Türkçe ekleri kaba biçimde kırpar (arama için yeterli, dilbilgisel değil).
  static String stem(String token) {
    if (token.length <= 5) return token;
    for (final String suffix in _suffixes) {
      if (token.length - suffix.length >= 3 && token.endsWith(suffix)) {
        return token.substring(0, token.length - suffix.length);
      }
    }
    return token;
  }

  static const List<String> _suffixes = <String>[
    'larindan', 'lerinden', 'larini', 'lerini', 'lariyla', 'leriyle',
    'larimiz', 'lerimiz', 'mizdan', 'mizden', 'larin', 'lerin',
    'lari', 'leri', 'lardan', 'lerden', 'sini', 'yisi',
    'inin', 'unun', 'imin', 'umun', 'imiz', 'iniz',
    'dan', 'den', 'tan', 'ten', 'nin', 'nun', 'dir', 'dur', 'tir', 'tur',
    'lar', 'ler', 'si', 'im', 'in', 'iz',
    'ya', 'ye', 'da', 'de', 'ta', 'te', 'mi', 'mu',
  ];

  /// [haystack] içinde [needle] var mı (diakritik duyarsız, ek toleranslı).
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
        if (token.contains(needleToken) || needleToken.contains(token)) return true;
        return needleStem == stem(token);
      });
      if (found) hits++;
    }
    return hits >= needleTokens.length;
  }
}
