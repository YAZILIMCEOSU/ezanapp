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
/// Zincir: önce `yearly` (tam yıl, tek istek), başarısızsa `monthly`.
class DiyanetApiSource implements PrayerTimesSource {
  DiyanetApiSource({
    http.Client? client,
    this.baseUrl = 'https://ezanvakti.imsakiyem.com/api',
  }) : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const Duration _timeout = Duration(seconds: 12);

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
    final String? districtId = location.city?.id;
    if (districtId == null || districtId.isEmpty) {
      throw const PrayerTimesSourceException(
        'diyanet',
        'İlçe kimliği yok (konum seçilmemiş).',
      );
    }
    final List<PrayerTimesDay> days = await _fetch(districtId, 'monthly');
    final PrayerTimesDay? day = days.firstWhereOrNull(
      (PrayerTimesDay d) => _sameDay(d.date, date),
    );
    if (day == null) {
      throw const PrayerTimesSourceException(
        'diyanet',
        'İstenen gün resmî veride bulunamadı.',
      );
    }
    return day;
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
      );
    }
    final int daySpan = endDate.difference(startDate).inDays;
    // Uzun aralıklar için yıllık uç nokta tek istekle döner.
    final List<PrayerTimesDay> days = await _fetch(
      districtId,
      daySpan > 45 ? 'yearly' : 'monthly',
    );
    return days
        .where(
          (PrayerTimesDay d) =>
              !d.date.isBefore(
                DateTime(startDate.year, startDate.month, startDate.day),
              ) &&
              !d.date.isAfter(
                DateTime(endDate.year, endDate.month, endDate.day),
              ),
        )
        .toList();
  }

  Future<List<PrayerTimesDay>> _fetch(String districtId, String period) async {
    final Uri uri = Uri.parse('$baseUrl/prayer-times/$districtId/$period');
    try {
      final http.Response response = await _client
          .get(
            uri,
            headers: const <String, String>{'Accept': 'application/json'},
          )
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw PrayerTimesSourceException(
          'diyanet',
          'Servis ${response.statusCode} döndü.',
          isTransient: response.statusCode >= 500,
        );
      }
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Map<String, Object?>> records = _extractRecords(decoded);
      if (records.isEmpty) {
        throw const PrayerTimesSourceException('diyanet', 'Yanıt boş.');
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

  void dispose() => _client.close();
}

extension _FirstWhereOrNull<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final E element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
