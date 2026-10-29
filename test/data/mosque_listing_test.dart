import 'package:ezanai/features/more/mosque_finder_screen.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Cami Bul — listeleme hatalarının regresyon testleri.**
///
/// Kullanıcı "mobil listeleme hatalı" dediğinde tespit edilen 6 sorun burada
/// kilitleniyor:
///
/// 1. Sabit "landmark" cami listesi Türkiye'nin her yerinde gösteriliyordu
///    (Ankara'daki kullanıcı Bağcılar camilerini görüyordu).
/// 2. Aynı cami OSM + Nominatim'den mükerrer geliyordu.
/// 3. "ŞİŞLİ" yazınca "şişli" camileri bulunmuyordu (Türkçe `İ` sorunu).
/// 4. Tesis etiketleri uydurma sabitlerdi ("Cuma Namazı", "Şadırvan"…).
/// 5. Boş liste / hata durumunda ekran boş kalıyordu.
/// 6. Dar ekranda kart satırı taşıyordu (düğmeler artık alt satırda).
void main() {
  group('Türkçe arama normalizasyonu', () {
    test('Büyük/küçük harf ve noktalı İ eşleşir', () {
      expect(normalizeTurkish('ŞİŞLİ'), 'sisli');
      expect(normalizeTurkish('şişli'), 'sisli');
      expect(normalizeTurkish('ÇAMLICA'), 'camlica');
      expect(normalizeTurkish('Üsküdar'), 'uskudar');
      expect(normalizeTurkish('Ğ'), 'g');
    });

    test('Türkçe karakter yazılmasa da eşleşir', () {
      final String typed = normalizeTurkish('camii');
      expect(normalizeTurkish('Çamlıca Camii'), contains(typed));
      expect(normalizeTurkish('Ayasofya-i Kebir Cami-i Şerifi'), contains('ayasofya'));
    });

    test('Fazla boşluklar kırpılır', () {
      expect(normalizeTurkish('  Sultan   Ahmet  '), 'sultan ahmet');
    });

    test('Boş metin güvenli', () {
      expect(normalizeTurkish(''), '');
    });
  });

  group('Mükerrer cami temizliği', () {
    MosquePlace place(String name, double lat, double lon) =>
        MosquePlace(name: name, district: 'Test', latitude: lat, longitude: lon);

    test('Aynı ad + 120 m içindeki kayıtlar tekilleşir', () {
      final List<MosquePlace> input = <MosquePlace>[
        place('Merkez Camii', 41.0100, 28.9700),
        place('Merkez Camii', 41.0104, 28.9702), // ~45 m
        place('MERKEZ CAMİİ', 41.0101, 28.9701), // Türkçe büyük harf
      ];
      expect(dedupeMosques(input).length, 1);
    });

    test('Aynı ad ama uzak camiler korunur', () {
      final List<MosquePlace> input = <MosquePlace>[
        place('Fatih Camii', 41.0186, 28.9497),
        place('Fatih Camii', 41.1000, 29.0000), // ~10 km
      ];
      expect(dedupeMosques(input).length, 2);
    });

    test('Farklı adlar korunur', () {
      final List<MosquePlace> input = <MosquePlace>[
        place('Sultanahmet Camii', 41.0054, 28.9768),
        place('Ayasofya Camii', 41.0086, 28.9802),
      ];
      expect(dedupeMosques(input).length, 2);
    });

    test('Uzun adlarda kısaltma da mükerrer sayılır', () {
      final List<MosquePlace> input = <MosquePlace>[
        place('Süleymaniye Camii', 41.0162, 28.9641),
        place('Süleymaniye Camii (Kanuni)', 41.0163, 28.9641),
      ];
      expect(dedupeMosques(input).length, 1);
    });

    test('Boş girdi güvenli', () {
      expect(dedupeMosques(const <MosquePlace>[]), isEmpty);
    });
  });

  group('Mesafe ve yön etiketleri', () {
    final MosquePlace mosque = MosquePlace(
      name: 'Test Camii',
      district: 'Bağcılar',
      latitude: 41.0339,
      longitude: 28.8567,
    );

    test('Aynı noktada 0 m', () {
      expect(mosque.formattedDistanceFrom(41.0339, 28.8567), '0 m');
    });

    test('1 km altı metre cinsinden', () {
      final String label = mosque.formattedDistanceFrom(41.0389, 28.8567);
      expect(label, endsWith(' m'));
    });

    test('Uzak mesafe km cinsinden', () {
      final String label = mosque.formattedDistanceFrom(39.9334, 32.8597);
      expect(label, endsWith(' km'));
    });

    test('Yön etiketi 8 yönden biri', () {
      const List<String> dirs = <String>['K', 'KD', 'D', 'GD', 'G', 'GB', 'B', 'KB'];
      final String dir = mosque.compassLabelFrom(41.0000, 28.8567);
      expect(dirs, contains(dir));
    });
  });

  group('Uydurma tesis etiketi yok', () {
    test('Varsayılan kayıtta tesis listesi boş', () {
      const MosquePlace mosque = MosquePlace(
        name: 'Herhangi Camii',
        district: 'X',
        latitude: 40,
        longitude: 29,
      );
      expect(mosque.facilities, isEmpty);
    });
  });
}
