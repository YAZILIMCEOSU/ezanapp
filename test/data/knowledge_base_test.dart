import 'package:ezanai/core/utils/text_normalizer.dart';
import 'package:ezanai/data/ai/ai_service.dart';
import 'package:ezanai/data/ai/knowledge_base.dart';
import 'package:ezanai/data/models/ai_models.dart';
import 'package:flutter_test/flutter_test.dart';

/// AI asistanın yerel bilgi tabanı denetimleri.
///
/// Amaç: içerik kalitesini ve kullanıcı sözleşmesini (kaynak gösterme, kesin
/// hüküm vermeme, mezhep farklarını belirtme) otomatik olarak korumak.
void main() {
  group('KnowledgeBase yapısı', () {
    test('en az 20 kayıt ve benzersiz kimlikler', () {
      expect(KnowledgeBase.entries.length, greaterThanOrEqualTo(20));
      final List<String> ids = KnowledgeBase.entries
          .map((KnowledgeEntry entry) => entry.id)
          .toList();
      expect(
        ids.toSet().length,
        ids.length,
        reason: 'Kimlikler benzersiz olmalı',
      );
    });

    test('her kayıtta başlık, cevap, anahtar kelime ve kaynak var', () {
      for (final KnowledgeEntry entry in KnowledgeBase.entries) {
        expect(entry.title.trim(), isNotEmpty, reason: entry.id);
        expect(entry.answer.trim().length, greaterThan(20), reason: entry.id);
        expect(entry.keywords, isNotEmpty, reason: entry.id);
        expect(
          entry.citations,
          isNotEmpty,
          reason: '${entry.id}: her cevap kaynak göstermeli',
        );
        expect(entry.category.trim(), isNotEmpty, reason: entry.id);
      }
    });

    test('anahtar kelimeler küçük harf ve ASCII (arama uyumu)', () {
      final List<String> offenders = <String>[];
      for (final KnowledgeEntry entry in KnowledgeBase.entries) {
        for (final String keyword in entry.keywords) {
          final bool asciiOnly = keyword.codeUnits.every(
            (int code) => code < 128,
          );
          if (!asciiOnly || keyword != keyword.toLowerCase()) {
            offenders.add('${entry.id}: "$keyword"');
          }
        }
      }
      expect(
        offenders,
        isEmpty,
        reason:
            'Anahtar kelimeler normalleştirilmiş olmalı:\n${offenders.join('\n')}',
      );
    });

    test('anahtar kelimeler yeterince ayırt edici', () {
      for (final KnowledgeEntry entry in KnowledgeBase.entries) {
        for (final String keyword in entry.keywords) {
          expect(
            keyword.trim().length,
            greaterThanOrEqualTo(3),
            reason: entry.id,
          );
        }
      }
    });

    test('ilişkili kayıt kimlikleri geçerli', () {
      final Set<String> ids = KnowledgeBase.entries
          .map((KnowledgeEntry entry) => entry.id)
          .toSet();
      for (final KnowledgeEntry entry in KnowledgeBase.entries) {
        for (final String related in entry.related) {
          expect(
            ids.contains(related),
            isTrue,
            reason: '${entry.id} → bilinmeyen kayıt: $related',
          );
        }
      }
    });

    test('mezhep farkı notları en az birkaç kayıtta bulunur', () {
      final int withNotes = KnowledgeBase.entries
          .where((KnowledgeEntry entry) => entry.madhabNotes.isNotEmpty)
          .length;
      expect(withNotes, greaterThanOrEqualTo(5));
    });

    test('kaynak künyeleri kaynak türüne ayrılabiliyor', () {
      final RegExp kuran = RegExp(r'^Kur');
      int quran = 0;
      int hadith = 0;
      for (final KnowledgeEntry entry in KnowledgeBase.entries) {
        for (final String citation in entry.citations) {
          if (kuran.hasMatch(citation)) {
            quran++;
          } else if (citation.contains('Buhârî') ||
              citation.contains('Müslim') ||
              citation.contains('Tirmizî')) {
            hadith++;
          }
        }
      }
      expect(quran, greaterThan(0), reason: 'Kur\'an kaynaklı künyeler olmalı');
      expect(hadith, greaterThan(0), reason: 'Hadis kaynaklı künyeler olmalı');
    });
  });

  group('LocalKnowledgeSource eşleştirmesi', () {
    final LocalKnowledgeSource source = LocalKnowledgeSource();

    void expectTopic(String question, String expectedId) {
      final AiAnswer? answer = source.answer(question);
      expect(answer, isNotNull, reason: 'Eşleşme bulunamadı: "$question"');
      final KnowledgeEntry entry = KnowledgeBase.entries.firstWhere(
        (KnowledgeEntry candidate) => candidate.title == answer!.topic,
      );
      expect(entry.id, expectedId, reason: '"$question"');
    }

    test('namaz rekatı sorusu doğru kayda gider', () {
      expectTopic('Vakit namazları kaç rekattır?', 'namaz_rekat');
    });

    test('abdest sorusu doğru kayda gider', () {
      expectTopic('Abdest nasıl alınır?', 'abdest');
    });

    test('zekât sorusu doğru kayda gider', () {
      expectTopic('Zekât oranı nedir, nisab ne demek?', 'zekat');
    });

    test('kıble sorusu doğru kayda gider', () {
      expectTopic('Kıble yönünü nasıl bulurum?', 'kible');
    });

    test('Türkçe karakter ve büyük harf farkı eşleşmeyi bozmaz', () {
      expectTopic('KIBLE YÖNÜ NASIL BULUNUR', 'kible');
      expectTopic('orucu bozan seyler nelerdir', 'oruc_bozan');
    });

    test('her yerel cevap kaynak, uyarı ve mezhep bilgisi taşır', () {
      final List<String> questions = <String>[
        'Abdest nasıl alınır?',
        'Orucu bozan şeyler nelerdir?',
        'Zekât oranı nedir?',
        'Cuma namazı hangi şartlarda farzdır?',
        'Kıble yönünü nasıl bulurum?',
      ];
      for (final String question in questions) {
        final AiAnswer? answer = source.answer(question);
        expect(answer, isNotNull, reason: question);
        expect(answer!.hasSources, isTrue, reason: question);
        expect(answer.mode, AiAnswerMode.offline);
        expect(answer.disclaimer, contains('kesin'), reason: question);
        expect(answer.disclaimer, contains('müftülüğe'), reason: question);
        expect(answer.text.trim(), isNotEmpty, reason: question);
      }
    });

    test('konu kelimesi genel kelimelere üstün gelir (vitir/teravih)', () {
      expectTopic('Vitir namazı kaç rekattır?', 'vitir_teravih');
      expectTopic('Teravih namazı kaç rekâttır?', 'vitir_teravih');
      expectTopic('Vitir namazı kaç rekât?', 'vitir_teravih');
    });

    test('ayırt edici kelime puanı, genel kelimelerden yüksektir', () {
      final String question = TextNormalizer.normalize(
        'Vitir namazı kaç rekattır?',
      );
      final List<String> tokens = TextNormalizer.tokens(question);
      final Set<String> tokenSet = tokens.toSet();
      final Set<String> stemSet = tokens.map(TextNormalizer.stem).toSet();

      KnowledgeEntry entryOf(String id) => KnowledgeBase.entries.firstWhere(
        (KnowledgeEntry entry) => entry.id == id,
      );

      final double vitir = LocalKnowledgeSource.scoreEntry(
        entryOf('vitir_teravih'),
        question,
        tokenSet,
        stemSet,
      );
      final double genel = LocalKnowledgeSource.scoreEntry(
        entryOf('namaz_rekat'),
        question,
        tokenSet,
        stemSet,
      );

      expect(vitir, greaterThan(genel));
      expect(vitir, greaterThan(LocalKnowledgeSource.minimumScore));
    });

    test('harf düşmesi olan sorular da eşleşir (hatim → hatmi)', () {
      expectTopic('Kur an hatmi nasıl yapılır?', 'hatim');
    });

    test('Kâbe yönü sorusu kıble kaydına gider', () {
      expectTopic('Kâbe hangi yönde?', 'kible');
      expectTopic('Namazda kıble şartı nedir?', 'kible');
    });

    test('önerilen sorular kimlik değil, okunabilir başlık olarak döner', () {
      final Set<String> titles = KnowledgeBase.entries
          .map((KnowledgeEntry entry) => entry.title)
          .toSet();
      final List<String> questions = <String>[
        'Cuma namazı hangi şartlarda farzdır?',
        'Abdest nasıl alınır?',
        'Zekât oranı nedir?',
      ];
      for (final String question in questions) {
        final AiAnswer? answer = source.answer(question);
        expect(answer, isNotNull, reason: question);
        expect(answer!.relatedQuestions, isNotEmpty, reason: question);
        for (final String related in answer.relatedQuestions) {
          expect(
            titles.contains(related),
            isTrue,
            reason: '"$question" → geçersiz öneri: $related',
          );
          expect(related.contains('_'), isFalse, reason: related);
        }
      }
    });

    test('kayda uymayan soru için uydurma cevap üretilmez', () {
      for (final String question in <String>[
        'zzz qqq xxx',
        'Bugün hava nasıl olacak acaba?',
        'Fenerbahçe maçı saat kaçta?',
        'Python nasıl öğrenilir?',
        'film önerisi ver',
      ]) {
        expect(
          source.answer(question),
          isNull,
          reason: 'Bilgi tabanı dışı soruya cevap verilmemeli: "$question"',
        );
      }
    });

    test('soru boşsa eşleşme yapılmaz', () {
      expect(source.answer('   '), isNull);
      expect(source.answer(''), isNull);
    });

    test('paylaşım metni kaynakları ve mezhep notlarını içerir', () {
      final AiAnswer? answer = source.answer(
        'Kadınlara özel hallerde ibadet nasıl olur?',
      );
      expect(answer, isNotNull);
      final String share = answer!.shareText();
      expect(share, contains('Kaynak'));
      expect(TextNormalizer.normalize(share), contains('kaynak'));
    });

    test('İslam\'ın şartları sorusuna beş şartı doğru sırayla ve kaynaklı cevaplar', () {
      for (final String variant in <String>[
        'İslam\'ın şartları nelerdir?',
        'ISLAMIN SARTLARI NELERDIR',
        'ıslamın 5 şartı nedir',
        'islamn sartlari neler',
        'İslam şartları kaç tanedir?',
      ]) {
        final AiAnswer? answer = source.answer(variant);
        expect(answer, isNotNull, reason: variant);
        expect(answer!.isVerifiedLocal, isTrue, reason: variant);
        expect(answer.hasSources, isTrue, reason: variant);

        final String text = TextNormalizer.normalize(answer.text);
        final int i1 = text.indexOf('sehadet');
        final int i2 = text.indexOf('namaz kilmak');
        final int i3 = text.indexOf('zekat vermek');
        final int i4 = text.indexOf('ramazan orucu');
        final int i5 = text.indexOf('hacca gitmek');

        expect(i1, greaterThanOrEqualTo(0), reason: variant);
        expect(i2, greaterThan(i1), reason: '2. sırada namaz olmalı: $variant');
        expect(i3, greaterThan(i2), reason: '3. sırada zekât olmalı: $variant');
        expect(i4, greaterThan(i3), reason: '4. sırada oruç olmalı: $variant');
        expect(i5, greaterThan(i4), reason: '5. sırada hac olmalı: $variant');
        expect(
          answer.sources.any((AiSource s) => s.detail != null),
          isTrue,
          reason: 'Kaynak bölüm bilgisi içermeli',
        );
      }
    });

    test('İmanın şartları sorusuna altı iman esasını doğru sırayla ve kaynaklı cevaplar', () {
      for (final String variant in <String>[
        'İmanın şartları nelerdir?',
        'İMANIN ŞARTLARI NELERDİR',
        'imanin 6 sarti nedir',
        'imann sartlari nelerdir',
        'iman esaslari nelerdir',
        'Âmentü esasları nelerdir?',
      ]) {
        final AiAnswer? answer = source.answer(variant);
        expect(answer, isNotNull, reason: variant);
        expect(answer!.isVerifiedLocal, isTrue, reason: variant);
        expect(answer.hasSources, isTrue, reason: variant);

        final String text = TextNormalizer.normalize(answer.text);
        final int i1 = text.indexOf('allaha iman');
        final int i2 = text.indexOf('meleklere iman');
        final int i3 = text.indexOf('kitaplara iman');
        final int i4 = text.indexOf('peygamberlere iman');
        final int i5 = text.indexOf('ahiret gunune iman');
        final int i6 = text.indexOf('kader ve kazaya');

        expect(i1, greaterThanOrEqualTo(0), reason: variant);
        expect(
          i2,
          greaterThan(i1),
          reason: '2. sırada melekler olmalı: $variant',
        );
        expect(
          i3,
          greaterThan(i2),
          reason: '3. sırada kitaplar olmalı: $variant',
        );
        expect(
          i4,
          greaterThan(i3),
          reason: '4. sırada peygamberler olmalı: $variant',
        );
        expect(
          i5,
          greaterThan(i4),
          reason: '5. sırada âhiret olmalı: $variant',
        );
        expect(
          i6,
          greaterThan(i5),
          reason: '6. sırada kader ve kazâ olmalı: $variant',
        );
      }
    });

    test('birleşik sorularda RAG yaklaşımıyla her iki doğrulanmış kayıt birleştirilir', () {
      final AiAnswer? combined = source.answer(
        'İslam\'ın şartları ve imanın şartları nelerdir?',
      );
      expect(combined, isNotNull);
      final String text = TextNormalizer.normalize(combined!.text);
      expect(text, contains('sehadet'));
      expect(text, contains('meleklere iman'));
      expect(combined.sources.length, greaterThanOrEqualTo(4));
    });
  });
}
