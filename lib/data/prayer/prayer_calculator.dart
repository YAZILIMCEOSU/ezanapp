/// Namaz vakti hesaplama motoru.
///
/// Astronomik olarak güneşin konumu (deklinasyon + zaman denklemi) NOAA
/// algoritmasıyla hesaplanır; ardından Diyanet İşleri Başkanlığı'nın
/// kullandığı "temkin" düzeltmeleri uygulanır.
///
/// Model, T.C. Diyanet İşleri Başkanlığı'nın yayımladığı **37.379 resmî
/// namaz vakti kaydı** (81 il, 495 gün) ile doğrulanmıştır: tüm vakitlerde
/// ortalama sapma ±0,2 dakika, standart sapma ≈1,5 dakikadır
/// (bkz. `test/prayer_calculation_test.dart`).
library;

import 'dart:math' as math;


const double _degreesToRadians = math.pi / 180.0;
const double _radiansToDegrees = 180.0 / math.pi;

/// Vakit hesabında kullanılan yöntem (fıkhi/astronomik parametre seti).
class CalculationMethod {
  const CalculationMethod({
    required this.id,
    required this.name,
    required this.description,
    required this.fajrAngle,
    required this.ishaAngle,
    this.ishaIntervalMinutes,
    this.maghribAngle = 0.833,
    this.sunriseAngle = 0.833,
    this.asrFactor = 1.0,
    this.temkin = Temkin.diyanet,
    this.highLatitudeRule = HighLatitudeRule.none,
    this.country = '',
    this.manualOffsets = const <String, int>{},
  });

  final String id;
  final String name;
  final String description;

  /// İmsak/şafak açısı (ufkun altında, derece).
  final double fajrAngle;

  /// Yatsı açısı (ufkun altında, derece).
  final double ishaAngle;

  /// Yatsı bunun yerine akşamdan sabit dakika sonra hesaplanır (ör. Umm al-Qura 90).
  final int? ishaIntervalMinutes;

  /// Akşam/şafak güneş yüksekliği.
  final double maghribAngle;
  final double sunriseAngle;

  /// 1 = Şâfiî/Mâlikî/Hanbelî, 2 = Hanefî ("asr-i sânî").
  final double asrFactor;

  final Temkin temkin;
  final HighLatitudeRule highLatitudeRule;
  final String country;

  /// Kullanıcının vakit bazlı manuel düzeltmeleri (dakika).
  final Map<String, int> manualOffsets;

  CalculationMethod copyWith({
    String? id,
    String? name,
    String? description,
    double? fajrAngle,
    double? ishaAngle,
    int? ishaIntervalMinutes,
    double? maghribAngle,
    double? sunriseAngle,
    double? asrFactor,
    Temkin? temkin,
    HighLatitudeRule? highLatitudeRule,
    String? country,
    Map<String, int>? manualOffsets,
  }) =>
      CalculationMethod(
        id: id ?? this.id,
        name: name ?? this.name,
        description: description ?? this.description,
        fajrAngle: fajrAngle ?? this.fajrAngle,
        ishaAngle: ishaAngle ?? this.ishaAngle,
        ishaIntervalMinutes: ishaIntervalMinutes ?? this.ishaIntervalMinutes,
        maghribAngle: maghribAngle ?? this.maghribAngle,
        sunriseAngle: sunriseAngle ?? this.sunriseAngle,
        asrFactor: asrFactor ?? this.asrFactor,
        temkin: temkin ?? this.temkin,
        highLatitudeRule: highLatitudeRule ?? this.highLatitudeRule,
        country: country ?? this.country,
        manualOffsets: manualOffsets ?? this.manualOffsets,
      );

  /// T.C. Diyanet İşleri Başkanlığı (uygulamanın varsayılanı).
  static const CalculationMethod diyanet = CalculationMethod(
    id: 'diyanet',
    name: 'Diyanet İşleri Başkanlığı',
    description: 'Türkiye Cumhuriyeti Diyanet İşleri Başkanlığı resmî parametreleri '
        '(imsak 18°, yatsı 17°, temkin düzeltmeleri dahil).',
    fajrAngle: 18.0,
    ishaAngle: 17.0,
    country: 'Türkiye',
  );

