import 'dart:async';

import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/services/connectivity_service.dart';
import '../../core/utils/logger.dart';
import '../models/city.dart';
import '../models/prayer.dart';
import '../models/prayer_times_day.dart';
import 'aladhan_api_source.dart';
import 'diyanet_api_source.dart';
import 'local_calculation_source.dart';
import 'prayer_calculator.dart';
import 'prayer_times_cache.dart';
import 'prayer_times_source.dart';
import 'time_zone_resolver.dart';

/// Vakit verisinin tek giriş noktası.
///
/// Çalışma akışı:
/// 1. Bellek önbelleği (aynı gün + aynı konum için anında yanıt)
/// 2. SQLite önbelleği (son başarılı resmî veri)
/// 3. Ağ kaynakları: Diyanet → AlAdhan
/// 4. Çevrimdışı yerel hesap (her koşulda çalışır)
///
/// Hiçbir adım istisna fırlatıp kullanıcıyı boş ekranla bırakmaz; en kötü
/// durumda bile yerel hesap sonuç üretir ve durum `source` alanıyla bildirilir.
class PrayerTimesRepository {
  /// Kaynaklar arayüz tipiyle alınır; böylece zincire yeni bir sağlayıcı
  /// (ör. kurumsal bir ezan servisi) takmak veya testte sahtesini kullanmak
  /// için repository'yi değiştirmek gerekmez.
  PrayerTimesRepository({
    required this._cache,
    required this._connectivity,
    PrayerTimesSource? diyanet,
    PrayerTimesSource? aladhan,
    PrayerTimesSource? local,
  }) : _diyanet = diyanet ?? DiyanetApiSource(),
       _aladhan = aladhan ?? AladhanApiSource(),
       _local = local ?? const LocalCalculationSource();

  final PrayerTimesCache _cache;
  final ConnectivityService _connectivity;
  final PrayerTimesSource _diyanet;
  final PrayerTimesSource _aladhan;
  final PrayerTimesSource _local;

  final Map<String, PrayerTimesDay> _memory = <String, PrayerTimesDay>{};
  final Map<String, List<PrayerTimesDay>> _rangeMemory =
      <String, List<PrayerTimesDay>>{};

  /// Kullanıcıya son veri durumunu bildirmek için.
  PrayerTimesDay? lastDay;
  String? lastWarning;

  /// Kaynak zinciri (öncelik sırası).
  List<PrayerTimesSource> get sources => <PrayerTimesSource>[
    _diyanet,
    _aladhan,
    _local,
  ];

