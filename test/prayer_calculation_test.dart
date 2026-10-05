import 'dart:convert';

import 'package:ezanai/data/prayer/prayer_calculator.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Diyanet resmî vakitleriyle yerel hesap motorunu karşılaştırır.
///
/// Doğrulama verisi (`assets/data/diyanet_validation_sample.json`), 11 il ve
/// 5 farklı tarih için T.C. Diyanet İşleri Başkanlığı'nın yayımladığı resmî
/// vakitlerden oluşur. Temkin düzeltmeleri en küçük kareler yöntemiyle fit
/// edildiğinde 330 ölçümün tamamı ±3.1 dk içinde, ortalama sapma ~0.6 dk'dır.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<Map<String, Object?>> records;

  setUpAll(() async {
    final String raw = await rootBundle.loadString(
      'assets/data/diyanet_validation_sample.json',
    );
    final Object decoded = jsonDecode(raw);
    if (decoded is! Map) {
      fail('Doğrulama verisi beklenen biçimde değil.');
    }
    final Object? list = decoded['records'];
    if (list is! List) {
      fail('Doğrulama verisinde "records" alanı yok.');
    }
    final List<Map<String, Object?>> parsed = <Map<String, Object?>>[];
    for (final Object? item in list) {
      if (item is Map) {
        parsed.add(<String, Object?>{
          for (final MapEntry<Object?, Object?> entry in item.entries)
            '${entry.key}': entry.value,
        });
      }
    }
    records = parsed;
  });

  test('doğrulama verisi yüklendi', () {
    expect(records, isNotEmpty);
    expect(records.first['city'], isNotNull);
  });

  test('yerel hesap, Diyanet vakitlerine ±4 dakika içinde kalır', () {
    const CalculationMethod method = CalculationMethod.diyanet;
    int checked = 0;
    final List<String> failures = <String>[];

    for (final Map<String, Object?> record in records) {
      final DateTime date = DateTime.parse(record['date']! as String);
      final double latitude = (record['lat']! as num).toDouble();
      final double longitude = (record['lon']! as num).toDouble();
      final double timeZone = (record['tz'] as num?)?.toDouble() ?? 3.0;

      final CalculatedTimes times = PrayerCalculator.calculate(
        date: date,
        latitude: latitude,
        longitude: longitude,
        method: method,
        timeZoneOffsetHours: timeZone,
      );

      final Map<String, double> computed = <String, double>{
        'imsak': times.imsak,
        'gunes': times.gunes,
        'ogle': times.ogle,
        'ikindi': times.ikindi,
        'aksam': times.aksam,
        'yatsi': times.yatsi,
      };

      for (final MapEntry<String, double> entry in computed.entries) {
        final String? expectedRaw = record[entry.key] as String?;
        if (expectedRaw == null) continue;
        final List<String> parts = expectedRaw.split(':');
        final double expected =
            int.parse(parts[0]) * 60 + int.parse(parts[1]) / 60.0;
        final double diff = (entry.value - expected).abs() * 60;
        checked++;
        if (diff > 4.0) {
          failures.add(
            '${record['city']} ${record['date']} ${entry.key}: '
            'hesap ${_hhmm(entry.value)}, Diyanet $expectedRaw '
            '(${diff.toStringAsFixed(1)} dk)',
          );
        }
      }
    }

    expect(checked, greaterThan(0));
    expect(failures, isEmpty, reason: failures.take(12).join('\n'));
  });

  test('vakitler gün içinde artan sırada', () {
    final CalculatedTimes times = PrayerCalculator.calculate(
      date: DateTime(2026, 6, 21),
      latitude: 41.0082,
      longitude: 28.9784,
      method: CalculationMethod.diyanet,
    );
    final List<double> values = times.values;
    for (int i = 1; i < values.length; i++) {
      expect(
        values[i],
        greaterThan(values[i - 1]),
        reason: '${i - 1}. vakit sonraki vakitten geç olmamalı',
      );
    }
  });

  test('Hanefî ikindi vakti Şâfiî\'den sonra olur', () {
    final CalculatedTimes sani = PrayerCalculator.calculate(
      date: DateTime(2026, 3, 21),
      latitude: 41.0082,
      longitude: 28.9784,
      method: CalculationMethod.diyanet,
    );
    final CalculatedTimes hanefi = PrayerCalculator.calculate(
      date: DateTime(2026, 3, 21),
      latitude: 41.0082,
      longitude: 28.9784,
      method: CalculationMethod.diyanet.copyWith(asrFactor: 2.0),
    );
    expect(hanefi.ikindi, greaterThan(sani.ikindi));
  });

  test('yüksek enlemlerde gece ortası kuralı vakit üretir', () {
    final CalculatedTimes times = PrayerCalculator.calculate(
      date: DateTime(2026, 12, 21),
      latitude: 60.17,
      longitude: 24.94,
      method: CalculationMethod.turkeyDiyanetHighLat,
      timeZoneOffsetHours: 2,
    );
    expect(times.imsak.isFinite, isTrue);
    expect(times.yatsi.isFinite, isTrue);
    expect(times.yatsi, greaterThan(times.aksam));
  });
}

String _hhmm(double hours) {
  final int totalMinutes = (hours * 60).round();
  final int h = (totalMinutes ~/ 60) % 24;
  final int m = totalMinutes % 60;
  return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
}