  static const CalculationMethod mwl = CalculationMethod(
    id: 'mwl',
    name: 'Müslüman Dünya Ligi (MWL)',
    description: 'Muslim World League — imsak 18°, yatsı 17°, temkin uygulanmaz.',
    fajrAngle: 18.0,
    ishaAngle: 17.0,
    temkin: Temkin.none,
    country: 'Avrupa / Genel',
  );

  static const CalculationMethod isna = CalculationMethod(
    id: 'isna',
    name: 'ISNA (Kuzey Amerika)',
    description: 'Islamic Society of North America — imsak 15°, yatsı 15°.',
    fajrAngle: 15.0,
    ishaAngle: 15.0,
    temkin: Temkin.none,
    country: 'ABD / Kanada',
  );

  static const CalculationMethod egypt = CalculationMethod(
    id: 'egypt',
    name: 'Mısır Genel Araştırma Kurumu',
    description: 'Egyptian General Authority of Survey — imsak 19.5°, yatsı 17.5°.',
    fajrAngle: 19.5,
    ishaAngle: 17.5,
    temkin: Temkin.none,
    country: 'Mısır / Afrika',
  );

  static const CalculationMethod ummAlQura = CalculationMethod(
    id: 'umm_al_qura',
    name: 'Ümmü’l-Kurâ (Mekke)',
    description: 'Mekke Ümmü’l-Kurâ takvimi — imsak 18.5°, yatsı akşamdan 90 dk sonra.',
    fajrAngle: 18.5,
    ishaAngle: 0,
    ishaIntervalMinutes: 90,
    temkin: Temkin.none,
    country: 'Suudi Arabistan',
  );

  static const CalculationMethod karachi = CalculationMethod(
    id: 'karachi',
    name: 'Karaçi İslamî İlimler Üniversitesi',
    description: 'University of Islamic Sciences, Karachi — imsak 18°, yatsı 18°, Hanefî ikindi.',
    fajrAngle: 18.0,
    ishaAngle: 18.0,
    asrFactor: 2.0,
    temkin: Temkin.none,
    country: 'Pakistan / Hindistan',
  );

  static const CalculationMethod tehran = CalculationMethod(
    id: 'tehran',
    name: 'Tahran Jeofizik Enstitüsü',
    description: 'Institute of Geophysics, University of Tehran — imsak 17.7°, yatsı 14°.',
    fajrAngle: 17.7,
    ishaAngle: 14.0,
    temkin: Temkin.none,
    country: 'İran',
  );

  static const CalculationMethod jafari = CalculationMethod(
    id: 'jafari',
    name: 'Caferî (Şia İmâmiyye)',
    description: 'Shia Ithna-Ashari — imsak 16°, yatsı 14°, akşam 4° alacakaranlık.',
    fajrAngle: 16.0,
    ishaAngle: 14.0,
    maghribAngle: 4.0,
    temkin: Temkin.none,
    country: 'İran / Irak',
  );

  static const CalculationMethod gulf = CalculationMethod(
    id: 'gulf',
    name: 'Körfez Bölgesi',
    description: 'Gulf Region — imsak 19.5°, yatsı akşamdan 90 dk sonra.',
    fajrAngle: 19.5,
    ishaAngle: 0,
    ishaIntervalMinutes: 90,
    temkin: Temkin.none,
    country: 'Körfez ülkeleri',
  );

  static const CalculationMethod kuwait = CalculationMethod(
    id: 'kuwait',
    name: 'Kuveyt',
    description: 'Kuwait — imsak 18°, yatsı 17.5°.',
    fajrAngle: 18.0,
    ishaAngle: 17.5,
    temkin: Temkin.none,
    country: 'Kuveyt',
  );

  static const CalculationMethod qatar = CalculationMethod(
    id: 'qatar',
    name: 'Katar',
    description: 'Qatar — imsak 18°, yatsı akşamdan 90 dk sonra.',
    fajrAngle: 18.0,
    ishaAngle: 0,
    ishaIntervalMinutes: 90,
    temkin: Temkin.none,
    country: 'Katar',
  );

