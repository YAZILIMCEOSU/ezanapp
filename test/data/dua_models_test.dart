import 'package:ezanai/data/models/dua_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// Dua modeli ve katalog davranışı testleri.
///
/// İçerik sözleşmesi: her duada kaynak künyesi olmalı, kategori bilinmeli,
/// arama diakritik duyarsız çalışmalı ve paylaşım metni künyeyi içermeli.
void main() {
  Dua dua({
    String key = 'ornek',
    String name = 'Örnek Dua',
    String arabic = 'الله',
    String transliteration = 'Allâh',
    String meaning = 'Allah',
    String reference = 'Buhârî, Deavât 1',
    String category = 'gunluk',
    String? time,
  }) => Dua(
    key: key,
    name: name,
    arabic: arabic,
    transliteration: transliteration,
    meaning: meaning,
    reference: reference,
    category: category,
    time: time,
  );

  group('Dua modeli', () {
    test('JSON ayrıştırma tüm alanları okur', () {
      final Dua parsed = Dua.fromJson(<String, Object?>{
        'key': 'uyku',
        'name': 'Uyku Duası',
        'arabic': 'اللَّهُمَّ',
        'transliteration': 'Allâhümme',
        'meaning': 'Allah\'ım!',
        'reference': 'Buhârî, Deavât 7',
        'category': 'aksam',
        'time': 'Gece',
      });
      expect(parsed.key, 'uyku');
      expect(parsed.name, 'Uyku Duası');
      expect(parsed.category, 'aksam');
      expect(parsed.time, 'Gece');
      expect(parsed.hasArabic, isTrue);
    });

    test('eksik alanlar çökmez, kategori varsayılana düşer', () {
      final Dua parsed = Dua.fromJson(<String, Object?>{'key': 'x'});
      expect(parsed.category, Dua.otherCategory);
      expect(parsed.arabic, isEmpty);
      expect(parsed.hasArabic, isFalse);
      expect(parsed.time, isNull);
    });

    test('kaynak künyesi paylaşım metninde yer alır', () {
      final String text = dua(reference: 'Müslim, Zikir 75').shareText();
      expect(text, contains('Kaynak: Müslim, Zikir 75'));
      expect(text, contains('EzanAI'));
    });

    test('paylaşım metni Arapça, okunuş ve meali içerir', () {
      final String text = dua(
        arabic: 'سُبْحَانَ اللَّهِ',
        transliteration: 'Sübhânallâh',
        meaning: 'Allah\'ı tenzih ederim.',
      ).shareText();
      expect(text, contains('سُبْحَانَ اللَّهِ'));
      expect(text, contains('Sübhânallâh'));
      expect(text, contains('tenzih'));
    });

    test('Arapçası olmayan dua bile okunabilir paylaşılır', () {
      final String text = dua(arabic: '').shareText();
      expect(text.trim(), isNotEmpty);
      expect(text, contains('Kaynak:'));
    });

    test('arama diakritik ve büyük harf duyarsız', () {
      final Dua item = dua(
        name: 'Sabah Duası',
        meaning: 'Sabaha erdik, mülk de Allah\'ın oldu.',
      );
      expect(item.matches('sabah'), isTrue);
      expect(item.matches('SABAH DUASI'), isTrue);
      expect(item.matches('sabaha'), isTrue);
      expect(item.matches('mulk'), isTrue, reason: 'Aksansız yazım da bulmalı');
      expect(item.matches('aksam namazi'), isFalse);
    });

    test('künye metni de aranabilir', () {
      final Dua item = dua(reference: 'Tirmizî, Deavât 13');
      expect(item.matches('tirmizi'), isTrue);
    });
  });

  group('DuaCatalog', () {
    DuaCatalog catalog() => DuaCatalog(
      categories: const <DuaCategory>[
        DuaCategory(key: 'sabah', label: 'Sabah'),
        DuaCategory(key: 'namaz', label: 'Namaz'),
      ],
      dualar: <Dua>[
        dua(key: 'a', name: 'Sabah Duası', category: 'sabah'),
        dua(key: 'b', name: 'İlim Duası', category: 'sabah'),
        dua(key: 'c', name: 'Tahiyyât', category: 'namaz'),
      ],
    );

    test('kategoriye göre süzer', () {
      expect(catalog().byCategory('sabah').length, 2);
      expect(catalog().byCategory('namaz').length, 1);
      expect(catalog().byCategory('yok').isEmpty, isTrue);
    });

    test('boş sorgu tüm listeyi döner', () {
      expect(catalog().search('').length, 3);
      expect(catalog().search('   ').length, 3);
    });

    test('sorguya göre süzer', () {
      expect(catalog().search('tahiyyat').single.key, 'c');
      expect(catalog().search('duasi').length, 2);
      expect(catalog().search('bulunmayan').isEmpty, isTrue);
    });

    test('kimliğe göre bulur', () {
      expect(catalog().byKey('b')?.name, 'İlim Duası');
      expect(catalog().byKey('yok'), isNull);
    });

    test('boş katalog güvenli', () {
      const DuaCatalog empty = DuaCatalog(
        categories: <DuaCategory>[],
        dualar: <Dua>[],
      );
      expect(empty.isEmpty, isTrue);
      expect(empty.search('x').isEmpty, isTrue);
      expect(empty.byCategory('x').isEmpty, isTrue);
    });
  });
}