  /// Tek gün vakitleri.
  Future<PrayerTimesDay> getDay({
    required UserLocation location,
    required DateTime date,
    required CalculationMethod method,
    bool forceRefresh = false,
  }) async {
    final String key = _cacheKey(location, method, date);
    lastWarning = null;

    if (!forceRefresh) {
      final PrayerTimesDay? memo = _memory[key];
      if (memo != null && !_isStale(memo)) return memo;

      final PrayerTimesDay? cached = await _cache.get(
        _locationKey(location, method),
        date,
      );
      if (cached != null && !_isStale(cached)) {
        // Önbellek **ham** resmî veriyi saklar; Hanefî/manüel düzeltmeler her
        // okumada yeniden uygulanır. Böylece ayar değiştirildiğinde eski
        // kayıtlar yanlış dakika göstermez (ve düzeltmeler iki kez eklenmez).
        final PrayerTimesDay resolved = _refineRemote(
          cached,
          method,
          location,
        ).copyWith(source: 'cache');
        _memory[key] = resolved;
        if (!_connectivity.isOnline) {
          lastWarning =
              'Çevrimdışı: son kaydedilen resmî vakitler gösteriliyor.';
        }
        return resolved;
      }
    }

    // **Düzeltme:** Hanefî ikindi veya manuel dakika düzeltmesi seçildiğinde
    // resmî Diyanet verisi **atlanmıyordu**; zincir doğrudan AlAdhan'a
    // düşüyor ve temkin düzeltmeleri kaybolduğu için akşam ~8, öğle ~5,
    // ikindi ~4, yatsı ~1 dakika **erken** görünüyordu. Artık resmî veri her
    // zaman ilk sırada; Hanefî farkı ve manuel düzeltme `_refineRemote`
    // içinde resmî vakitlerin **üzerine** uygulanır.
    final List<PrayerTimesSource> chain =
        _connectivity.isOnline && location.city != null
        ? <PrayerTimesSource>[_diyanet, _aladhan, _local]
        : <PrayerTimesSource>[_local];

    final List<String> failures = <String>[];
    for (final PrayerTimesSource source in chain) {
      try {
        final PrayerTimesDay rawResult = await source.fetchDay(
          location: location,
          date: date,
          method: method,
        );
        final PrayerTimesDay result = _refineRemote(
          rawResult,
          method,
          location,
        );
        if (!result.isSane) {
          failures.add('${source.id}: vakitler tutarsız');
          continue;
        }
        _memory[key] = result;
        // Cihazda hesaplanan vakitler önbelleğe yazılmaz: hesap zaten
        // milisaniyeler sürer ve yazılırsa manuel düzeltmeler ikinci kez
        // uygulanabilir. Yalnızca uzak/resmî veri saklanır.
        if (rawResult.source != 'calculation') {
          await _cache.save(_locationKey(location, method), rawResult);
        }
        if (source.id == 'calculation' && _connectivity.isOnline) {
          lastWarning =
              'Resmî vakit servisine ulaşılamadı; vakitler cihazda hesaplandı.';
        } else if (source.id == 'aladhan' && location.city != null) {
          lastWarning =
              'Diyanet resmî verisine şu an ulaşılamadı; yedek servis '
              'kullanıldı (Diyanet temkinine göre düzeltildi). '
              'Listeyi yenilemeyi deneyin.';
        }
        return result;
      } on PrayerTimesSourceException catch (error) {
        failures.add('${error.sourceId}: ${error.message}');
        AppLog.warning('Vakit kaynağı başarısız → $error');
      } catch (error) {
        failures.add('${source.id}: $error');
        AppLog.warning('Vakit kaynağı hata verdi', error: error);
      }
    }

    // Buraya düşülmemeli (yerel hesap her zaman çalışır) ama yine de güvence:
    final PrayerTimesDay fallback = await _local.fetchDay(
      location: location,
      date: date,
      method: method,
    );
    lastWarning = 'Vakitler cihazda hesaplandı.';
    return fallback;
  }

