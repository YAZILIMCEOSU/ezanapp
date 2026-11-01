import 'package:ezanai/core/services/location_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Konum hızı ve tazelik testleri.**
///
/// Kullanıcı bildirimi: "konum bilgisini geç alıyor".
///
/// Uygulama artık GPS kilidini beklemiyor:
/// 1. Son bilinen konum (**10 dakikadan yeni**) anında kullanılır,
/// 2. yoksa düşük doğruluk (Wi-Fi) → orta → yüksek doğruluk sırasıyla,
///    toplam ~9 saniyelik bütçeyle denenir,
/// 3. hiçbiri olmazsa eski de olsa son bilinen konum döner.
///
/// Bu dosya, kararı veren **saf** yardımcıları doğrular; platform çağrısı
/// yapılmaz (geolocator kanalı yalnızca gerçek cihazda çalışır).
void main() {
  LocationFix fix({
    double lat = 41.0132,
    double lon = 28.9486,
    double? accuracy,
    Duration ago = Duration.zero,
  }) => LocationFix(
    latitude: lat,
    longitude: lon,
    accuracyMeters: accuracy,
    timestamp: DateTime.now().subtract(ago),
  );

  group('tazelik: GPS beklenmeden kullanılabilir mi?', () {
    test('2 dakikalık konum tazedir', () {
      expect(fix(ago: const Duration(minutes: 2)).isFresh, isTrue);
    });

    test('9 dakikalık konum tazedir (sınır altı)', () {
      expect(fix(ago: const Duration(minutes: 9)).isFresh, isTrue);
    });

    test('15 dakikalık konum taze değildir', () {
      expect(
        fix(ago: const Duration(minutes: 15)).isFresh,
        isFalse,
        reason: 'Bayat konumla vakit hesaplanmamalı',
      );
    });

    test('tarih bilgisi yoksa taze sayılmaz', () {
      const LocationFix unknown = LocationFix(latitude: 41, longitude: 29);
      expect(unknown.isFresh, isFalse);
    });

    test('gelecekteki zaman damgası negatif yaş üretmez', () {
      final LocationFix future = LocationFix(
        latitude: 41,
        longitude: 29,
        timestamp: DateTime.now().add(const Duration(minutes: 5)),
      );
      expect(future.age, Duration.zero);
      expect(future.isFresh, isTrue);
    });
  });

  group('ilçe eşleştirme hassasiyeti', () {
    test('500 m doğruluk ilçe için yeterli', () {
      expect(fix(accuracy: 500).isDistrictAccurate, isTrue);
    });

    test('2 km doğruluk sınırda yeterli', () {
      expect(fix(accuracy: 2000).isDistrictAccurate, isTrue);
    });

    test('3 km doğruluk ilçe için yetersiz (arka planda iyileştirilir)', () {
      expect(
        fix(accuracy: 3000).isDistrictAccurate,
        isFalse,
        reason: 'Kaba konum yanlış ilçeye düşüp vakitleri 1–2 dk kaydırabilir',
      );
    });

    test('hassasiyet bilinmiyorsa yetersiz kabul edilir', () {
      expect(fix().isDistrictAccurate, isFalse);
    });
  });

  group('bütçe sabitleri', () {
    test('tazelik penceresi ve GPS bütçesi makul', () {
      expect(LocationService.freshWindow.inMinutes, inInclusiveRange(5, 15));
      expect(
        LocationService.defaultBudget.inSeconds,
        inInclusiveRange(4, 15),
        reason: 'Kullanıcı 15 saniyeden fazla beklememeli',
      );
    });
  });
}
