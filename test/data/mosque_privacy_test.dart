import 'package:ezanai/features/more/mosque_finder_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// KVKK veri minimizasyonu: cami aramasında tam koordinat gönderilmez.
void main() {
  test('Overpass sorgusu koordinatı 3 ondalığa (~110 m) yuvarlar', () {
    final String query = buildOverpassQuery(
      latitude: 41.00823456,
      longitude: 28.9784321,
    );

    expect(query.contains('41.00823456'), isFalse);
    expect(query.contains('28.9784321'), isFalse);
    expect(query.contains('around:2500,41.008,28.978'), isTrue);

    // Beş geometri türünün hepsi aynı yuvarlanmış noktayı kullanmalı.
    final Iterable<RegExpMatch> matches = RegExp(
      r'around:2500,([0-9.]+),([0-9.]+)',
    ).allMatches(query);
    expect(matches.length, 5);
    for (final RegExpMatch match in matches) {
      expect(match.group(1), '41.008');
      expect(match.group(2), '28.978');
    }
  });

  test('negatif koordinatlar da güvenli biçimde yuvarlanır', () {
    final String query = buildOverpassQuery(
      latitude: -33.8688197,
      longitude: 151.2092955,
    );

    expect(query.contains('around:2500,-33.869,151.209'), isTrue);
    expect(query.contains('-33.8688197'), isFalse);
  });
}
