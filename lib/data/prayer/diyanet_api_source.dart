import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/logger.dart';
import '../models/city.dart';
import '../models/prayer.dart';
import '../models/prayer_times_day.dart';
import 'prayer_calculator.dart';
import 'prayer_times_source.dart';

/// T.C. Diyanet İşleri Başkanlığı vakit verisi sağlayıcısı.
///
/// Diyanet, resmî vakit verilerini ilçe kimliği (district id) bazında
/// yayımlar. Uygulama, paket içindeki il/ilçe kimlikleriyle resmî veriyi
/// doğrudan çeker; böylece vakitler hesaplama değil **resmî kaynak** olur.
///
/// **Dayanıklılık (1 Kasım 2026):** Tek bir uç noktaya bağlı kalmak
/// "Resmî vakit servisine ulaşılamadı" uyarısına yol açıyordu. Artık sırasıyla
/// şunlar denenir:
///
/// 1. `daily?startDate=...` — tek küçük istek, tam istenen gün (ay sınırı
///    sorunu yok; açılışta ~100 KB aylık paket indirilmez),
/// 2. `monthly` — günlük uç nokta yanıt vermezse ayın tamamı (bellekte 6 saat),
/// 3. `yearly` — yılın tamamı,
/// 4. **Yedek resmî sunucu** (`ezanvakti.emushaf.net`) — aynı Diyanet verisi,
///    farklı altyapı.
///
/// Böylece bir servis kesintisi veya ay sınırı, kullanıcıyı doğrudan cihaz
/// hesabına düşürmez. Tüm zincirin toplam süresi [_dayBudget] ile sınırlıdır;
/// aksi hâlde dört ayrı zaman aşımı açılışı dakikalarca bekletirdi.
class DiyanetApiSource implements PrayerTimesSource {
  DiyanetApiSource({
    http.Client? client,
    this.baseUrl = 'https://ezanvakti.imsakiyem.com/api',
    this.fallbackBaseUrl = 'https://ezanvakti.emushaf.net',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  /// İkinci resmî kaynak: aynı Diyanet verisini yayımlayan bağımsız altyapı.
  final String fallbackBaseUrl;

  static const Duration _timeout = Duration(seconds: 4);

  /// Tek gün için tüm uç noktaların **toplam** bütçesi.
  ///
  /// Günlük istek zaman aşımına düşerse aylık/yedek yollar da denenir; ancak
  /// kullanıcı açılışta 20+ saniye beklememeli. Bütçe dolunca zincir durur ve
  /// sıradaki kaynak (AlAdhan / cihaz hesabı) devreye girer.
  static const Duration _dayBudget = Duration(seconds: 8);

  /// Aynı ilçe için aylık/yıllık/günlük yanıt bellekte tutulur.
  ///
  /// Resmî veri günde bir kez değişir; her gün isteği için tekrar ağa çıkmak
  /// hem yavaş hem de servis kesintisinde gereksiz yedek kaynağa düşme
  /// (dolayısıyla dakika farkı) riski demekti.
  final Map<String, _CachedPeriod> _periodCache = <String, _CachedPeriod>{};

  static const Duration _memoryTtl = Duration(hours: 6);

  /// Son başarılı isteğin okunabilir etiketi (tanılama ekranı için).
  String? lastEndpointLabel;

  /// Son hatanın kısa nedeni (tanılama ekranı için; kişisel veri içermez).
  String? lastError;

  @override
  String get id => 'diyanet';

  @override
  String get label => 'Diyanet (resmî veri)';

  @override
  String get description =>
      'Diyanet İşleri Başkanlığı’nın ilçe bazlı resmî namaz vakitleri. '
      'Yaz/kış saati ve resmî düzeltmeler dahildir.';

  @override
  bool get requiresNetwork => true;

  @override
  Future<PrayerTimesDay> fetchDay({
    required UserLocation location,
    required DateTime date,
    required CalculationMethod method,
  }) async {
    try {
      return await _fetchDayChain(
        location: location,
        date: date,
      ).timeout(_dayBudget);
    } on TimeoutException {
      lastError =
          'Resmî servis ${_dayBudget.inSeconds} saniyede yanıt vermedi.';
      throw const PrayerTimesSourceException(
        'diyanet',
        'Zaman aşımı.',
        isTransient: true,
      );
    }
  }

  /// Günlük → aylık → yıllık → yedek sunucu sırası (bütçe dışında).
  Future<PrayerTimesDay> _fetchDayChain({
    required UserLocation location,
    required DateTime date,
  }) async {
    final String? districtId = location.city?.id;
    if (districtId == null || districtId.isEmpty) {
      throw const PrayerTimesSourceException(
        'diyanet',
        'İlçe kimliği yok (konum seçilmemiş).',
        isTransient: false,
      );
    }

    PrayerTimesSourceException? failure;

    // 1) **Günlük** uç nokta: tek küçük istek, tam istenen gün. Ay sınırı
    //    sorunu yoktur ve aylık paketin (~100 KB) indirilmesini beklemez.
    try {
      final List<PrayerTimesDay> daily = await _fetch(
        districtId,
        'daily',
        query: <String, String>{'startDate': _isoDate(date)},
      );
      final PrayerTimesDay? hit = _findDay(daily, date);
      if (hit != null) {
        lastEndpointLabel = 'Diyanet resmî servisi (günlük veri)';
        return hit;
      }
    } catch (error) {
      failure = _asSourceError(error);
    }

    // 2) Aylık veri: günlük uç nokta yanıt vermezse ayın tamamı (bellekte
    //    6 saat; aynı ay içindeki sonraki günler ağa çıkmaz).
    try {
      final List<PrayerTimesDay> monthly = await _fetch(districtId, 'monthly');
      final PrayerTimesDay? hit = _findDay(monthly, date);
      if (hit != null) {
        lastEndpointLabel = 'Diyanet resmî servisi (aylık veri)';
        return hit;
      }
    } catch (error) {
      failure ??= _asSourceError(error);
    }

    // 3) Yıllık veri (yalnızca önceki adımlar günü bulamadıysa).
    try {
      final List<PrayerTimesDay> yearly = await _fetch(districtId, 'yearly');
      final PrayerTimesDay? hit = _findDay(yearly, date);
      if (hit != null) {
        lastEndpointLabel = 'Diyanet resmî servisi (yıllık veri)';
        return hit;
      }
    } catch (error) {
      failure ??= _asSourceError(error);
    }

    // 4) Yedek resmî sunucu: aynı veri, farklı altyapı.
    try {
      final List<PrayerTimesDay> backup = await _fetchBackupHost(districtId);
      final PrayerTimesDay? hit = _findDay(backup, date);
      if (hit != null) {
        lastEndpointLabel = 'Diyanet resmî servisi (yedek sunucu)';
        return hit;
      }
    } catch (error) {
      failure ??= _asSourceError(error);
    }

    lastError = failure?.message ?? 'Resmî vakit verisi alınamadı.';
    throw failure ??
        const PrayerTimesSourceException(
          'diyanet',
          'İstenen gün resmî veride bulunamadı.',
          isTransient: false,
        );
  }

  @override
  Future<List<PrayerTimesDay>> fetchRange({
    required UserLocation location,
    required DateTime startDate,
    required DateTime endDate,
    required CalculationMethod method,
  }) async {
    final String? districtId = location.city?.id;
    if (districtId == null || districtId.isEmpty) {
      throw const PrayerTimesSourceException(
        'diyanet',
        'İlçe kimliği yok (konum seçilmemiş).',
        isTransient: false,
      );
    }
    final int daySpan = endDate.difference(startDate).inDays;
    final DateTime first = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    );
    final DateTime last = DateTime(endDate.year, endDate.month, endDate.day);
    List<PrayerTimesDay> slice(List<PrayerTimesDay> days) => days
        .where(
          (PrayerTimesDay d) =>
              !d.date.isBefore(first) && !d.date.isAfter(last),
        )
        .toList();
    final int expected = daySpan + 1;

    // 1) **range** uç noktası: istenen aralığı birebir döndürür; ay sınırı
    //    sorunu yoktur ve `monthly`den büyük değildir.
    List<PrayerTimesDay>? ranged;
    try {
      ranged = slice(
        await _fetch(
          districtId,
          'range',
          query: <String, String>{
            'startDate': _isoDate(startDate),
            'endDate': _isoDate(endDate),
          },
        ),
      );
      if (ranged.isNotEmpty) {
        if (ranged.length >= expected) {
          lastEndpointLabel = 'Diyanet resmî servisi (aralık verisi)';
          return ranged;
        }
      }
    } catch (error) {
      lastError = _asSourceError(error).message;
    }

    // 2) Dönem uç noktası: uzun aralıklar için yıllık, kısa aralıklar için
    //    aylık. Ay sonunu aşan aralıkta eksik gün kalırsa yıllıktan tamamlanır.
    final String period = daySpan > 45 ? 'yearly' : 'monthly';
    String? label;
    List<PrayerTimesDay> days;
    try {
      days = slice(await _fetch(districtId, period));
      label = period == 'yearly'
          ? 'Diyanet resmî servisi (yıllık veri)'
          : 'Diyanet resmî servisi (aylık veri)';
      // Aylık veri aralığı kapsamıyorsa (ay sınırı) yıllıkla tamamlanır;
      // yıllık istek başarısız olsa bile eldeki aylık günler korunur.
      if (days.length < expected && period != 'yearly') {
        try {
          final List<PrayerTimesDay> yearly = slice(
            await _fetch(districtId, 'yearly'),
          );
          if (yearly.length > days.length) {
            days = yearly;
            label = 'Diyanet resmî servisi (yıllık veri)';
          }
        } catch (error) {
          AppLog.warning('Yıllık vakit verisi alınamadı', error: error);
        }
      }
      if (label != null && days.isNotEmpty) lastEndpointLabel = label;
    } catch (error) {
      // Aralık ucu bir kısmını getirdiyse tamamen kaybetmeyelim.
      if (ranged != null && ranged.isNotEmpty) {
        lastEndpointLabel = 'Diyanet resmî servisi (aralık verisi)';
        return ranged;
      }
      rethrow;
    }
    if (ranged == null || ranged.isEmpty) return days;
    if (ranged.length >= expected) {
      lastEndpointLabel = 'Diyanet resmî servisi (aralık verisi)';
      return ranged;
    }
    lastEndpointLabel = 'Diyanet resmî servisi (aylık + aralık verisi)';
    return _merge(ranged, days);
  }

  /// [base] içindeki günleri [extra] ile (varsa) tarihe göre birleştirir.
  static List<PrayerTimesDay> _merge(
    List<PrayerTimesDay> base,
    List<PrayerTimesDay> extra,
  ) {
    final Map<String, PrayerTimesDay> byDate = <String, PrayerTimesDay>{
      for (final PrayerTimesDay day in base) _dateKey(day.date): day,
      for (final PrayerTimesDay day in extra) _dateKey(day.date): day,
    };
    return byDate.values.toList()
      ..sort((PrayerTimesDay a, PrayerTimesDay b) => a.date.compareTo(b.date));
  }

  Future<List<PrayerTimesDay>> _fetch(
    String districtId,
    String period, {
    Map<String, String> query = const <String, String>{},
  }) async {
    final String apiDistrictId = _apiDistrictId(districtId);
    final String queryKey = query.isEmpty
        ? ''
        : '|${query.entries.map((MapEntry<String, String> e) => '${e.key}=${e.value}').join('&')}';
    final String cacheKey = '$apiDistrictId|$period$queryKey';
    final _CachedPeriod? hit = _periodCache[cacheKey];
    if (hit != null && DateTime.now().difference(hit.fetchedAt) < _memoryTtl) {
      return hit.days;
    }
    final Uri endpoint = Uri.parse(
      '$baseUrl/prayer-times/$apiDistrictId/$period',
    );
    final Uri uri = query.isEmpty
        ? endpoint
        : endpoint.replace(queryParameters: query);
    try {
      final http.Response response = await _get(uri);
      if (response.statusCode != 200) {
        throw PrayerTimesSourceException(
          'diyanet',
          'Servis ${response.statusCode} döndü.',
          isTransient: response.statusCode >= 500 || response.statusCode == 429,
        );
      }
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Map<String, Object?>> records = _extractRecords(decoded);
      if (records.isEmpty) {
        throw PrayerTimesSourceException(
          'diyanet',
          _messageOf(decoded) ?? 'Yanıt boş.',
          // Boş yanıt kalıcıdır (o ilçe için veri yok); ama 200 + boş yanıt
          // geçici bir bakım da olabilir, bir kez yedek yol denenir.
          isTransient: false,
        );
      }
      final List<PrayerTimesDay> days =
          records
              .map(_parseRecord)
              .where((PrayerTimesDay? d) => d != null)
              .cast<PrayerTimesDay>()
              .toList()
            ..sort(
              (PrayerTimesDay a, PrayerTimesDay b) => a.date.compareTo(b.date),
            );
      if (days.isEmpty) {
        throw const PrayerTimesSourceException(
          'diyanet',
          'Kayıtlar çözümlenemedi.',
        );
      }
      // Bellek sınırsız büyümesin: en fazla 40 dönem (≈2 yıl × birkaç ilçe).
      if (_periodCache.length >= 40) _periodCache.clear();
      _periodCache[cacheKey] = _CachedPeriod(days, DateTime.now());
      AppLog.debug('Diyanet API: ${days.length} gün alındı ($period)');
      return days;
    } on TimeoutException {
      throw const PrayerTimesSourceException('diyanet', 'Zaman aşımı.');
    } on PrayerTimesSourceException {
      rethrow;
    } catch (error) {
      throw PrayerTimesSourceException('diyanet', 'Bağlantı hatası: $error');
    }
  }

  /// **Yedek resmî sunucu** — `ezanvakti.emushaf.net/vakitler/{id}`.
  ///
  /// Eski EzanVakti uç noktası; aynı Diyanet verisini PascalCase alanlarla
  /// döndürür. Birincil servis çöktüğünde kullanıcı cihaz hesabına düşmesin
  /// diye eklendi.
  Future<List<PrayerTimesDay>> _fetchBackupHost(String districtId) async {
    final String apiDistrictId = _apiDistrictId(districtId);
    final String cacheKey = '$apiDistrictId|backup';
    final _CachedPeriod? hit = _periodCache[cacheKey];
    if (hit != null && DateTime.now().difference(hit.fetchedAt) < _memoryTtl) {
      return hit.days;
    }
    final Uri uri = Uri.parse('$fallbackBaseUrl/vakitler/$apiDistrictId');
    final http.Response response = await _client
        .get(uri, headers: const <String, String>{'Accept': 'application/json'})
        .timeout(_timeout);
    if (response.statusCode != 200) {
      throw PrayerTimesSourceException(
        'diyanet',
        'Yedek sunucu ${response.statusCode} döndü.',
        isTransient: response.statusCode >= 500,
      );
    }
    final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
    if (decoded is! List) {
      throw const PrayerTimesSourceException(
        'diyanet',
        'Yedek sunucu beklenmeyen yanıt döndürdü.',
      );
    }
    final List<PrayerTimesDay> days = <PrayerTimesDay>[];
    for (final Object? item in decoded) {
      if (item is! Map) continue;
      final PrayerTimesDay? day = _parseBackupRecord(
        item.cast<String, Object?>(),
      );
      if (day != null) days.add(day);
    }
    if (days.isEmpty) {
      throw const PrayerTimesSourceException(
        'diyanet',
        'Yedek sunucuda kayıt yok.',
        isTransient: false,
      );
    }
    days.sort((PrayerTimesDay a, PrayerTimesDay b) => a.date.compareTo(b.date));
    if (_periodCache.length >= 40) _periodCache.clear();
    _periodCache[cacheKey] = _CachedPeriod(days, DateTime.now());
    return days;
  }

  /// Tek istek + yalnızca **5xx** için tek tekrar denemesi.
  ///
  /// Zaman aşımında yeniden denemek açılışı iki katı bekletiyordu; artık
  /// zaman aşımı doğrudan bir sonraki (daha ucuz) yola bırakılır.
  Future<http.Response> _get(Uri uri) async {
    const Map<String, String> headers = <String, String>{
      'Accept': 'application/json',
    };
    final http.Response first = await _client
        .get(uri, headers: headers)
        .timeout(_timeout);
    if (first.statusCode < 500) return first;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    return _client.get(uri, headers: headers).timeout(_timeout);
  }

  /// İlçe kimliğini servisin beklediği biçime çevirir.
  ///
  /// Veri kümesindeki yeni ilçeler `9541_bagcilar` gibi üretilmiş kimlikler
  /// taşır. Servis bu kimlikleri tanımaz; ancak aynı ilçeleri il (9541)
  /// verisiyle eşler (API'de `url` alanı da il merkezini gösterir). Bu yüzden
  /// alt çizgiden sonrası atılır.
  static String _apiDistrictId(String districtId) =>
      districtId.split('_').first;

  PrayerTimesDay? _findDay(List<PrayerTimesDay> days, DateTime date) =>
      days.firstWhereOrNull((PrayerTimesDay d) => _sameDay(d.date, date));

  /// Farklı yanıt zarflarını tolere eder: `{data: [...]}`, `[...]`, `{data: {items: []}}`.
  List<Map<String, Object?>> _extractRecords(Object? decoded) {
    List<Map<String, Object?>> castList(Object? value) {
      if (value is List) {
        return value
            .whereType<Map<Object?, Object?>>()
            .map((Map<Object?, Object?> m) => m.cast<String, Object?>())
            .toList();
      }
      return <Map<String, Object?>>[];
    }

    if (decoded is List) return castList(decoded);
    if (decoded is Map) {
      final Map<String, Object?> map = decoded.cast<String, Object?>();
      final Object? data = map['data'] ?? map['results'] ?? map['items'];
      if (data is List) return castList(data);
      if (data is Map) {
        final Map<String, Object?> nested = data.cast<String, Object?>();
        for (final String key in <String>[
          'items',
          'records',
          'times',
          'prayerTimes',
        ]) {
          final List<Map<String, Object?>> found = castList(nested[key]);
          if (found.isNotEmpty) return found;
        }
        // Tek kayıt: tarih anahtarlı sözlük olabilir.
        final List<Map<String, Object?>> dateKeyed = _fromDateKeyedMap(nested);
        if (dateKeyed.isNotEmpty) return dateKeyed;
      }
      final List<Map<String, Object?>> dateKeyed = _fromDateKeyedMap(map);
      if (dateKeyed.isNotEmpty) return dateKeyed;
    }
    return <Map<String, Object?>>[];
  }

  /// `{"message": "..."}` alanından kullanıcıya gösterilebilir nedeni çıkarır.
  static String? _messageOf(Object? decoded) {
    if (decoded is! Map) return null;
    final Object? message = decoded['message'] ?? decoded['error'];
    return message is String && message.trim().isNotEmpty
        ? message.trim()
        : null;
  }

  /// `{"2026-01-01": {"imsak": "06:15", ...}}` biçimini kayıtlara çevirir.
  List<Map<String, Object?>> _fromDateKeyedMap(Map<String, Object?> map) {
    final List<Map<String, Object?>> records = <Map<String, Object?>>[];
    final RegExp datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}');
    map.forEach((String key, Object? value) {
      if (datePattern.hasMatch(key) && value is Map) {
        records.add(<String, Object?>{
          'date': key,
          ...(value as Map<Object?, Object?>).cast<String, Object?>(),
        });
      }
    });
    return records;
  }

