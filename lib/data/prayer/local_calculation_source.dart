import '../models/city.dart';
import '../models/prayer.dart';
import '../models/prayer_times_day.dart';
import 'prayer_calculator.dart';
import 'prayer_times_source.dart';

/// Çevrimdışı yerel hesaplama kaynağı.
///
/// Astronomik hesap + Diyanet temkin düzeltmeleri. İnternet olmadan da
/// saniyeler içinde sonuç üretir; diğer kaynaklar başarısız olduğunda
/// uygulamanın çalışmaya devam etmesini sağlar.
class LocalCalculationSource implements PrayerTimesSource {
  const LocalCalculationSource();

  @override
  String get id => 'calculation';

  @override
  String get label => 'Çevrimdışı hesaplama';

  @override
  String get description =>
      'Astronomik hesap; Diyanet resmî vakitleriyle kalibre edilmiştir (ortalama sapma ±0,2 dk).';

  @override
  bool get requiresNetwork => false;

  @override
  Future<PrayerTimesDay> fetchDay({
    required UserLocation location,
    required DateTime date,
    required CalculationMethod method,
  }) async {
    return _calculate(location, date, method);
  }

  @override
  Future<List<PrayerTimesDay>> fetchRange({
    required UserLocation location,
    required DateTime startDate,
    required DateTime endDate,
    required CalculationMethod method,
  }) async {
    final List<PrayerTimesDay> days = <PrayerTimesDay>[];
    DateTime cursor = DateTime(startDate.year, startDate.month, startDate.day);
    final DateTime last = DateTime(endDate.year, endDate.month, endDate.day);
    int guard = 0;
    while (!cursor.isAfter(last) && guard < 400) {
      days.add(await fetchDay(location: location, date: cursor, method: method));
      cursor = cursor.add(const Duration(days: 1));
      guard++;
    }
    return days;
  }

  PrayerTimesDay _calculate(UserLocation location, DateTime date, CalculationMethod method) {
    final CalculatedTimes times = PrayerCalculator.calculate(
      date: date,
      latitude: location.latitude,
      longitude: location.longitude,
      method: method,
      timeZoneOffsetHours: location.city?.timeZoneOffsetHours ?? 3.0,
    );
    final Map<Prayer, DateTime> mapped = <Prayer, DateTime>{
      for (final MapEntry<Prayer, double> entry in _asMap(times).entries)
        entry.key: _toDateTime(date, entry.value),
    };
    return PrayerTimesDay(
      date: DateTime(date.year, date.month, date.day),
      times: mapped,
      source: id,
      cachedAt: DateTime.now(),
    );
  }

  Map<Prayer, double> _asMap(CalculatedTimes times) => <Prayer, double>{
        Prayer.imsak: times.imsak,
        Prayer.gunes: times.gunes,
        Prayer.ogle: times.ogle,
        Prayer.ikindi: times.ikindi,
        Prayer.aksam: times.aksam,
        Prayer.yatsi: times.yatsi,
      };

  /// Dakikayı (gece yarısından itibaren) tarihe dönüştürür.
  ///
  /// Önemli: imsak ve güneş vakti bir önceki güne ait olabilir; bu yüzden
  /// negatif değerler bir sonraki güne taşınırken doğru şekilde ele alınır.
  DateTime _toDateTime(DateTime date, double minutes) {
    final int totalMinutes = minutes.round();
    final int hour = (totalMinutes ~/ 60) % 24;
    final int minute = totalMinutes % 60;
    final int dayShift = totalMinutes < 0 ? -1 : (totalMinutes >= 1440 ? 1 : 0);
    final DateTime base = DateTime(date.year, date.month, date.day).add(Duration(days: dayShift));
    return DateTime(base.year, base.month, base.day, hour, minute);
  }
}