  /// Aralık (haftalık/aylık tablo ve **bildirim zamanlaması**).
  ///
  /// Dönen listenin her zaman istenen **her günü** içermesi garanti edilir;
  /// eksik günler tek tek [getDay] ile tamamlanır. Böylece ana ekranda görünen
  /// saat ile bildirime kurulan saat **aynı kaynaktan** gelir (eskiden aralık
  /// isteği başarısız olunca bildirim yedek servisten, ekran resmî veriden
  /// beslenebiliyor ve 1–2 dakika fark oluşuyordu).
  Future<List<PrayerTimesDay>> getRange({
    required UserLocation location,
    required DateTime startDate,
    required DateTime endDate,
    required CalculationMethod method,
    bool forceRefresh = false,
  }) async {
    final String key = _rangeKey(location, method, startDate, endDate);
    if (!forceRefresh) {
      final List<PrayerTimesDay>? memo = _rangeMemory[key];
      // Bellek önbelleği de tazelik denetiminden geçer; aksi halde uygulama
      // açık kaldığı sürece (günlerce) eski saatler kullanılmaya devam ederdi.
      if (memo != null && _isRangeFresh(memo) && _covers(memo, startDate, endDate)) {
        return memo;
      }
      _rangeMemory.remove(key);
    }

    final String locationKey = _locationKey(location, method);
    final List<PrayerTimesDay> cached = await _cache.getRange(
      locationKey,
      startDate,
      endDate,
    );
    final bool cacheCoversRange = _covers(cached, startDate, endDate);
    // **Düzeltme:** aralık önbelleği hiç tazelik denetimi yapmıyordu.
    // Cihazda hesaplanmış (ya da 1 hafta önce çekilmiş) kayıtlar "taze"
    // sayılıp bildirimler bu eski saatlere kuruluyordu; ekran ise güncel
    // resmî veriyi gösterdiği için ezan 1–2 dakika **erken** çalabiliyordu.
    final bool cacheFresh = cached.isEmpty ? false : _isRangeFresh(cached);

    List<PrayerTimesDay>? resolved;

    if (_connectivity.isOnline &&
        location.city != null &&
        (!cacheCoversRange || forceRefresh || !cacheFresh)) {
      for (final PrayerTimesSource source in <PrayerTimesSource>[
        _diyanet,
        _aladhan,
      ]) {
        try {
          final List<PrayerTimesDay> fetched = await source.fetchRange(
            location: location,
            startDate: startDate,
            endDate: endDate,
            method: method,
          );
          if (fetched.isNotEmpty) {
            if (fetched.first.source != 'calculation') {
              await _cache.saveMany(locationKey, fetched);
            }
            resolved = <PrayerTimesDay>[
              for (final PrayerTimesDay day in fetched)
                _refineRemote(day, method, location),
            ];
            // **Resmî veri kısmi de olsa korunur.** Eksik günler aşağıda
            // `_fillMissingDays` ile Diyanet'in tek-gün uç noktasından
            // tamamlanır; tüm aralığı yedek servise çevirmek dakika farkına
            // yol açardı.
            if (source.id == 'diyanet') break;
          }
        } on PrayerTimesSourceException catch (error) {
          AppLog.warning('Aralık kaynağı başarısız → $error');
        } catch (error) {
          AppLog.warning('Aralık isteği hata verdi', error: error);
        }
      }
    }

    resolved ??= cached.isNotEmpty
        ? <PrayerTimesDay>[
            // Önbellekteki resmî veri kullanıcı düzeltmeleriyle birlikte
            // sunulur; böylece ekran ile bildirim aynı dakikayı gösterir.
            // Kaynak etiketi "Kayıtlı veri"; düzeltmeler **özgün kaynağa**
            // (Diyanet) göre uygulanır.
            for (final PrayerTimesDay day in cached)
              _refineRemote(day, method, location).copyWith(source: 'cache'),
          ]
        : await _local.fetchRange(
            location: location,
            startDate: startDate,
            endDate: endDate,
            method: method,
          );

    // Her koşulda eksik günleri tamamla (bildirim boşluğu kalmasın).
    final List<PrayerTimesDay> complete = await _fillMissingDays(
      resolved,
      location: location,
      startDate: startDate,
      endDate: endDate,
      method: method,
    );
    _rangeMemory[key] = complete;
    return complete;
  }

