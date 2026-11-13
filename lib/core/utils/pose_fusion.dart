import 'dart:math' as math;

/// **Tutuştan bağımsız pusula füzyonu — Dart referans uygulaması.**
///
/// Android tarafında (`MainActivity.extractAnglesFromMatrix`) aynı matematiğin
/// Kotlin sürümü çalışır; bu sınıf o matematiğin **birebir test edilebilir
/// referansıdır**. İki uygulama aynı girdi için aynı açıyı üretmek zorundadır
/// (`test/data/pose_fusion_test.dart`).
///
/// ### Neden gerekli?
/// Eski kod `SensorManager.getOrientation()` azimutunu (ekranın **üst kenarı**)
/// kullanıyordu. Telefon ufka doğru dik tutulduğunda üst kenar yukarı bakar;
/// yatay izdüşümü sıfıra iner ve açı **tanımsız** olur. Telefon dikeyin biraz
/// ötesine yatırıldığında ise izdüşüm ters döner ve ölçüm **180° hatalı**
/// olur — sahada "Kıble tam tersini gösteriyor" şikâyetinin kaynağı budur.
///
/// ### Çözüm
/// İki yön birlikte değerlendirilir:
/// * **Yatay tutuş** → ekranın üst kenarı (`bearingFlat`),
/// * **Dik tutuş** → arka kamera (`bearingUpright`, ekran normalinin tersi).
///
/// Her yönün **yatay izdüşüm uzunluğunun karesi** ağırlık olur (uzunluk 0'a
/// yaklaşırken ağırlık da hızla 0'a iner) ve iki yön **birim vektörler**
/// üzerinden dairesel olarak toplanır. Sonuç: tutuş açısı ne olursa olsun
/// kesintisiz, sıçramasız ve doğru yön.
abstract final class PoseFusion {
  /// Android döndürme matrisinden (satır-öncelikli 9 eleman) yön ve tutuş.
  ///
  /// [rotationMatrix] dünya koordinatlarına (Doğu, Kuzey, Yukarı) giden
  /// matristir: `world = R · device`. Android `displayAdjusted` matrisi ile
  /// aynı düzendedir.
  static FusedBearing? fromRotationMatrix(List<double> rotationMatrix) {
    if (rotationMatrix.length < 9) return null;

    // Yatay tutuş: ekranın üst kenarı (device +Y).
    final double flatEast = rotationMatrix[1];
    final double flatNorth = rotationMatrix[4];
    final double flatHoriz = math.sqrt(
      flatEast * flatEast + flatNorth * flatNorth,
    );

    // Dik tutuş: arka kamera (device -Z).
    final double camEast = -rotationMatrix[2];
    final double camNorth = -rotationMatrix[5];
    final double camHoriz = math.sqrt(camEast * camEast + camNorth * camNorth);

    final double flatWeight = flatHoriz * flatHoriz;
    final double camWeight = camHoriz * camHoriz;
    final double total = flatWeight + camWeight;
    if (total < 1e-6) return null;

    final double bearingFlat = math.atan2(flatEast, flatNorth);
    final double bearingCam = math.atan2(camEast, camNorth);
    final double sinSum =
        flatWeight * math.sin(bearingFlat) + camWeight * math.sin(bearingCam);
    final double cosSum =
        flatWeight * math.cos(bearingFlat) + camWeight * math.cos(bearingCam);
    final double bearing = _normalize360(
      math.atan2(sinSum, cosSum) * 180.0 / math.pi,
    );

    final double pitch =
        math.asin((-rotationMatrix[8]).clamp(-1.0, 1.0)) * 180.0 / math.pi;
    final double tilt = (90.0 - pitch.abs()).abs();
    final double roll =
        math.asin(rotationMatrix[6].clamp(-1.0, 1.0)) * 180.0 / math.pi;

    final double weight = camWeight / total;
    return FusedBearing(
      bearing: bearing,
      poseWeight: weight,
      pose: weight > 0.72
          ? CompassPose.upright
          : weight < 0.28
          ? CompassPose.flat
          : CompassPose.blend,
      tilt: tilt,
      roll: roll,
    );
  }

  /// Ekran dönüşü için eksen eşlemesi (0°, 90°, 180°, 270°).
  ///
  /// Android sabitleri (`SensorManager.AXIS_*`).
  static const int axisX = 1;
  static const int axisY = 2;
  static const int axisMinusX = 0x81;
  static const int axisMinusY = 0x82;

  /// Android `SensorManager.remapCoordinateSystem` çağrısında kullanılan
  /// `(axisX, axisY)` çiftini döndürür (`Surface.ROTATION_*` değerine göre).
  ///
  /// Yatay tutuşta da yönün doğru kalması için gereklidir: telefon yan
  /// çevrildiğinde "ekranın üst kenarı" artık fiziksel olarak başka bir
  /// kenardır.
  static (int, int) remapAxes(int surfaceRotation) => switch (surfaceRotation) {
    1 => (axisY, axisMinusX), // ROTATION_90
    2 => (axisMinusX, axisMinusY), // ROTATION_180
    3 => (axisMinusY, axisX), // ROTATION_270
    _ => (axisX, axisY), // ROTATION_0
  };

  static double _normalize360(double degrees) {
    final double v = degrees % 360.0;
    return v < 0 ? v + 360.0 : v;
  }
}

/// Füzyon sonucu.
class FusedBearing {
  const FusedBearing({
    required this.bearing,
    required this.poseWeight,
    required this.pose,
    required this.tilt,
    required this.roll,
  });

  /// Gerçek kuzeyden saat yönünde yön (0-360°).
  final double bearing;

  /// 0 = tamamen yatay, 1 = tamamen dik.
  final double poseWeight;

  final CompassPose pose;

  /// Yatay düzlemden sapma (0° = masada düz, 90° = dik).
  final double tilt;

  /// Yan yatırma (derece).
  final double roll;
}

/// Telefonun tutuş biçimi.
enum CompassPose { flat, blend, upright }