  static const CalculationMethod singapore = CalculationMethod(
    id: 'singapore',
    name: 'Singapur / Güneydoğu Asya',
    description: 'Majlis Ugama Islam Singapura — imsak 20°, yatsı 18°.',
    fajrAngle: 20.0,
    ishaAngle: 18.0,
    temkin: Temkin.none,
    country: 'Singapur / Malezya',
  );

  static const CalculationMethod france = CalculationMethod(
    id: 'france',
    name: 'Fransa (UOIF)',
    description: 'Union des Organisations Islamiques de France — 12° temkin yaklaşımı.',
    fajrAngle: 12.0,
    ishaAngle: 12.0,
    temkin: Temkin.none,
    highLatitudeRule: HighLatitudeRule.angleBased,
    country: 'Fransa',
  );

  static const CalculationMethod russia = CalculationMethod(
    id: 'russia',
    name: 'Rusya / Kafkasya',
    description: 'Spiritual Administration of Muslims of Russia — imsak 16°, yatsı 15°.',
    fajrAngle: 16.0,
    ishaAngle: 15.0,
    temkin: Temkin.none,
    highLatitudeRule: HighLatitudeRule.angleBased,
    country: 'Rusya / Kafkasya',
  );

  static const CalculationMethod turkeyDiyanetHighLat = CalculationMethod(
    id: 'diyanet_high_lat',
    name: 'Diyanet (yüksek enlem kuralı)',
    description: 'Diyanet parametreleri + gece ortası kuralı (48° üzeri enlemler için).',
    fajrAngle: 18.0,
    ishaAngle: 17.0,
    highLatitudeRule: HighLatitudeRule.middleOfNight,
    country: 'Kuzey Avrupa',
  );

  static const List<CalculationMethod> all = <CalculationMethod>[
    diyanet,
    mwl,
    isna,
    egypt,
    ummAlQura,
    karachi,
    tehran,
    jafari,
    gulf,
    kuwait,
    qatar,
    singapore,
    france,
    russia,
    turkeyDiyanetHighLat,
  ];

  static CalculationMethod fromId(String? id) =>
      all.firstWhere((CalculationMethod m) => m.id == id, orElse: () => diyanet);
}

/// Temkin (tedbir) düzeltmeleri — dakika cinsinden.
class Temkin {
  const Temkin({
    this.imsak = 0,
    this.gunes = 0,
    this.ogle = 0,
    this.ikindi = 0,
    this.aksam = 0,
    this.yatsi = 0,
  });

  final int imsak;
  final int gunes;
  final int ogle;
  final int ikindi;
  final int aksam;
  final int yatsi;

  static const Temkin none = Temkin();

  /// Diyanet resmî vakitleriyle kalibre edilmiş düzeltmeler.
  static const Temkin diyanet = Temkin(
    imsak: 0,
    gunes: -7,
    ogle: 5,
    ikindi: 4,
    aksam: 7,
    yatsi: 0,
  );
}

/// Yüksek enlem kuralı (48° üzerindeki bölgeler için).
enum HighLatitudeRule {
  none('Yok'),
  middleOfNight('Gecenin ortası'),
  seventhOfNight('Gecenin 1/7’si'),
  angleBased('Açıya dayalı');

  const HighLatitudeRule(this.label);

  final String label;
}

/// Günün ham astronomik verisi.
class _SunData {
  const _SunData(this.declination, this.equationOfTime);

  final double declination;
  final double equationOfTime;
}

/// Bir günün hesaplanmış vakitleri (yerel saat, dakika cinsinden gece yarısından).
class CalculatedTimes {
  const CalculatedTimes({
    required this.imsak,
    required this.gunes,
    required this.ogle,
    required this.ikindi,
    required this.aksam,
    required this.yatsi,
  });

  final double imsak;
  final double gunes;
  final double ogle;
  final double ikindi;
  final double aksam;
  final double yatsi;

  List<double> get values => <double>[imsak, gunes, ogle, ikindi, aksam, yatsi];
}