  /// Aralıktaki eksik günleri tek-gün zinciriyle (Diyanet → yedek → hesap)
  /// tamamlar ve tarihe göre sıralar.
  Future<List<PrayerTimesDay>> _fillMissingDays(
    List<PrayerTimesDay> days, {
    required UserLocation location,
    required DateTime startDate,
    required DateTime endDate,
    required CalculationMethod method,
  }) async {
    final int expected = _daysBetween(startDate, endDate);
    final DateTime windowStart = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime windowEnd = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
    ).add(const Duration(days: 1));
    String keyOf(DateTime d) => '${d.year}-${d.month}-${d.day}';
    // **Düzeltme:** kaynak istenen aralığın dışında gün döndürebiliyordu
    // (AlAdhan bütün ayı döner). Haftalık tablo 31 gün gösteriyor, bildirim
    // ufku kayıyordu. Pencere dışındaki günler atılır.
    final Map<String, PrayerTimesDay> byDate = <String, PrayerTimesDay>{
      for (final PrayerTimesDay day in days)
        if (!day.date.isBefore(windowStart) && day.date.isBefore(windowEnd))
          keyOf(day.date): day,
    };
    if (byDate.length >= expected) {
      final List<PrayerTimesDay> sorted = byDate.values.toList()
        ..sort((PrayerTimesDay a, PrayerTimesDay b) => a.date.compareTo(b.date));
      return sorted;
    }
    // Güvenlik sınırı: iki aydan uzun aralıkta gün gün istek atmayalım.
    if (expected > 62) {
      final List<PrayerTimesDay> sorted = byDate.values.toList()
        ..sort((PrayerTimesDay a, PrayerTimesDay b) => a.date.compareTo(b.date));
      return sorted;
    }
    final DateTime first = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    for (int i = 0; i < expected; i++) {
      final DateTime day = first.add(Duration(days: i));
      if (byDate.containsKey(keyOf(day))) continue;
      try {
        final PrayerTimesDay filled = await getDay(
          location: location,
          date: day,
          method: method,
        );
        byDate[keyOf(day)] = filled;
      } catch (error) {
        AppLog.warning('Aralıkta eksik gün tamamlanamadı ($day)', error: error);
      }
    }
    final List<PrayerTimesDay> sorted = byDate.values.toList()
      ..sort((PrayerTimesDay a, PrayerTimesDay b) => a.date.compareTo(b.date));
    return sorted;
  }

  /// Aralık, istenen günlerin **tamamını** içeriyor mu?
  static bool _covers(
    List<PrayerTimesDay> days,
    DateTime startDate,
    DateTime endDate,
  ) {
    if (days.isEmpty) return false;
    final Set<String> keys = <String>{
      for (final PrayerTimesDay day in days)
        '${day.date.year}-${day.date.month}-${day.date.day}',
    };
    final DateTime first = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final int expected = _daysBetween(startDate, endDate);
    for (int i = 0; i < expected; i++) {
      final DateTime day = first.add(Duration(days: i));
      if (!keys.contains('${day.year}-${day.month}-${day.day}')) return false;
    }
    return true;
  }

  /// İki tarih arasındaki gün sayısı (**dahil** — off-by-one koruması).
  static int _daysBetween(DateTime startDate, DateTime endDate) =>
      DateTime(endDate.year, endDate.month, endDate.day)
          .difference(DateTime(startDate.year, startDate.month, startDate.day))
          .inDays +
      1;

  /// Ayarlar ekranı için: hangi kaynağın kullanıldığı bilgisi.
  Future<String> describeActiveSource(UserLocation location) async {
    if (location.city != null) {
      final DateTime? last = await _cache.lastFetch(_locationKey(location));
      if (last != null) {
        return 'Diyanet resmî verisi • ilçe: ${location.city!.name} · '
            'son kontrol ${_relative(last)}';
      }
      return 'Diyanet resmî verisi • ilçe: ${location.city!.name}';
    }
    return 'Konum seçilmedi: vakitler GPS koordinatına göre cihazda hesaplanır';
  }

  /// Namaza kalan süre bilgisi (ana ekran sayacı için).
  ({PrayerTime? next, Prayer? current, Duration? remaining}) nextPrayerInfo(
    PrayerTimesDay day,
    DateTime now,
  ) {
    final Prayer current = day.currentPrayer(now);
    final PrayerTime? next = day.nextPrayer(now);
    return (
      next: next,
      current: current,
      remaining: next?.time.difference(now),
    );
  }

  /// Vaktin girdiği andan itibaren geçen süre.
  Duration elapsedSince(PrayerTimesDay day, Prayer prayer, DateTime now) {
    final DateTime? time = day.timeOf(prayer);
    if (time == null) return Duration.zero;
    final Duration elapsed = now.difference(time);
    return elapsed.isNegative ? Duration.zero : elapsed;
  }

  void clearMemoryCache() {
    _memory.clear();
    _rangeMemory.clear();
  }

  /// Aralık önbelleği taze mi? (en eski kayıt TTL'den yeni olmalı)
  bool _isRangeFresh(List<PrayerTimesDay> days) {
    final DateTime now = DateTime.now();
    for (final PrayerTimesDay day in days) {
      final DateTime? fetched = day.cachedAt;
      if (fetched == null) return false;
      if (now.difference(fetched) > AppConstants.prayerTimesTtl) return false;
    }
    return true;
  }

  bool _isStale(PrayerTimesDay day) {
    if (day.source == 'calculation') return false;
    final DateTime? fetched = day.cachedAt;
    if (fetched == null) return true;
    return DateTime.now().difference(fetched) > AppConstants.prayerTimesTtl;
  }

  String _locationKey(UserLocation location, [CalculationMethod? method]) {
    final String base = location.city != null
        ? 'district:${location.city!.id}'
        : 'gps:${double.parse(location.latitude.toStringAsFixed(2))}_${double.parse(location.longitude.toStringAsFixed(2))}';
    if (_isDefaultDiyanet(method)) return base;
    return '$base|${_methodSignature(method!)}';
  }

  static bool _isDefaultDiyanet(CalculationMethod? method) {
    if (method == null) return true;
    const CalculationMethod def = CalculationMethod.diyanet;
    if (method.id != def.id || method.asrFactor != def.asrFactor) return false;
    for (final Prayer p in Prayer.values) {
      if ((method.manualOffsets[p.key] ?? 0) !=
          (def.manualOffsets[p.key] ?? 0)) {
        return false;
      }
    }
    return true;
  }

  static String _methodSignature(CalculationMethod method) {
    final String adj = Prayer.values
        .map((Prayer p) => '${p.key}:${method.manualOffsets[p.key] ?? 0}')
        .join(',');
    return '${method.id}|asr${method.asrFactor}|$adj';
  }

  /// Uzak (resmî) veriye yöntem ve kullanıcı düzeltmelerini uygular.
  ///
  /// * **Hanefî (asr-ı sânî):** resmî ikindi vakti, aynı günün asr-ı sânî
  ///   farkı kadar (genelde 40–90 dk) ileri alınır. Diğer vakitler resmî kalır.
  /// * **Manuel dakika düzeltmeleri:** yöntemin varsayılanından farkı eklenir.
  ///
  /// Yerel hesaplama kaynağı bu düzeltmeleri kendi içinde uyguladığı için
  /// burada yalnızca resmî/uzak kaynaklara dokunulur.
  PrayerTimesDay _refineRemote(
    PrayerTimesDay day,
    CalculationMethod method,
    UserLocation location,
  ) {
    PrayerTimesDay refined = day;
    final bool officialData = day.source == 'diyanet';
    final CalculationMethod base = CalculationMethod.fromId(method.id);
    if (officialData && method.asrFactor >= 2 && base.asrFactor < 2) {
      final DateTime? ikindi = day.timeOf(Prayer.ikindi);
      if (ikindi != null) {
        final double shift = PrayerCalculator.asrShiftMinutes(
          date: day.date,
          latitude: location.latitude,
          longitude: location.longitude,
          method: base,
          timeZoneOffsetHours: _tzFor(day.date, location),
        );
        if (shift > 0) {
          // Tam dakikaya yuvarlanır: ekranda 17:10 yazıyorsa bildirim de
          // 17:10:00'da çalsın (saniye artığı kalmasın).
          refined = refined.copyWith(
            times: <Prayer, DateTime>{
              ...refined.times,
              Prayer.ikindi: ikindi.add(Duration(minutes: shift.round())),
            },
          );
        }
      }
    }
    return _applyExtraOffsets(refined, method);
  }

  /// O günün UTC farkı — çevrimdışı hesapla **aynı** çözümleyici kullanılır.
  static double _tzFor(DateTime date, UserLocation location) =>
      TimeZoneResolver.forLocation(location, date);

  /// Uzak servislerden gelen vakitlere kullanıcının manuel dakika düzeltmelerini uygular.
  static PrayerTimesDay _applyExtraOffsets(
    PrayerTimesDay day,
    CalculationMethod method,
  ) {
    if (day.source == 'calculation') return day;
    final CalculationMethod base = CalculationMethod.fromId(method.id);
    bool hasExtra = false;
    final Map<Prayer, DateTime> adjusted = <Prayer, DateTime>{};
    for (final Prayer prayer in Prayer.values) {
      final DateTime? time = day.times[prayer];
      if (time == null) continue;
      final int extra =
          (method.manualOffsets[prayer.key] ?? 0) -
          (base.manualOffsets[prayer.key] ?? 0);
      if (extra != 0) hasExtra = true;
      adjusted[prayer] = extra == 0 ? time : time.add(Duration(minutes: extra));
    }
    if (!hasExtra) return day;
    return day.copyWith(times: adjusted);
  }

  String _cacheKey(
    UserLocation location,
    CalculationMethod method,
    DateTime date,
  ) =>
      '${_locationKey(location, method)}|${_methodSignature(method)}|${date.year}-${date.month}-${date.day}';

  String _rangeKey(
    UserLocation location,
    CalculationMethod method,
    DateTime start,
    DateTime end,
  ) =>
      '${_locationKey(location, method)}|${_methodSignature(method)}|range|${start.year}${start.month}${start.day}-${end.year}${end.month}${end.day}';

  String _relative(DateTime time) {
    final Duration diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'az önce';
    if (diff.inHours < 1) return '${diff.inMinutes} dk önce';
    if (diff.inDays < 1) return '${diff.inHours} saat önce';
    return '${diff.inDays} gün önce';
  }

  /// Kullanıcı dostu hata mesajı — boş durum ekranlarında gösterilir.
  static AppException friendlyError(Object error) =>
      error is AppException ? error : AppException.unexpected(error);
}
