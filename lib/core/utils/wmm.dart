import 'dart:math' as math;

/// Manyetik alan modeli: **WMM-2025** (World Magnetic Model, NOAA/NCEI & BGS).
///
/// Dünyanın manyetik sapma açısını (declination) 2025.0–2030.0 aralığında
/// `0.05°` hassasiyetle verir. Katsayılar resmî `WMM_2025.COF` dosyasından
/// birebir alınmıştır (derece 12, 90 katsayı çifti).
///
/// **Neden gerekli?** Telefonun manyetometresi manyetik kuzeyi ölçer; Kâbe
/// yönü ise **gerçek (coğrafi) kuzeye** göre hesaplanır. Aradaki fark
/// (Türkiye'de ~+6°, Sidney'de ~+13°, New York'ta ~-12.5°) düzeltilmezse
/// pusula iğnesi Kâbe'yi onlarca derece yanlış gösterir.
///
/// * Android tarafında cihazın kendi `GeomagneticField` (WMM) hesabı varsa o
///   kullanılır (birincil kaynak).
/// * Bu sınıf, cihaz desteği olmadığında ya da testlerde kullanılan
///   **birebir aynı modelin** saf Dart uygulamasıdır (her platformda çalışır).
abstract final class Wmm2025 {
  /// Modelin geçerlilik başlangıç yılı (ondalık yıl).
  static const double epoch = 2025.0;

  /// Modelin geçerlilik bitiş yılı (ondalık yıl).
  static const double validUntil = 2030.0;

  static const int _maxOrder = 12;
  static const int _size = _maxOrder + 1;

  /// WGS-84 elipsoidi ve referans küre yarıçapı (km).
  static const double _a = 6378.137;
  static const double _b = 6356.7523142;
  static const double _re = 6371.2;

  static final _WmmModel _model = _WmmModel();

  /// Verilen konum ve tarihte manyetik sapma açısı (derece, Doğu pozitif).
  ///
  /// [latitude] -89.9..+89.9, [longitude] -180..+180, [altitudeKm] deniz
  /// seviyesinden yükseklik (km, varsayılan 0).
  static double declination(
    double latitude,
    double longitude, {
    double altitudeKm = 0,
    DateTime? date,
  }) {
    if (!latitude.isFinite || !longitude.isFinite) return 0.0;
    final double year = decimalYear(date ?? DateTime.now());
    return declinationAtYear(latitude, longitude, year, altitudeKm: altitudeKm);
  }

  /// Testlerde sabit tarihle hesap yapabilmek için ayrık (ondalık yıl) sürüm.
  static double declinationAtYear(
    double latitude,
    double longitude,
    double year, {
    double altitudeKm = 0,
  }) {
    if (!latitude.isFinite || !longitude.isFinite || !year.isFinite) return 0.0;
    final double lat = latitude.clamp(-89.9, 89.9);
    final double lon = longitude.clamp(-180.0, 180.0);
    // Modelin ömrü dışına çıkıldığında en yakın geçerli yıl kullanılır
    // (2030'dan sonra da sapma "donmuş" olarak makul kalır).
    final double clampedYear = year.clamp(epoch, validUntil);
    try {
      return _model.declination(lat, lon, altitudeKm, clampedYear);
    } catch (_) {
      return 0.0;
    }
  }

  /// [DateTime] → ondalık yıl (ör. 2026-10-27 → 2026.82).
  static double decimalYear(DateTime date) {
    final int year = date.year;
    final int dayOfYear = date.difference(DateTime(year)).inDays;
    final int daysInYear = DateTime(year + 1).difference(DateTime(year)).inDays;
    return year + dayOfYear / daysInYear;
  }

  /// Çevrimdışı testlerde doğrulama için model sürümü.
  static String get modelId => 'WMM-2025 (NOAA/NCEI & BGS, 2024-11-13)';

