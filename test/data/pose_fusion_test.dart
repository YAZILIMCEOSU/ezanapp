import 'dart:math' as math;

import 'package:ezanai/core/utils/geo.dart';
import 'package:ezanai/core/utils/pose_fusion.dart';
import 'package:flutter_test/flutter_test.dart';

/// **Kıble doğrulama — 3. tur: tutuş matematik testi.**
///
/// Android sensöründen gelen döndürme matrisleri **fiziksel olarak
/// simüle edilir**: telefon, gerçek dünyada bilinen bir yönü gösterirken
/// (yatay → 45° → dik → dikey ötesi) matris üretilir ve füzyonun doğru yönü
/// verdiği kontrol edilir.
///
/// Bu test, sahada görülen üç hatayı kilitler:
/// * Dik tutuşta `getOrientation` tabanlı eski yöntem **tanımsız** oluyordu.
/// * Dikeyin biraz ötesinde ölçüm **180° ters** dönüyordu.
/// * Yatay ↔ dik geçişinde açı **sıçrıyordu**.
void main() {
  /// `theta`: telefonun gösterdiği yön (derece, gerçek kuzeyden saat yönü).
  /// `pitch`: 0° masada düz, 90° ufka dik.
  ///
  /// Dünya koordinatı ENU (Doğu, Kuzey, Yukarı). Döndürme matrisi
  /// `world = R · device` biçimindedir; `R[i][j]`, i. dünya ekseninin
  /// j. cihaz ekseni üzerindeki bileşenidir.
  List<double> frame(double thetaDegrees, double pitchDegrees) {
    final double th = thetaDegrees * math.pi / 180.0;
    final double p = pitchDegrees * math.pi / 180.0;

    // Telefon yatayken: üst kenar (0, sin t, cos t), sağ kenar (cos t, -sin t, 0)
    final List<double> top = <double>[math.sin(th), math.cos(th), 0];
    final List<double> right = <double>[math.cos(th), -math.sin(th), 0];
    const List<double> up = <double>[0, 0, 1];

    // Sağ kenar ekseni etrafında `pitch` kadar döndür (telefonu kaldır).
    List<double> rotate(List<double> v) {
      // Rodrigues: v·cos + (a × v)·sin + a(a·v)(1-cos), a = right.
      final double dot = v[0] * right[0] + v[1] * right[1] + v[2] * right[2];
      final List<double> cross = <double>[
        right[1] * v[2] - right[2] * v[1],
        right[2] * v[0] - right[0] * v[2],
        right[0] * v[1] - right[1] * v[0],
      ];
      return <double>[
        v[0] * math.cos(p) + cross[0] * math.sin(p) + right[0] * dot * (1 - math.cos(p)),
        v[1] * math.cos(p) + cross[1] * math.sin(p) + right[1] * dot * (1 - math.cos(p)),
        v[2] * math.cos(p) + cross[2] * math.sin(p) + right[2] * dot * (1 - math.cos(p)),
      ];
    }

    final List<double> x = rotate(right);
    final List<double> y = rotate(top);
    final List<double> z = rotate(up);

    // Satır öncelikli: R[0] = (x_e, y_e, z_e), R[1] = (x_n, y_n, z_n)…
    return <double>[
      x[0], y[0], z[0],
      x[1], y[1], z[1],
      x[2], y[2], z[2],
    ];
  }

  group('1. Füzyon her tutuşta doğru yönü verir', () {
    for (final double theta in <double>[0, 37, 90, 151.371, 180, 270, 359]) {
      test('yön ${theta}° · tüm tutuş açılarında ±0,001°', () {
        for (final double pitch in <double>[0, 15, 30, 45, 60, 75, 90, 100, 120]) {
          final FusedBearing? fused = PoseFusion.fromRotationMatrix(
            frame(theta, pitch),
          );
          expect(fused, isNotNull, reason: 'pitch $pitch');
          expect(
            GeoUtils.normalizeSigned(fused!.bearing - theta).abs(),
            lessThan(0.001),
            reason: 'yön $theta°, pitch $pitch° → ${fused.bearing}°',
          );
        }
      });
    }

    test('Bağcılar kıble yönü (151.371°) dikey tutuşta da doğru', () {
      final FusedBearing? fused = PoseFusion.fromRotationMatrix(
        frame(151.371, 90),
      );
      expect(fused!.bearing, closeTo(151.371, 0.001));
      expect(fused.pose, CompassPose.upright);
      expect(fused.poseWeight, closeTo(1.0, 0.01));
      expect(fused.tilt, closeTo(90, 1));
      expect(fused.roll.abs(), lessThan(0.001));
    });
  });

  group('2. Eski yöntemin 180° hatası artık yok', () {
    /// Eski kod: yalnızca ekranın üst kenarı (device +Y) kullanılıyordu.
    double? legacyBearing(List<double> r) {
      final double east = r[1];
      final double north = r[4];
      if (math.sqrt(east * east + north * north) < 1e-9) return null;
      return GeoUtils.normalizeDegrees(math.atan2(east, north) * 180 / math.pi);
    }

    test('Dikey tutuşta eski yöntem tanımsız, yeni yöntem doğru', () {
      final List<double> matrix = frame(37, 90);
      expect(legacyBearing(matrix), isNull);
      expect(
        PoseFusion.fromRotationMatrix(matrix)!.bearing,
        closeTo(37, 0.001),
      );
    });

    test('Dikeyin ötesinde (100°) eski yöntem 180° hatalı, yeni doğru', () {
      final List<double> matrix = frame(37, 100);
      final double legacy = legacyBearing(matrix)!;
      expect(
        GeoUtils.normalizeSigned(legacy - 37).abs(),
        greaterThan(179),
        reason: 'eski yöntem gerçekten 180° hatalı olmalı (kanıt)',
      );
      expect(
        GeoUtils.normalizeSigned(
          PoseFusion.fromRotationMatrix(matrix)!.bearing - 37,
        ).abs(),
        lessThan(0.001),
      );
    });

    test('Yatay → dik geçişinde açı sıçramaz', () {
      double? previous;
      for (double pitch = 0; pitch <= 120; pitch += 1) {
        final double bearing = PoseFusion.fromRotationMatrix(
          frame(151.371, pitch),
        )!.bearing;
        if (previous != null) {
          expect(
            GeoUtils.normalizeSigned(bearing - previous).abs(),
            lessThan(0.5),
            reason: 'pitch $pitch° geçişinde sıçrama',
          );
        }
        previous = bearing;
      }
    });
  });

  group('3. Tutuş ağırlığı ve etiketleri', () {
    test('Yatayda flat, 45° geçişte blend, dikte upright', () {
      expect(
        PoseFusion.fromRotationMatrix(frame(0, 0))!.pose,
        CompassPose.flat,
      );
      expect(
        PoseFusion.fromRotationMatrix(frame(0, 45))!.pose,
        CompassPose.blend,
      );
      expect(
        PoseFusion.fromRotationMatrix(frame(0, 90))!.pose,
        CompassPose.upright,
      );
    });

    test('Ağırlık 0 → 1 arasında ve tek yönlü artar', () {
      double previous = -1;
      for (double pitch = 0; pitch <= 90; pitch += 5) {
        final double w = PoseFusion.fromRotationMatrix(
          frame(10, pitch),
        )!.poseWeight;
        expect(w, inInclusiveRange(0, 1));
        expect(w, greaterThanOrEqualTo(previous));
        previous = w;
      }
    });

    test('Eğim (tilt) tutuş açısıyla birebir', () {
      for (final double pitch in <double>[0, 20, 45, 70, 90]) {
        final FusedBearing fused = PoseFusion.fromRotationMatrix(
          frame(10, pitch),
        )!;
        expect(fused.tilt, closeTo(pitch, 0.5));
      }
    });

    test('Geçersiz matris null döner', () {
      expect(PoseFusion.fromRotationMatrix(<double>[1, 2]), isNull);
    });
  });

  group('4. Ekran dönüşü (yatay tutuş) eksen eşlemesi', () {
    test('Dört ekran yönü de tanımlı ve birbirinden farklı', () {
      final List<(int, int)> mappings = <(int, int)>[
        PoseFusion.remapAxes(0),
        PoseFusion.remapAxes(1),
        PoseFusion.remapAxes(2),
        PoseFusion.remapAxes(3),
      ];
      expect(mappings.toSet().length, 4);
    });

    test('Dikey ekran için AXIS_X / AXIS_Y', () {
      expect(PoseFusion.remapAxes(0), (1, 2));
    });

    test('Yan çevrilmiş ekranda eksenler döner (AY, -AX)', () {
      expect(
        PoseFusion.remapAxes(1),
        (PoseFusion.axisY, PoseFusion.axisMinusX),
      );
      expect(
        PoseFusion.remapAxes(3),
        (PoseFusion.axisMinusY, PoseFusion.axisX),
      );
    });
  });
}