  PrayerTimesDay? _parseRecord(Map<String, Object?> record) {
    final Object? rawDate =
        record['date'] ??
        record['miladiTarihKisaIso8601'] ??
        record['gregorianDate'];
    if (rawDate is! String) return null;
    final DateTime? date = DateTime.tryParse(rawDate.split('T').first);
    if (date == null) return null;

    final Map<String, Object?> times =
        (record['times'] as Map?)?.cast<String, Object?>() ?? record;

    DateTime? parseTime(Object? value) {
      if (value is! String) return null;
      final List<String> parts = value.split(':');
      if (parts.length < 2) return null;
      final int? hour = int.tryParse(parts[0]);
      final int? minute = int.tryParse(parts[1]);
      if (hour == null || minute == null || hour > 23 || minute > 59) {
        return null;
      }
      return DateTime(date.year, date.month, date.day, hour, minute);
    }

    final Map<Prayer, DateTime> mapped = <Prayer, DateTime>{};
    for (final Prayer prayer in Prayer.values) {
      final DateTime? parsed = parseTime(
        times[prayer.key] ?? times[_alternativeKey(prayer)],
      );
      if (parsed == null) return null;
      mapped[prayer] = parsed;
    }

    String? hijri;
    final Map<String, Object?>? hijriRaw = (record['hijri_date'] as Map?)
        ?.cast<String, Object?>();
    if (hijriRaw != null) {
      hijri =
          hijriRaw['full_date'] as String? ??
          '${hijriRaw['day']} ${hijriRaw['month_name']} ${hijriRaw['year']}';
    } else {
      hijri = record['hicriTarihUzun'] as String?;
    }

    return PrayerTimesDay(
      date: DateTime(date.year, date.month, date.day),
      times: mapped,
      source: id,
      hijriDate: hijri,
      cachedAt: DateTime.now(),
    );
  }

