import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/logger.dart';
import '../models/city.dart';
import '../models/prayer.dart';
import '../models/prayer_times_day.dart';
import 'prayer_calculator.dart';
import 'prayer_times_source.dart';

/// Uluslararası alternatif vakit servisi (AlAdhan).
///
/// Diyanet verisi alınamadığında (yurt dışı, servis kesintisi) kullanılan
/// ikinci kaynak. Method parametresi uygulamanın seçili yöntemine eşlenir.
class AladhanApiSource implements PrayerTimesSource {
  AladhanApiSource({http.Client? client, this.baseUrl = 'https://api.aladhan.com/v1'})
      : _client = client ?? http.Client();

  final http.Client _client;
  final String baseUrl;

  static const Duration _timeout = Duration(seconds: 12);

  @override
  String get id => 'aladhan';

  @override
  String get label => 'Uluslararası servis (AlAdhan)';

  @override
  String get description =>
      'Dünya genelinde 200+ ülke için çalışan alternatif vakit servisi; '
      'Diyanet verisi alınamazsa devreye girer.';

  @override
  bool get requiresNetwork => true;

  @override
  Future<PrayerTimesDay> fetchDay({
    required UserLocation location,
    required DateTime date,
    required CalculationMethod method,
  }) async {
    final Uri uri = Uri.parse(
      '$baseUrl/timings/${_formatDate(date)}'
      '?latitude=${location.latitude}&longitude=${location.longitude}'
      '&method=${_methodParameter(method)}&school=${method.asrFactor >= 2 ? 1 : 0}',
    );
    try {
      final http.Response response = await _client
          .get(uri, headers: const <String, String>{'Accept': 'application/json'})
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw PrayerTimesSourceException('aladhan', 'Servis ${response.statusCode} döndü.',
            isTransient: response.statusCode >= 500);
      }
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) {
        throw const PrayerTimesSourceException('aladhan', 'Beklenmeyen yanıt biçimi.');
      }
      final Map<String, Object?> root = decoded.cast<String, Object?>();
      final Map<String, Object?> data = (root['data'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
      final Map<String, Object?> timings = (data['timings'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
      if (timings.isEmpty) {
        throw const PrayerTimesSourceException('aladhan', 'Vakit verisi boş.');
      }

      DateTime? parse(Object? value) {
        if (value is! String) return null;
        final String cleaned = value.split(' ').first.trim();
        final List<String> parts = cleaned.split(':');
        if (parts.length < 2) return null;
        final int? hour = int.tryParse(parts[0]);
        final int? minute = int.tryParse(parts[1]);
        if (hour == null || minute == null || hour > 23 || minute > 59) return null;
        return DateTime(date.year, date.month, date.day, hour, minute);
      }

      final Map<Prayer, DateTime> mapped = <Prayer, DateTime>{
        Prayer.imsak: parse(timings['Fajr']),
        Prayer.gunes: parse(timings['Sunrise']),
        Prayer.ogle: parse(timings['Dhuhr']),
        Prayer.ikindi: parse(timings['Asr']),
        Prayer.aksam: parse(timings['Maghrib']),
        Prayer.yatsi: parse(timings['Isha']),
      }..removeWhere((Prayer key, DateTime? value) => value == null);
      if (mapped.length < Prayer.values.length) {
        throw const PrayerTimesSourceException('aladhan', 'Vakitlerin tamamı çözümlenemedi.');
      }

      final Map<String, Object?> hijriRaw = (data['date'] as Map?)?.cast<String, Object?>() ??
          <String, Object?>{};
      final Map<String, Object?> hijri =
          (hijriRaw['hijri'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
      final String? hijriLabel = hijri.isEmpty
          ? null
          : '${hijri['day']} ${(hijri['month'] as Map?)?.cast<String, Object?>()?['tr'] ?? (hijri['month'] as Map?)?.cast<String, Object?>()?['en']} ${hijri['year']}';

      return PrayerTimesDay(
        date: DateTime(date.year, date.month, date.day),
        times: mapped,
        source: id,
        hijriDate: hijriLabel,
        cachedAt: DateTime.now(),
      );
    } on TimeoutException {
      throw const PrayerTimesSourceException('aladhan', 'Zaman aşımı.');
    } on PrayerTimesSourceException {
      rethrow;
    } catch (error) {
      throw PrayerTimesSourceException('aladhan', 'Bağlantı hatası: $error');
    }
  }

  @override
  Future<List<PrayerTimesDay>> fetchRange({
    required UserLocation location,
    required DateTime startDate,
    required DateTime endDate,
    required CalculationMethod method,
  }) async {
    // AlAdhan aralık uç noktası gün bazlı liste döner (en fazla 1 yıl).
    final Uri uri = Uri.parse(
      '$baseUrl/calendar/${startDate.year}/${startDate.month}'
      '?latitude=${location.latitude}&longitude=${location.longitude}'
      '&method=${_methodParameter(method)}&school=${method.asrFactor >= 2 ? 1 : 0}',
    );
    try {
      final http.Response response = await _client
          .get(uri, headers: const <String, String>{'Accept': 'application/json'})
          .timeout(_timeout);
      if (response.statusCode != 200) {
        throw PrayerTimesSourceException('aladhan', 'Servis ${response.statusCode} döndü.');
      }
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final Map<String, Object?> root = (decoded as Map).cast<String, Object?>();
      final List<Object?> data = (root['data'] as List?) ?? <Object?>[];
      final List<PrayerTimesDay> days = <PrayerTimesDay>[];
      for (final Object? item in data) {
        if (item is! Map) continue;
        final Map<String, Object?> record = item.cast<String, Object?>();
        final Map<String, Object?> gregorian =
            ((record['date'] as Map?)?.cast<String, Object?>()?['gregorian'] as Map?)
                    ?.cast<String, Object?>() ??
                <String, Object?>{};
        final DateTime? date = DateTime.tryParse(gregorian['date'] as String? ?? '');
        if (date == null) continue;
        final Map<String, Object?> timings =
            (record['timings'] as Map?)?.cast<String, Object?>() ?? <String, Object?>{};
        DateTime? parse(Object? value) {
          if (value is! String) return null;
          final List<String> parts = value.split(' ').first.trim().split(':');
          if (parts.length < 2) return null;
          final int? hour = int.tryParse(parts[0]);
          final int? minute = int.tryParse(parts[1]);
          if (hour == null || minute == null) return null;
          return DateTime(date.year, date.month, date.day, hour, minute);
        }

        final Map<Prayer, DateTime> mapped = <Prayer, DateTime>{
          Prayer.imsak: parse(timings['Fajr']),
          Prayer.gunes: parse(timings['Sunrise']),
          Prayer.ogle: parse(timings['Dhuhr']),
          Prayer.ikindi: parse(timings['Asr']),
          Prayer.aksam: parse(timings['Maghrib']),
          Prayer.yatsi: parse(timings['Isha']),
        }..removeWhere((Prayer key, DateTime? value) => value == null);
        if (mapped.length == Prayer.values.length) {
          days.add(PrayerTimesDay(
            date: DateTime(date.year, date.month, date.day),
            times: mapped,
            source: id,
            cachedAt: DateTime.now(),
          ));
        }
      }
      if (days.isEmpty) {
        throw const PrayerTimesSourceException('aladhan', 'Aralık verisi boş.');
      }
      days.sort((PrayerTimesDay a, PrayerTimesDay b) => a.date.compareTo(b.date));
      return days;
    } on PrayerTimesSourceException {
      rethrow;
    } catch (error) {
      AppLog.warning('AlAdhan aralık isteği başarısız', error: error);
      throw PrayerTimesSourceException('aladhan', 'Aralık verisi alınamadı: $error');
    }
  }

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';

  /// AlAdhan yöntem kodları: Diyanet için 13 (Turkey Religious Affairs).
  int _methodParameter(CalculationMethod method) => switch (method.id) {
        'diyanet' || 'diyanet_high_lat' => 13,
        'mwl' => 3,
        'isna' => 2,
        'egypt' => 5,
        'umm_al_qura' => 4,
        'karachi' => 1,
        'tehran' => 7,
        'jafari' => 0,
        'gulf' => 8,
        'kuwait' => 9,
        'qatar' => 10,
        'singapore' => 11,
        'france' => 12,
        'russia' => 14,
        _ => 13,
      };

  void dispose() => _client.close();
}
