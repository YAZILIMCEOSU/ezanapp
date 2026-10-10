import '../models/city.dart';
import '../models/prayer_times_day.dart';
import 'prayer_calculator.dart';

/// Namaz vakti kaynağı sözleşmesi.
///
/// Uygulama, kaynakları bir öncelik zinciri içinde dener; herhangi biri
/// başarısız olursa bir sonrakine geçer ve son çare olarak yerel hesap
/// kullanılır. Böylece API çökse bile uygulama tamamen kullanılamaz hâle
/// gelmez.
abstract interface class PrayerTimesSource {
  /// Kaynak kimliği (önbellek ve hata mesajlarında kullanılır).
  String get id;

  /// Kullanıcıya gösterilen ad.
  String get label;

  /// Kaynağın bilgi kaynağı açıklaması (ayarlar ekranında gösterilir).
  String get description;

  /// Ağ erişimi gerekli mi? (çevrimdışıyken atlanır)
  bool get requiresNetwork;

  /// Tek bir günün vakitleri.
  Future<PrayerTimesDay> fetchDay({
    required UserLocation location,
    required DateTime date,
    required CalculationMethod method,
  });

  /// Belirli bir aralık (haftalık/aylık tablolar için).
  Future<List<PrayerTimesDay>> fetchRange({
    required UserLocation location,
    required DateTime startDate,
    required DateTime endDate,
    required CalculationMethod method,
  });
}

/// Vakit kaynağı hataları — zincir yöneticisi hangi kaynağın neden
/// başarısız olduğunu anlayabilir.
class PrayerTimesSourceException implements Exception {
  const PrayerTimesSourceException(
    this.sourceId,
    this.message, {
    this.isTransient = true,
  });

  final String sourceId;
  final String message;
  final bool isTransient;

  @override
  String toString() => '[$sourceId] $message';
}