abstract final class PrayerCalculator {
  /// Belirtilen gün, koordinat ve yöntem için vakitleri hesaplar.
  ///
  /// [date] yerel saat diliminde günü belirtir; [timeZoneOffsetHours] o günün
  /// UTC farkıdır (Türkiye için yaz saati dahil 3.0).
  static CalculatedTimes calculate({
    required DateTime date,
    required double latitude,
    required double longitude,
    required CalculationMethod method,
    double timeZoneOffsetHours = 3.0,
    double elevationMeters = 0,
    Map<String, int> manualOffsets = const <String, int>{},
  }) {
    final double julianDay = _julianDay(date.year, date.month, date.day) +
        (12.0 - timeZoneOffsetHours) / 24.0;
    _SunData sun = _sunPosition(julianDay);

    // Zaman denklemi için iki kez yinele (öğle vakti hassasiyeti).
    double dhuhr = 0;
    for (int i = 0; i < 3; i++) {
      dhuhr = 12.0 + timeZoneOffsetHours - longitude / 15.0 - sun.equationOfTime;
      final double refineJd = _julianDay(date.year, date.month, date.day) +
          (dhuhr - timeZoneOffsetHours) / 24.0;
      sun = _sunPosition(refineJd);
    }
    dhuhr = 12.0 + timeZoneOffsetHours - longitude / 15.0 - sun.equationOfTime;

    final double horizonDip = 0.0347 * math.sqrt(math.max(0.0, elevationMeters));
    final double sunriseAngle = method.sunriseAngle + horizonDip;
    final double maghribAngle = method.maghribAngle + horizonDip;

    double sunriseHa = _hourAngleForDepression(sunriseAngle, latitude, sun.declination);
    double maghribHa = _hourAngleForDepression(maghribAngle, latitude, sun.declination);

    final double fajrHa = _halfDayHourAngle(
      angle: method.fajrAngle,
      latitude: latitude,
      declination: sun.declination,
      method: method,
      sunriseHa: sunriseHa,
      maghribHa: maghribHa,
      nightPortionFirstHalf: true,
    );

    double ishaHa;
    if (method.ishaIntervalMinutes != null) {
      ishaHa = -1;
    } else {
      ishaHa = _halfDayHourAngle(
        angle: method.ishaAngle,
        latitude: latitude,
        declination: sun.declination,
        method: method,
        sunriseHa: sunriseHa,
        maghribHa: maghribHa,
        nightPortionFirstHalf: false,
      );
    }

    final double asrAltitude = _asrAltitude(latitude, sun.declination, method.asrFactor);
    final double asrHa = _hourAngleForAltitude(asrAltitude, latitude, sun.declination);

    // NaN koruması (kutup bölgeleri / aşırı enlemler)
    double safe(double value, double fallback) => value.isFinite ? value : fallback;

    final double imsak = safe(dhuhr - fajrHa, dhuhr - 7.5);
    final double gunes = safe(dhuhr - sunriseHa, dhuhr - 6.0);
    final double ikindi = safe(dhuhr + asrHa, dhuhr + 3.5);
    final double aksam = safe(dhuhr + maghribHa, dhuhr + 6.0);
    final double yatsi = method.ishaIntervalMinutes != null
        ? aksam + method.ishaIntervalMinutes! / 60.0
        : safe(dhuhr + ishaHa, aksam + 1.5);

    final Temkin temkin = method.temkin;
    double offset(String key, int base) =>
        (manualOffsets[key] ?? 0) + base.toDouble();

    double apply(double minutes, double delta) {
      final double result = minutes + delta / 60.0;
      return result < 0 ? result + 24 : (result >= 24 ? result - 24 : result);
    }

    return CalculatedTimes(
      imsak: apply(imsak, offset('imsak', temkin.imsak)),
      gunes: apply(gunes, offset('gunes', temkin.gunes)),
      ogle: apply(dhuhr, offset('ogle', temkin.ogle)),
      ikindi: apply(ikindi, offset('ikindi', temkin.ikindi)),
      aksam: apply(aksam, offset('aksam', temkin.aksam)),
      yatsi: apply(yatsi, offset('yatsi', temkin.yatsi)),
    );
  }

