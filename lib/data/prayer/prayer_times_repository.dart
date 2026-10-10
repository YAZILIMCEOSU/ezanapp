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
        final PrayerTimesDay resolved = cached.copyWith(source: 'cache');
        _memory[key] = resolved;
        if (!_connectivity.isOnline) {
          lastWarning =
              'Çevrimdışı: son kaydedilen resmî vakitler gösteriliyor.';
        }
        return resolved;
      }
    }

    final bool useDiyanetOfficial =
        (method.id == 'diyanet' || method.id == 'diyanet_high_lat') &&
        method.asrFactor == CalculationMethod.diyanet.asrFactor;
    final List<PrayerTimesSource> chain =
        _connectivity.isOnline && location.city != null
        ? <PrayerTimesSource>[
            if (useDiyanetOfficial) _diyanet,
            _aladhan,
            _local,
          ]
        : <PrayerTimesSource>[_local];

    final List<String> failures = <String>[];
    for (final PrayerTimesSource source in chain) {
      try {
        final PrayerTimesDay rawResult = await source.fetchDay(
          location: location,
          date: date,
          method: method,
        );
        final PrayerTimesDay result = _applyExtraOffsets(rawResult, method);
        if (!result.isSane) {
          failures.add('${source.id}: vakitler tutarsız');
          continue;
        }
        _memory[key] = result;
        await _cache.save(_locationKey(location, method), result);
        if (source.id == 'calculation' && _connectivity.isOnline) {
          lastWarning =
              'Resmî vakit servisine ulaşılamadı; vakitler cihazda hesaplandı.';
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

  /// Aralık (haftalık/aylık tablo).
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
      if (memo != null) return memo;
    }

    final String locationKey = _locationKey(location, method);
    final List<PrayerTimesDay> cached = await _cache.getRange(
      locationKey,
      startDate,
      endDate,
    );
    final bool cacheCoversRange =
        cached.length >= endDate.difference(startDate).inDays;

    if (_connectivity.isOnline &&
        location.city != null &&
        (!cacheCoversRange || forceRefresh)) {
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
            await _cache.saveMany(locationKey, fetched);
            _rangeMemory[key] = fetched;
            return fetched;
          }
        } on PrayerTimesSourceException catch (error) {
          AppLog.warning('Aralık kaynağı başarısız → $error');
        } catch (error) {
          AppLog.warning('Aralık isteği hata verdi', error: error);
        }
      }
    }

    if (cached.isNotEmpty) {
      _rangeMemory[key] = cached;
      return cached;
    }

    final List<PrayerTimesDay> calculated = await _local.fetchRange(
      location: location,
      startDate: startDate,
      endDate: endDate,
      method: method,
    );
    _rangeMemory[key] = calculated;
    unawaited(_cache.saveMany(locationKey, calculated));
    return calculated;
  }

  /// Ayarlar ekranı için: hangi kaynağın kullanıldığı bilgisi.
  Future<String> describeActiveSource(UserLocation location) async {
    if (location.city != null) {
      final DateTime? last = await _cache.lastFetch(_locationKey(location));
      if (last != null) return 'Son güncelleme: ${_relative(last)}';
    }
    if (location.city == null) {
      return 'Konum seçilmedi: vakitler GPS koordinatına göre hesaplanır';
    }
    return 'Resmî Diyanet verisi • ilçe: ${location.city!.name}';
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
      if ((method.adjustments[p] ?? 0) != (def.adjustments[p] ?? 0)) {
        return false;
      }
    }
    return true;
  }

  static String _methodSignature(CalculationMethod method) {
    final String adj = Prayer.values
        .map((Prayer p) => '${p.key}:${method.adjustments[p] ?? 0}')
        .join(',');
    return '${method.id}|asr${method.asrFactor}|$adj';
  }

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
          (method.adjustments[prayer] ?? 0) - (base.adjustments[prayer] ?? 0);
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
