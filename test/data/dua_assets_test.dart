import 'dart:convert';
import 'dart:io';

import 'package:ezanai/data/models/dua_models.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Gömülü dua içeriğinin içerik sözleşmesi testleri.
///
/// `assets/data/adhkar/adhkar.json` içindeki her dua; künye, kategori, okunuş
/// ve meal alanlarını taşımak zorundadır. Böylece içerik eklerken kaynaksız ya
/// da bozuk kayıt yayına giremez.
void main() {
  late Map<String, Object?> json;

  setUpAll(() async {
    // Test ortamında rootBundle her zaman okunamayabilir; dosyaya düşülür
    // (bkz. test/prayer_calculation_test.dart ile aynı desen).
    try {
      final String raw = await rootBundle.loadString(
        'assets/data/adhkar/adhkar.json',
      );
      json = (jsonDecode(raw) as Map).cast<String, Object?>();
    } catch (_) {
      final String raw = File('assets/data/adhkar/adhkar.json')
          .readAsStringSync();
      json = (jsonDecode(raw) as Map).cast<String, Object?>();
    }
  });

  List<Map<String, Object?>> rawDualar() =>
      ((json['dualar'] as List?) ?? <Object?>[])
          .whereType<Map<Object?, Object?>>()
          .map((Map<Object?, Object?> m) => m.cast<String, Object?>())
          .toList();

  List<Dua> dualar() => rawDualar().map(Dua.fromJson).toList();

  test('kategoriler tanımlı ve benzersiz', () {
    final List<Object?> raw = (json['dua_categories'] as List?) ?? <Object?>[];
    expect(raw, isNotEmpty, reason: 'dua_categories tanımlı olmalı');
    final List<DuaCategory> categories = raw
        .whereType<Map<Object?, Object?>>()
        .map(
          (Map<Object?, Object?> m) =>
              DuaCategory.fromJson(m.cast<String, Object?>()),
        )
        .toList();
    expect(categories.length, greaterThanOrEqualTo(6));
    for (final DuaCategory category in categories) {
      expect(category.key.trim(), isNotEmpty);
      expect(category.label.trim(), isNotEmpty);
    }
    expect(
      categories.map((DuaCategory c) => c.key).toSet().length,
      categories.length,
      reason: 'Kategori kimlikleri benzersiz olmalı',
    );
  });

  test('en az 30 dua var ve kimlikler benzersiz', () {
    final List<Dua> items = dualar();
    expect(items.length, greaterThanOrEqualTo(30));
    final Set<String> keys = items.map((Dua dua) => dua.key).toSet();
    expect(
      keys.length,
      items.length,
      reason: 'Dua kimlikleri benzersiz olmalı',
    );
    expect(keys.every((String key) => key.trim().isNotEmpty), isTrue);
  });

  test('her duada ad, okunuş, meal ve kategori dolu', () {
    for (final Dua dua in dualar()) {
      expect(dua.name.trim(), isNotEmpty, reason: dua.key);
      expect(
        dua.transliteration.trim(),
        isNotEmpty,
        reason: '${dua.key}: okunuş boş olamaz',
      );
      expect(
        dua.meaning.trim(),
        isNotEmpty,
        reason: '${dua.key}: meal/anlam boş olamaz',
      );
      expect(
        dua.category.trim(),
        isNotEmpty,
        reason: '${dua.key}: kategori boş olamaz',
      );
    }
  });

  test('her duada kaynak künyesi var', () {
    for (final Dua dua in dualar()) {
      expect(
        dua.reference.trim(),
        isNotEmpty,
        reason: '${dua.key}: kaynak künyesi zorunlu',
      );
    }
  });

  test('kaynak künyeleri ya Kur\'an ya muteber hadis kaynağına dayanır', () {
    const List<String> kabul = <String>[
      'Kur\'an',
      'Buhârî',
      'Müslim',
      'Tirmizî',
      'Ebû Dâvûd',
      'Nesâî',
      'İbn Mâce',
      'Dârimî',
      'Taberânî',
      'Ahmed b. Hanbel',
    ];
    for (final Dua dua in dualar()) {
      final bool taniniyor = kabul.any(
        (String kaynak) => dua.reference.contains(kaynak),
      );
      expect(
        taniniyor,
        isTrue,
        reason: '${dua.key}: tanınmayan kaynak → ${dua.reference}',
      );
    }
  });

  test('her duanın kategorisi kategori listesinde tanımlı', () {
    final Set<String> tanimli =
        (((json['dua_categories'] as List?) ?? <Object?>[])
                .whereType<Map<Object?, Object?>>()
                .map((Map<Object?, Object?> m) => m['key'].toString()))
            .toSet();
    for (final Dua dua in dualar()) {
      expect(
        tanimli.contains(dua.category),
        isTrue,
        reason: '${dua.key}: tanımsız kategori → ${dua.category}',
      );
    }
  });

  test('her kategoride en az bir dua var (boş sekme olmasın)', () {
    final List<Dua> items = dualar();
    for (final Object? entry
        in (json['dua_categories'] as List?) ?? <Object?>[]) {
      if (entry is! Map) continue;
      final String key = entry['key'].toString();
      final int count = items.where((Dua dua) => dua.category == key).length;
      expect(count, greaterThan(0), reason: 'Kategori boş: $key');
    }
  });

  test('Kur\'an kaynaklı duaların künyesi sure/ayet içerir', () {
    final List<Dua> kuran = dualar()
        .where((Dua dua) => dua.category == 'kuran')
        .toList();
    expect(kuran, isNotEmpty);
    for (final Dua dua in kuran) {
      expect(
        RegExp(r'\d+/\d+').hasMatch(dua.reference),
        isTrue,
        reason: '${dua.key}: sure/ayet belirtilmeli → ${dua.reference}',
      );
    }
  });

  test('Arapça metin içeren dualar Arapça alfabede', () {
    final RegExp arabic = RegExp(r'[\u0600-\u06ff]');
    for (final Dua dua in dualar()) {
      if (!dua.hasArabic) continue;
      expect(
        arabic.hasMatch(dua.arabic),
        isTrue,
        reason: '${dua.key}: Arapça alan beklenen alfabede değil',
      );
    }
  });

  test('katalogda arama ve kategori süzme çalışıyor', () {
    final DuaCatalog catalog = DuaCatalog(
      categories:
          (((json['dua_categories'] as List?) ?? <Object?>[])
                  .whereType<Map<Object?, Object?>>()
                  .map(
                    (Map<Object?, Object?> m) =>
                        DuaCategory.fromJson(m.cast<String, Object?>()),
                  ))
              .toList(),
      dualar: dualar(),
    );
    expect(catalog.byCategory('sabah'), isNotEmpty);
    expect(catalog.search('sabah'), isNotEmpty);
    expect(catalog.search('zekat orani'), isEmpty);
    expect(catalog.byKey(catalog.dualar.first.key), isNotNull);
  });
}