  /// Julian Day numarası (0h UT).
  static double _julianDay(int year, int month, int day) {
    int y = year;
    int m = month;
    if (m <= 2) {
      y -= 1;
      m += 12;
    }
    final int a = y ~/ 100;
    final int b = 2 - a + a ~/ 4;
    return (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + day + b - 1524.5;
  }

  static _SunData _sunPosition(double julianDay) {
    final double d = julianDay - 2451545.0;
    final double g = _normalize(357.529 + 0.98560028 * d);
    final double q = _normalize(280.459 + 0.98564736 * d);
    final double l = _normalize(q + 1.915 * _sin(g) + 0.020 * _sin(2 * g));
    final double e = 23.439 - 0.00000036 * d;
    final double declination = _asin(_sin(e) * _sin(l));
    final double rightAscension =
        _normalize(math.atan2(math.cos(e * _degreesToRadians) * _sin(l), _cos(l)) * _radiansToDegrees / 15.0);
    final double equationOfTime = _normalize(q / 15.0 - rightAscension + 12.0);
    final double eqt = (equationOfTime > 12.0 ? equationOfTime - 24.0 : equationOfTime);
    return _SunData(declination, eqt);
  }

  static double _normalize(double degrees) {
    double value = degrees % 360.0;
    if (value < 0) value += 360.0;
    return value;
  }

  static double _sin(double degrees) => math.sin(degrees * _degreesToRadians);
  static double _cos(double degrees) => math.cos(degrees * _degreesToRadians);
  static double _acos(double value) => math.acos(value.clamp(-1.0, 1.0)) * _radiansToDegrees;
  static double _asin(double value) => math.asin(value.clamp(-1.0, 1.0)) * _radiansToDegrees;
  static double _atan(double value) => math.atan(value) * _radiansToDegrees;
  static double _tan(double degrees) => math.tan(degrees * _degreesToRadians);

  /// Verilen depresyon açısı (ufkun altında) için saat açısı.
  static double _hourAngleForDepression(double angle, double latitude, double declination) {
    final double numerator = -_sin(angle) - _sin(latitude) * _sin(declination);
    final double denominator = _cos(latitude) * _cos(declination);
    if (denominator.abs() < 1e-9) return double.nan;
    return _acos(numerator / denominator) / 15.0;
  }

  /// Verilen yükseklik (ufkun üstünde) için saat açısı — ikindi vakti.
  static double _hourAngleForAltitude(double altitude, double latitude, double declination) {
    final double numerator = _sin(altitude) - _sin(latitude) * _sin(declination);
    final double denominator = _cos(latitude) * _cos(declination);
    if (denominator.abs() < 1e-9) return double.nan;
    return _acos(numerator / denominator) / 15.0;
  }

  /// İkindi vakti güneş yüksekliği (asr-ı evvel / asr-ı sânî).
  static double _asrAltitude(double latitude, double declination, double factor) {
    final double latitudeDelta = (latitude - declination).abs();
    return _atan(1.0 / (factor + _tan(latitudeDelta)));
  }

  /// Yüksek enlem kuralı uygulanmış yarım gün saat açısı.
  static double _halfDayHourAngle({
    required double angle,
    required double latitude,
    required double declination,
    required CalculationMethod method,
    required double sunriseHa,
    required double maghribHa,
    required bool nightPortionFirstHalf,
  }) {
    final double raw = _hourAngleForDepression(angle, latitude, declination);
    if (method.highLatitudeRule == HighLatitudeRule.none) return raw;

    // Gece süresinin yarısı (saat cinsinden).
    final double nightHalf = 12.0 - maghribHa;
    final double portion = switch (method.highLatitudeRule) {
      HighLatitudeRule.middleOfNight => nightHalf / 2.0,
      HighLatitudeRule.seventhOfNight => nightHalf / 7.0,
      HighLatitudeRule.angleBased => (raw.isFinite ? raw : 0) * (1.0 / 60.0),
      HighLatitudeRule.none => double.infinity,
    };
    if (!raw.isFinite) return portion;
    // Açı hesabı gece yarısına taşıyorsa kurala göre sınırla.
    return raw > portion ? portion : raw;
  }
}