  /// Resmî WMM-2025 Gauss katsayıları:
  /// `n, m, g(n,m), h(n,m), dg/dt, dh/dt` (nT ve nT/yıl).
  // dart format off
  static const List<double> coefficients = <double>[
    1.0,
    0.0,
    -29351.8,
    0.0,
    12.0,
    0.0,
    1.0,
    1.0,
    -1410.8,
    4545.4,
    9.7,
    -21.5,
    2.0,
    0.0,
    -2556.6,
    0.0,
    -11.6,
    0.0,
    2.0,
    1.0,
    2951.1,
    -3133.6,
    -5.2,
    -27.7,
    2.0,
    2.0,
    1649.3,
    -815.1,
    -8.0,
    -12.1,
    3.0,
    0.0,
    1361.0,
    0.0,
    -1.3,
    0.0,
    3.0,
    1.0,
    -2404.1,
    -56.6,
    -4.2,
    4.0,
    3.0,
    2.0,
    1243.8,
    237.5,
    0.4,
    -0.3,
    3.0,
    3.0,
    453.6,
    -549.5,
    -15.6,
    -4.1,
    4.0,
    0.0,
    895.0,
    0.0,
    -1.6,
    0.0,
    4.0,
    1.0,
    799.5,
    278.6,
    -2.4,
    -1.1,
    4.0,
    2.0,
    55.7,
    -133.9,
    -6.0,
    4.1,
    4.0,
    3.0,
    -281.1,
    212.0,
    5.6,
    1.6,
    4.0,
    4.0,
    12.1,
    -375.6,
    -7.0,
    -4.4,
    5.0,
    0.0,
    -233.2,
    0.0,
    0.6,
    0.0,
    5.0,
    1.0,
    368.9,
    45.4,
    1.4,
    -0.5,
    5.0,
    2.0,
    187.2,
    220.2,
    0.0,
    2.2,
    5.0,
    3.0,
    -138.7,
    -122.9,
    0.6,
    0.4,
    5.0,
    4.0,
    -142.0,
    43.0,
    2.2,
    1.7,
    5.0,
    5.0,
    20.9,
    106.1,
    0.9,
    1.9,
    6.0,
    0.0,
    64.4,
    0.0,
    -0.2,
    0.0,
    6.0,
    1.0,
    63.8,
    -18.4,
    -0.4,
    0.3,
    6.0,
    2.0,
    76.9,
    16.8,
    0.9,
    -1.6,
    6.0,
    3.0,
    -115.7,
    48.8,
    1.2,
    -0.4,
    6.0,
    4.0,
    -40.9,
    -59.8,
    -0.9,
    0.9,
    6.0,
    5.0,
    14.9,
    10.9,
    0.3,
    0.7,
    6.0,
    6.0,
    -60.7,
    72.7,
    0.9,
    0.9,
    7.0,
    0.0,
    79.5,
    0.0,
    0.0,
    0.0,
    7.0,
    1.0,
    -77.0,
    -48.9,
    -0.1,
    0.6,
    7.0,
    2.0,
    -8.8,
    -14.4,
    -0.1,
    0.5,
    7.0,
    3.0,
    59.3,
    -1.0,
    0.5,
    -0.8,
    7.0,
    4.0,
    15.8,
    23.4,
    -0.1,
    0.0,
    7.0,
    5.0,
    2.5,
    -7.4,
    -0.8,
    -1.0,
    7.0,
    6.0,
    -11.1,
    -25.1,
    -0.8,
    0.6,
    7.0,
    7.0,
    14.2,
    -2.3,
    0.8,
    -0.2,
    8.0,
    0.0,
    23.2,
    0.0,
    -0.1,
    0.0,
    8.0,
    1.0,
    10.8,
    7.1,
    0.2,
    -0.2,
    8.0,
    2.0,
    -17.5,
    -12.6,
    0.0,
    0.5,
    8.0,
    3.0,
    2.0,
    11.4,
    0.5,
    -0.4,
    8.0,
    4.0,
    -21.7,
    -9.7,
    -0.1,
    0.4,
    8.0,
    5.0,
    16.9,
    12.7,
    0.3,
    -0.5,
    8.0,
    6.0,
    15.0,
    0.7,
    0.2,
    -0.6,
    8.0,
    7.0,
    -16.8,
    -5.2,
    0.0,
    0.3,
    8.0,
    8.0,
    0.9,
    3.9,
    0.2,
    0.2,
    9.0,
    0.0,
    4.6,
    0.0,
    0.0,
    0.0,
    9.0,
    1.0,
    7.8,
    -24.8,
    -0.1,
    -0.3,
    9.0,
    2.0,
    3.0,
    12.2,
    0.1,
    0.3,
    9.0,
    3.0,
    -0.2,
    8.3,
    0.3,
    -0.3,
    9.0,
    4.0,
    -2.5,
    -3.3,
    -0.3,
    0.3,
    9.0,
    5.0,
    -13.1,
    -5.2,
    0.0,
    0.2,
    9.0,
    6.0,
    2.4,
    7.2,
    0.3,
    -0.1,
    9.0,
    7.0,
    8.6,
    -0.6,
    -0.1,
    -0.2,
    9.0,
    8.0,
    -8.7,
    0.8,
    0.1,
    0.4,
    9.0,
    9.0,
    -12.9,
    10.0,
    -0.1,
    0.1,
    10.0,
    0.0,
    -1.3,
    0.0,
    0.1,
    0.0,
    10.0,
    1.0,
    -6.4,
    3.3,
    0.0,
    0.0,
    10.0,
    2.0,
    0.2,
    0.0,
    0.1,
    0.0,
    10.0,
    3.0,
    2.0,
    2.4,
    0.1,
    -0.2,
    10.0,
    4.0,
    -1.0,
    5.3,
    0.0,
    0.1,
    10.0,
    5.0,
    -0.6,
    -9.1,
    -0.3,
    -0.1,
    10.0,
    6.0,
    -0.9,
    0.4,
    0.0,
    0.1,
    10.0,
    7.0,
    1.5,
    -4.2,
    -0.1,
    0.0,
    10.0,
    8.0,
    0.9,
    -3.8,
    -0.1,
    -0.1,
    10.0,
    9.0,
    -2.7,
    0.9,
    0.0,
    0.2,
    10.0,
    10.0,
    -3.9,
    -9.1,
    0.0,
    0.0,
    11.0,
    0.0,
    2.9,
    0.0,
    0.0,
    0.0,
    11.0,
    1.0,
    -1.5,
    0.0,
    0.0,
    0.0,
    11.0,
    2.0,
    -2.5,
    2.9,
    0.0,
    0.1,
    11.0,
    3.0,
    2.4,
    -0.6,
    0.0,
    0.0,
    11.0,
    4.0,
    -0.6,
    0.2,
    0.0,
    0.1,
    11.0,
    5.0,
    -0.1,
    0.5,
    -0.1,
    0.0,
    11.0,
    6.0,
    -0.6,
    -0.3,
    0.0,
    0.0,
    11.0,
    7.0,
    -0.1,
    -1.2,
    0.0,
    0.1,
    11.0,
    8.0,
    1.1,
    -1.7,
    -0.1,
    0.0,
    11.0,
    9.0,
    -1.0,
    -2.9,
    -0.1,
    0.0,
    11.0,
    10.0,
    -0.2,
    -1.8,
    -0.1,
    0.0,
    11.0,
    11.0,
    2.6,
    -2.3,
    -0.1,
    0.0,
    12.0,
    0.0,
    -2.0,
    0.0,
    0.0,
    0.0,
    12.0,
    1.0,
    -0.2,
    -1.3,
    0.0,
    0.0,
    12.0,
    2.0,
    0.3,
    0.7,
    0.0,
    0.0,
    12.0,
    3.0,
    1.2,
    1.0,
    0.0,
    -0.1,
    12.0,
    4.0,
    -1.3,
    -1.4,
    0.0,
    0.1,
    12.0,
    5.0,
    0.6,
    0.0,
    0.0,
    0.0,
    12.0,
    6.0,
    0.6,
    0.6,
    0.1,
    0.0,
    12.0,
    7.0,
    0.5,
    -0.1,
    0.0,
    0.0,
    12.0,
    8.0,
    -0.1,
    0.8,
    0.0,
    0.0,
    12.0,
    9.0,
    -0.4,
    0.1,
    0.0,
    0.0,
    12.0,
    10.0,
    -0.2,
    -1.0,
    -0.1,
    0.0,
    12.0,
    11.0,
    -1.3,
    0.1,
    0.0,
    0.0,
    12.0,
    12.0,
    -0.7,
    0.2,
    -0.1,
    -0.1,
  ];
  // dart format on
}

