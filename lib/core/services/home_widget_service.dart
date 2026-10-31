import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/app_time.dart';
import '../utils/logger.dart';

/// Ana ekran widget'ına yazılacak veri.
///
/// Widget, uygulama kapalıyken de çalıştığı için **yalnızca yerel**
/// `SharedPreferences` dosyasına yazılır; ağ isteği yapılmaz.
@immutable
class HomeWidgetPayload {
  const HomeWidgetPayload({
    required this.city,
    required this.prayer,
    required this.time,
    required this.target,
    required this.hijri,
  });

  final String city;
  final String prayer;
  final String time;
  final DateTime target;
  final String hijri;

  Map<String, Object?> toMap() => <String, Object?>{
    'city': city,
    'prayer': prayer,
    'time': time,
    'targetMillis': target.millisecondsSinceEpoch,
    'hijri': hijri,
  };

  /// Widget'ta gösterilecek "sonraki vakit" satırı.
  String get headline => '$prayer · $time';

  @override
  String toString() =>
      'HomeWidgetPayload($city, $prayer, $time, ${target.toIso8601String()})';
}

/// Android **ana ekran widget'ı** köprüsü.
///
/// * iOS/desktop/test ortamlarında sessizce devre dışıdır.
/// * Widget desteği olmayan cihazlarda hata üretmez.
class HomeWidgetService {
  const HomeWidgetService();

  static const MethodChannel _channel = MethodChannel('ezanai/widget');

  bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Vakit bilgisini widget'a yazar (widget yoksa da güvenle döner).
  Future<bool> sync(HomeWidgetPayload payload) async {
    if (!isSupported) return false;
    try {
      final bool? ok = await _channel.invokeMethod<bool>(
        'update',
        payload.toMap(),
      );
      return ok ?? false;
    } on PlatformException catch (error) {
      AppLog.debug('Ana ekran widget güncellenemedi: ${error.message}');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Kullanıcıya "ana ekrana ekle" sistem penceresini gösterir (Android 8+).
  Future<bool> requestPin() async {
    if (!isSupported) return false;
    try {
      final bool? ok = await _channel.invokeMethod<bool>('requestPin');
      return ok ?? false;
    } on PlatformException catch (error) {
      AppLog.debug('Widget ekleme isteği gönderilemedi: ${error.message}');
      return false;
    } on MissingPluginException {
      return false;
    }
  }

  /// Widget metnini üretir (saf fonksiyon — birim testlerle doğrulanır).
  static HomeWidgetPayload payloadFor({
    required String city,
    required String prayerLabel,
    required DateTime prayerTime,
    required String hijri,
  }) => HomeWidgetPayload(
    city: city.trim().isEmpty ? 'Konum seçilmedi' : city.trim(),
    prayer: prayerLabel,
    time: AppTime.formatTime(prayerTime, use24Hour: true),
    target: prayerTime,
    hijri: hijri,
  );
}
