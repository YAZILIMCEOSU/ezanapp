import 'dart:math' as math;

import 'geo.dart';

/// Kıble Pusulası ekran geometrisi — e-Diyanet birebir davranışı.
///
/// **Referans çerçevesi:** Tüm açılar **gerçek (coğrafi) kuzeye** göredir ve
/// ekranda `0° = saat 12 yönü`, pozitif yön **saat yönü**dür.
///
/// * Telefonun baktığı yön: `heading` (0-360°).
/// * Kâbe yönü: `qibla` (0-360°, gerçek kuzeyden saat yönünde).
/// * Kadran (N/E/S/W + derece çizgileri) `-heading` kadar döner ki kuzey
///   harfi, telefon hangi yöne bakıyorsa doğru tarafta görünsün.
/// * Kâbe rozeti, sabit 12 yönündeki okun üzerine `qibla - heading` kadar
///   dönerek gelir; fark `0°` olduğunda rozet okun ucundadır (hizalı).
///
/// Bu sınıf, arayüzden bağımsız olarak birim testlerle doğrulanır
/// (`test/data/qibla_verification_test.dart`).
abstract final class QiblaMath {
  /// Kâbe rozetinin ekran açısı (saat 12 = 0°, saat yönü pozitif, -180..180).
  ///
  /// Bu değer aynı zamanda "Kıble farkı"dır; pozitifse Kâbe rozeti okun
  /// **sağında** (telefonu saat yönünde çevirmek gerekir), negatifse solunda.
  static double badgeScreenAngle({
    required double qibla,
    required double heading,
  }) => GeoUtils.normalizeSigned(qibla - heading);

  /// Kadranın (N/E/S/W) dönüş açısı. Telefon `heading` yönüne bakarken
  /// kuzey, ekranın `-heading` açısında görünmelidir.
  static double dialRotation({required double heading}) =>
      GeoUtils.normalizeSigned(-heading);

  /// Sabit 12 yönü oku, Kâbe rozetiyle hizalandı mı?
  static bool isAligned({
    required double qibla,
    required double heading,
    double tolerance = 5.0,
  }) => badgeScreenAngle(qibla: qibla, heading: heading).abs() <= tolerance;

  /// Hizalanana kadar telefonu hangi tarafa çevirmeli?
  /// `1` → saat yönü (sağa), `-1` → saat yönünün tersi (sola), `0` → hizalı.
  static int turnDirection({
    required double qibla,
    required double heading,
    double tolerance = 1.5,
  }) {
    final double diff = badgeScreenAngle(qibla: qibla, heading: heading);
    if (diff.abs() <= tolerance) return 0;
    return diff > 0 ? 1 : -1;
  }

  /// Kâbe rozetinin kadran üzerindeki merkeze uzaklığı (piksel) — 12 yönü
  /// okunun ucu ile rozetin oturması gereken yarıçap aynıdır.
  static double badgeRadius(double dialDiameter) => dialDiameter / 2;

  /// Kullanıcıya gösterilecek yönlendirme metni.
  static String guidanceText({
    required double qibla,
    required double heading,
    double tolerance = 5.0,
  }) {
    final double diff = badgeScreenAngle(qibla: qibla, heading: heading);
    if (diff.abs() <= tolerance) {
      return 'Kâbe yönündesiniz. Ok ile Kâbe rozeti hizalı.';
    }
    final String side = diff > 0 ? 'sağa' : 'sola';
    final int degrees = diff.abs().round();
    if (diff.abs() <= 15) {
      return 'Çok yaklaştınız: telefonu $degrees° $side çevirin.';
    }
    return 'Telefonu $degrees° $side çevirip yeşil oku Kâbe rozetine getirin.';
  }

  /// Kıble yönünü, ekrana çizilen haritada kullanılacak vektöre çevirir
  /// (ekran koordinatı: +X sağ, +Y aşağı).
  static math.Point<double> screenVector({
    required double qibla,
    required double heading,
    double length = 1,
  }) {
    final double rad =
        (badgeScreenAngle(qibla: qibla, heading: heading) - 90) *
        math.pi /
        180.0;
    return math.Point<double>(math.cos(rad) * length, math.sin(rad) * length);
  }
}
