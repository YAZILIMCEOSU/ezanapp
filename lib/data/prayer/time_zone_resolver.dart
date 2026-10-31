import '../../core/utils/geo.dart';
import '../models/city.dart';

/// Bir konum için **o günün** UTC farkını (saat) çözer.
///
/// Aynı mantık hem çevrimdışı hesapta hem de resmî veriye uygulanan
/// düzeltmelerde kullanılır; iki yerde farklı sonuç çıkması "ekran 19:41,
/// bildirim 19:34" gibi tutarsızlıklara yol açıyordu.
abstract final class TimeZoneResolver {
  /// Öncelik sırası:
  /// 1. Şehir kaydında saat dilimi **açıkça** varsa o kullanılır.
  /// 2. Türkiye ilçeleri her zaman UTC+3'tür (2016'dan beri yaz saati yok).
  /// 3. GPS ile alınmış konumda cihazın o günkü saat dilimi esas alınır
  ///    (kullanıcı fiziksel olarak oradadır; yaz saati doğru uygulanır).
  /// 4. Yurt dışı şehir seçildiyse boylamdan yaklaşık dilim hesaplanır,
  ///    30 dakikaya yuvarlanır (Kâbil ≈ +4,5; Tahran ≈ +3,5).
  static double forLocation(UserLocation location, DateTime date) {
    final City? city = location.city;
    if (city != null) {
      if (city.hasTimeZone) return city.timeZoneOffsetHours;
      if (city.isTurkish) return 3.0;
      if (location.mode == LocationMode.gps) {
        return _deviceOffset(date);
      }
      return GeoUtils.approximateUtcOffsetHours(city.longitude);
    }
    return _deviceOffset(date);
  }

  /// Cihazın verilen gündeki UTC farkı (yaz/kış saati dahil).
  static double _deviceOffset(DateTime date) {
    return DateTime(
              date.year,
              date.month,
              date.day,
              12,
            ).timeZoneOffset.inMinutes /
        60.0;
  }
}