/// Schönberg/NOAA algoritmasının (geomag70.c) saf Dart uygulaması.
class _WmmModel {
  _WmmModel() {
    _buildTables();
  }

  late final List<List<double>> _c;
  late final List<List<double>> _cd;
  late final List<double> _fn;
  late final List<double> _fm;
  late final List<List<double>> _k;

  void _buildTables() {
    final List<List<double>> c = List<List<double>>.generate(
      Wmm2025._size,
      (_) => List<double>.filled(Wmm2025._size, 0.0),
    );
    final List<List<double>> cd = List<List<double>>.generate(
      Wmm2025._size,
      (_) => List<double>.filled(Wmm2025._size, 0.0),
    );
    final List<double> snorm = List<double>.filled(
      Wmm2025._size * Wmm2025._size,
      0.0,
    );
    final List<double> fn = List<double>.filled(Wmm2025._size, 0.0);
    final List<double> fm = List<double>.filled(Wmm2025._size, 0.0);
    final List<List<double>> k = List<List<double>>.generate(
      Wmm2025._size,
      (_) => List<double>.filled(Wmm2025._size, 0.0),
    );

    const List<double> cof = Wmm2025.coefficients;
    for (int i = 0; i + 5 < cof.length; i += 6) {
      final int n = cof[i].toInt();
      final int m = cof[i + 1].toInt();
      final double gnm = cof[i + 2];
      final double hnm = cof[i + 3];
      final double dgnm = cof[i + 4];
      final double dhnm = cof[i + 5];
      if (m > n || m < 0) continue;
      c[m][n] = gnm;
      cd[m][n] = dgnm;
      if (m != 0) {
        c[n][m - 1] = hnm;
        cd[n][m - 1] = dhnm;
      }
    }

    // Schmidt yarı-normalize katsayıların normalize edilmemiş hâle çevrimi.
    snorm[0] = 1.0;
    fm[0] = 0.0;
    for (int n = 1; n < Wmm2025._size; n++) {
      snorm[n] = snorm[n - 1] * (2 * n - 1) / n;
      int j = 2;
      int m = 0;
      while (m <= n) {
        k[m][n] = ((n - 1) * (n - 1) - m * m) / ((2 * n - 1) * (2 * n - 3));
        if (m > 0) {
          final double flnmj = (n - m + 1) * j / (n + m);
          snorm[n + m * Wmm2025._size] =
              snorm[n + (m - 1) * Wmm2025._size] * math.sqrt(flnmj);
          j = 1;
          c[n][m - 1] = snorm[n + m * Wmm2025._size] * c[n][m - 1];
          cd[n][m - 1] = snorm[n + m * Wmm2025._size] * cd[n][m - 1];
        }
        c[m][n] = snorm[n + m * Wmm2025._size] * c[m][n];
        cd[m][n] = snorm[n + m * Wmm2025._size] * cd[m][n];
        m += 1;
      }
      fn[n] = (n + 1).toDouble();
      fm[n] = n.toDouble();
    }
    k[1][1] = 0.0;

    _c = c;
    _cd = cd;
    _fn = fn;
    _fm = fm;
    _k = k;
  }