  /// Yedek sunucunun PascalCase kaydını çözümler.
  PrayerTimesDay? _parseBackupRecord(Map<String, Object?> record) {
    final Object? rawDate =
        record['MiladiTarihKisaIso8601'] ??
        record['MiladiTarihUzunIso8601'] ??
        record['MiladiTarihKisa'];
    if (rawDate is! String) return null;

    DateTime? date;
    final String value = rawDate.split('T').first.trim();
    if (value.contains('.')) {
      // 03.11.2026 (gün.ay.yıl)
      final List<String> parts = value.split('.');
      if (parts.length >= 3) {
        final int? day = int.tryParse(parts[0]);
        final int? month = int.tryParse(parts[1]);
        final int? year = int.tryParse(parts[2]);
        if (day != null && month != null && year != null) {
          date = DateTime(year, month, day);
        }
      }
    } else {
      date = DateTime.tryParse(value);
    }
    if (date == null) return null;

    DateTime? parseTime(Object? raw) {
      if (raw is! String) return null;
      final List<String> parts = raw.split(':');
      if (parts.length < 2) return null;
      final int? hour = int.tryParse(parts[0]);
      final int? minute = int.tryParse(parts[1]);
      if (hour == null || minute == null || hour > 23 || minute > 59) {
        return null;
      }
      return DateTime(date!.year, date.month, date.day, hour, minute);
    }

    final Map<Prayer, DateTime?> rawTimes = <Prayer, DateTime?>{
      Prayer.imsak: parseTime(record['Imsak']),
      Prayer.gunes: parseTime(record['Gunes'] ?? record['GunesDogus']),
      Prayer.ogle: parseTime(record['Ogle']),
      Prayer.ikindi: parseTime(record['Ikindi']),
      Prayer.aksam: parseTime(record['Aksam']),
      Prayer.yatsi: parseTime(record['Yatsi']),
    };
    final Map<Prayer, DateTime> mapped = <Prayer, DateTime>{};
    for (final MapEntry<Prayer, DateTime?> entry in rawTimes.entries) {
      final DateTime? time = entry.value;
      if (time == null) return null;
      mapped[entry.key] = time;
    }

    return PrayerTimesDay(
      date: DateTime(date.year, date.month, date.day),
      times: mapped,
      source: id,
      hijriDate: record['HicriTarihUzun'] as String?,
      cachedAt: DateTime.now(),
    );
  }

  String _alternativeKey(Prayer prayer) => switch (prayer) {
    Prayer.imsak => 'Imsak',
    Prayer.gunes => 'Sunrise',
    Prayer.ogle => 'Dhuhr',
    Prayer.ikindi => 'Asr',
    Prayer.aksam => 'Maghrib',
    Prayer.yatsi => 'Isha',
  };

  static bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month}-${date.day}';

  /// `YYYY-MM-DD` — servis ISO 8601 tarih bekler.
  static String _isoDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static PrayerTimesSourceException _asSourceError(Object error) =>
      error is PrayerTimesSourceException
      ? error
      : PrayerTimesSourceException('diyanet', 'Beklenmeyen hata: $error');

  /// Bellek önbelleğini temizler (zorla yenileme / tanılama).
  void clearMemoryCache() {
    _periodCache.clear();
    lastError = null;
  }

  void dispose() {
    _periodCache.clear();
    _client.close();
  }
}

/// Bellekte tutulan dönem yanıtı.
class _CachedPeriod {
  const _CachedPeriod(this.days, this.fetchedAt);

  final List<PrayerTimesDay> days;
  final DateTime fetchedAt;
}

extension _FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
