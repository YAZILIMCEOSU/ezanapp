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
      days.add(
        await fetchDay(location: location, date: cursor, method: method),
      );
      cursor = cursor.add(const Duration(days: 1));
      guard++;
    }
    return days;
  }

  PrayerTimesDay _calculate(
    UserLocation location,
    DateTime date,
    CalculationMethod method,
  ) {
    final CalculatedTimes times = PrayerCalculator.calculate(
      date: date,
      latitude: location.latitude,
      longitude: location.longitude,
      method: method,
      timeZoneOffsetHours: _timeZoneOffset(location, date),
      manualOffsets: method.manualOffsets,
    );
    final Map<Prayer, DateTime> mapped = <Prayer, DateTime>{
      // Hesap motoru ondalık SAAT üretir (örn. 5.56 = 05:34); dönüştürücü
      // ise gece yarısından itibaren DAKİKA bekler.
      for (final MapEntry<Prayer, double> entry in _asMap(times).entries)
        entry.key: _toDateTime(date, entry.value * 60.0),
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

  /// Hesapta kullanılacak UTC farkını belirler.
  ///
  /// Seçili şehir varsa şehrin saat dilimi (yaz/kış saati dahil) kullanılır.
  /// Konum GPS ile alındıysa şehir bilgisi olmadığından cihazın o günkü
  /// saat dilimi farkı esas alınır; böylece yurt dışındaki kullanıcılar için
  /// vakitler 3 saat kaymaz.
  double _timeZoneOffset(UserLocation location, DateTime date) {
    final double? cityOffset = location.city?.timeZoneOffsetHours;
    if (cityOffset != null) return cityOffset;
    final DateTime probe = DateTime(date.year, date.month, date.day, 12);
    return probe.timeZoneOffset.inMinutes / 60.0;
  }

  /// Gece yarısından itibaren geçen [minutes] dakikayı tarihe dönüştürür.
  ///
  /// Gün sınırı aşılırsa (imsak/güneş bir önceki güne, yatsı bir sonraki güne
  /// taşabilir) komşu güne geçilir; negatif değerler de doğru ele alınır.
  DateTime _toDateTime(DateTime date, double minutes) {
    final int totalMinutes = minutes.round();
    final int dayShift = (totalMinutes / 1440).floor();
    final int inDay = totalMinutes - dayShift * 1440;
    final DateTime base = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(Duration(days: dayShift));
    return DateTime(base.year, base.month, base.day, inDay ~/ 60, inDay % 60);
  }
}