  /// Manyetik sapma açısı (derece).
  double declination(double glat, double glon, double altKm, double year) {
    const int size = Wmm2025._size;
    final List<double> p = List<double>.filled(size * size, 0.0);
    p[0] = 1.0;
    final List<List<double>> dp = List<List<double>>.generate(
      size,
      (_) => List<double>.filled(size, 0.0),
    );
    final List<List<double>> tc = List<List<double>>.generate(
      size,
      (_) => List<double>.filled(size, 0.0),
    );
    final List<double> sp = List<double>.filled(size, 0.0);
    final List<double> cp = List<double>.filled(size, 0.0);
    final List<double> pp = List<double>.filled(size, 0.0);
    cp[0] = 1.0;
    pp[0] = 1.0;
    dp[0][0] = 0.0;

    const double a = Wmm2025._a;
    const double b = Wmm2025._b;
    const double re = Wmm2025._re;
    const double a2 = a * a;
    const double b2 = b * b;
    const double c2 = a2 - b2;
    const double a4 = a2 * a2;
    const double b4 = b2 * b2;
    const double c4 = a4 - b4;

    final double dt = year - Wmm2025.epoch;
    final double rlon = glon * math.pi / 180.0;
    final double rlat = glat * math.pi / 180.0;
    final double srlon = math.sin(rlon);
    final double srlat = math.sin(rlat);
    final double crlon = math.cos(rlon);
    final double crlat = math.cos(rlat);
    final double srlat2 = srlat * srlat;
    final double crlat2 = crlat * crlat;
    sp[1] = srlon;
    cp[1] = crlon;

    // Jeodezik → küresel koordinat dönüşümü.
    final double q = math.sqrt(a2 - c2 * srlat2);
    final double q1 = altKm * q;
    final double q2 = math.pow((q1 + a2) / (q1 + b2), 2).toDouble();
    final double ct = srlat / math.sqrt(q2 * crlat2 + srlat2);
    final double st = math.sqrt(math.max(0.0, 1.0 - ct * ct));
    final double r2 = altKm * altKm + 2.0 * q1 + (a4 - c4 * srlat2) / (q * q);
    final double r = math.sqrt(r2);
    final double d = math.sqrt(a2 * crlat2 + b2 * srlat2);
    final double ca = (altKm + d) / r;
    final double sa = c2 * crlat * srlat / (r * d);

    for (int m = 2; m < size; m++) {
      sp[m] = sp[1] * cp[m - 1] + cp[1] * sp[m - 1];
      cp[m] = cp[1] * cp[m - 1] - sp[1] * sp[m - 1];
    }

    final double aor = re / r;
    double ar = aor * aor;
    double br = 0.0;
    double bt = 0.0;
    double bp = 0.0;
    double bpp = 0.0;

    for (int n = 1; n < size; n++) {
      ar = ar * aor;
      for (int m = 0; m <= n; m++) {
        if (n == m) {
          p[n + m * size] = st * p[(n - 1) + (m - 1) * size];
          dp[m][n] = st * dp[m - 1][n - 1] + ct * p[(n - 1) + (m - 1) * size];
        } else if (n == 1 && m == 0) {
          p[n + m * size] = ct * p[(n - 1) + m * size];
          dp[m][n] = ct * dp[m][n - 1] - st * p[(n - 1) + m * size];
        } else {
          if (m > n - 2) {
            p[(n - 2) + m * size] = 0.0;
            dp[m][n - 2] = 0.0;
          }
          p[n + m * size] =
              ct * p[(n - 1) + m * size] - _k[m][n] * p[(n - 2) + m * size];
          dp[m][n] =
              ct * dp[m][n - 1] -
              st * p[(n - 1) + m * size] -
              _k[m][n] * dp[m][n - 2];
        }

        // Gauss katsayılarının zamana göre güncellenmesi.
        tc[m][n] = _c[m][n] + dt * _cd[m][n];
        if (m != 0) {
          tc[n][m - 1] = _c[n][m - 1] + dt * _cd[n][m - 1];
        }

        final double par = ar * p[n + m * size];
        double temp1;
        double temp2;
        if (m == 0) {
          temp1 = tc[m][n] * cp[m];
          temp2 = tc[m][n] * sp[m];
        } else {
          temp1 = tc[m][n] * cp[m] + tc[n][m - 1] * sp[m];
          temp2 = tc[m][n] * sp[m] - tc[n][m - 1] * cp[m];
        }
        bt = bt - ar * temp1 * dp[m][n];
        bp += _fm[m] * temp2 * par;
        br += _fn[n] * temp1 * par;

        // Coğrafi kutuplar özel durumu.
        if (st == 0.0 && m == 1) {
          if (n == 1) {
            pp[n] = pp[n - 1];
          } else {
            pp[n] = ct * pp[n - 1] - _k[m][n] * pp[n - 2];
          }
          final double parp = ar * pp[n];
          bpp += _fm[m] * temp2 * parp;
        }
      }
    }

    if (st == 0.0) {
      bp = bpp;
    } else {
      bp /= st;
    }

    // Küresel → jeodezik bileşen dönüşümü.
    final double bx = -bt * ca - br * sa;
    final double by = bp;
    final double bh = math.sqrt(bx * bx + by * by);
    if (bh < 1e-9) return 0.0;
    final double dec = math.atan2(by, bx) * 180.0 / math.pi;
    return dec.isFinite ? dec : 0.0;
  }
}
