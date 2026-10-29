import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/compass_service.dart';
import '../../core/utils/geo.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/qibla_math.dart';
import '../../core/utils/sun_position.dart';
import '../../data/models/app_settings.dart';
import '../../data/models/city.dart';
import '../../data/models/prayer.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
import '../widgets/app_shell.dart';
import '../widgets/state_views.dart';

/// Kıble ekranı: pusula, Kâbe yönü, mesafe ve kalibrasyon uyarıları.
class QiblaScreen extends ConsumerStatefulWidget {
  const QiblaScreen({super.key});

  @override
  ConsumerState<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends ConsumerState<QiblaScreen> {
  StreamSubscription<CompassReading?>? _subscription;
  CompassService? _compassService;
  CompassReading? _reading;
  double? _hardwareDeclination;
  double _fallbackDeclination = 0;
  String _declinationKey = '';
  bool _declinationFromHardware = false;
  bool _wasAligned = false;
  bool _supported = true;
  bool _showMapTab = false;
  bool _showCalibrationGuide = false;
  String? _error;

  // Güneşle Kıble doğrulaması (pusuladan bağımsız ikinci kaynak).
  String _sunKey = '';
  QiblaSunAlignment? _sunToday;
  QiblaSunAlignment? _sunBest;
  SunCoordinates? _sunNow;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final CompassService service = ref.read(compassServiceProvider);
    _compassService = service;
    // Kıble hizalanırken ekran sönmesin (rakip uygulamalarda standart davranış).
    unawaited(service.setKeepScreenOn(true));
    final bool calibrationSeen = ref
        .read(runtimeProvider)
        .preferences
        .getBool('qibla_calibration_seen_v1');
    if (!calibrationSeen && WebViewPlatform.instance != null && mounted) {
      setState(() => _showCalibrationGuide = true);
    }
    final UserLocation initialLoc = ref.read(activeLocationProvider);
    if (initialLoc.mode == LocationMode.gps) {
      unawaited(
        ref
            .read(locationControllerProvider.notifier)
            .refreshFromGps(requestPermission: true),
      );
    }
    final UserLocation location = ref.read(activeLocationProvider);
    final double trueQibla = GeoUtils.qiblaBearing(
      location.latitude,
      location.longitude,
    );
    // Sapma açısı konuma göre otomatik çözülür (WMM-2025 + donanım modeli).
    final double declination = _declinationFor(location);

    final bool supported = await service.checkSupport();
    if (!mounted) return;
    if (!supported) {
      setState(() => _supported = false);
      return;
    }

    _subscription = service.readings.listen(
      (CompassReading? reading) {
        if (!mounted) return;
        final UserLocation currentLocation = ref.read(activeLocationProvider);
        final double currentTrueQibla = GeoUtils.qiblaBearing(
          currentLocation.latitude,
          currentLocation.longitude,
        );
        final double currentDeclination = _declinationFor(currentLocation);
        final CompassReading? updated = reading?.withQibla(
          currentTrueQibla,
          declination: currentDeclination,
        );
        final bool nowAligned = updated?.isAligned ?? false;
        if (nowAligned && !_wasAligned) {
          HapticFeedback.selectionClick();
        }
        _wasAligned = nowAligned;
        setState(() {
          _reading = updated;
          _error = reading == null
              ? 'Pusula verisi okunamadı. Telefonu 8 çizer gibi hareket ettirip tekrar deneyin.'
              : null;
        });
      },
      onError: (Object error) {
        AppLog.warning('Pusula akışı hata verdi: $error');
        if (mounted) setState(() => _error = 'Pusula okunamadı.');
      },
    );
    service.start(qiblaDirection: trueQibla, declination: declination);
  }

  /// Konuma göre manyetik sapma (declination, derece; Doğu +).
  ///
  /// * Konum değiştiğinde (GPS güncellemesi, şehir değişikliği) değer
  ///   **otomatik yenilenir**; eski şehrin sapma açısı asla kullanılmaz.
  /// * İlk değer WMM-2025 modelinden **senkron** hesaplanır (anında doğru),
  ///   ardından Android `GeomagneticField` (cihazın kendi WMM hesabı) varsa
  ///   daha kesin değerle değiştirilir.
  double _declinationFor(UserLocation location) {
    final String key =
        '${location.latitude.toStringAsFixed(2)},'
        '${location.longitude.toStringAsFixed(2)}';
    if (key != _declinationKey) {
      _declinationKey = key;
      _fallbackDeclination = GeoUtils.magneticDeclination(
        location.latitude,
        location.longitude,
      );
      _hardwareDeclination = null;
      _declinationFromHardware = false;
      unawaited(_loadHardwareDeclination(location, key));
    }
    return _hardwareDeclination ?? _fallbackDeclination;
  }

  Future<void> _loadHardwareDeclination(
    UserLocation location,
    String key,
  ) async {
    final CompassService service = ref.read(compassServiceProvider);
    final double value = await service.getGeomagneticDeclination(
      location.latitude,
      location.longitude,
    );
    if (!mounted || key != _declinationKey) return;
    setState(() {
      _hardwareDeclination = value;
      _declinationFromHardware = service.lastDeclinationFromHardware;
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    unawaited(_compassService?.setKeepScreenOn(false));
    unawaited(_compassService?.stop());
    super.dispose();
  }

  /// Güneşle Kıble doğrulaması verisini (konum başına bir kez) hesaplar.
  ///
  /// Hesap ~10 ms sürer; kare çizimini bloklamamak için kare sonrasında çağrılır.
  void _refreshSunCheck(UserLocation location) {
    final String key =
        '${location.latitude.toStringAsFixed(3)},'
        '${location.longitude.toStringAsFixed(3)}';
    if (key == _sunKey) return;
    _sunKey = key;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final DateTime now = DateTime.now();
      final QiblaSunAlignment? today = QiblaSunCheck.bestOn(
        day: now,
        latitude: location.latitude,
        longitude: location.longitude,
        toleranceDegrees: 15,
      );
      final QiblaSunAlignment? best = QiblaSunCheck.bestUpcoming(
        from: now,
        latitude: location.latitude,
        longitude: location.longitude,
      );
      final SunCoordinates sunNow = SunPosition.at(
        utc: now.toUtc(),
        latitude: location.latitude,
        longitude: location.longitude,
      );
      if (!mounted) return;
      setState(() {
        _sunToday = today;
        _sunBest = best;
        _sunNow = sunNow;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final double trueQibla = ref.watch(qiblaDirectionProvider);
    final double distance = ref.watch(qiblaDistanceProvider);
    final UserLocation location = ref.watch(activeLocationProvider);
    final double declination = _declinationFor(location);
    final double compassQibla = GeoUtils.compassQiblaBearing(
      location.latitude,
      location.longitude,
    );
    final CompassReading? activeReading = _reading?.withQibla(
      trueQibla,
      declination: declination,
    );
    _refreshSunCheck(location);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Kıble Pusulası'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Pusula Kalibrasyonu',
            onPressed: () {
              setState(() => _showCalibrationGuide = true);
            },
            icon: const Icon(Icons.compass_calibration_rounded, size: 22),
          ),
          IconButton(
            tooltip: 'Yakındaki Camiler ve Navigasyon',
            onPressed: () => context.push(AppRoutes.mosques),
            icon: const Icon(Icons.mosque_outlined, size: 22),
          ),
        ],
      ),
      body: _showCalibrationGuide
          ? _DiyanetCalibrationGuideView(
              onContinue: () async {
                setState(() => _showCalibrationGuide = false);
                await ref
                    .read(runtimeProvider)
                    .preferences
                    .setBool('qibla_calibration_seen_v1', true);
                await ref.read(compassServiceProvider).resetCompass();
                unawaited(
                  ref
                      .read(locationControllerProvider.notifier)
                      .refreshFromGps(requestPermission: true),
                );
              },
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xs,
                  ),
                  child: Row(
                    children: <Widget>[
                      const Icon(Icons.place_outlined, size: 16),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          location.city?.displayName ?? 'Mevcut konum',
                          style: theme.textTheme.labelLarge,
                        ),
                      ),
                      IconButton(
                        tooltip: 'GPS ile tam konumumu güncelle',
                        onPressed: () => ref
                            .read(locationControllerProvider.notifier)
                            .refreshFromGps(),
                        icon: const Icon(Icons.my_location_rounded, size: 18),
                      ),
                      TextButton(
                        onPressed: () => context.push(AppRoutes.cities),
                        child: const Text('Değiştir'),
                      ),
                    ],
                  ),
                ),
                // Diyanet Kıble Pusulası tarzı Pusula | Harita sekme seçici
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.xs,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() => _showMapTab = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: !_showMapTab
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.explore_rounded,
                                    size: 18,
                                    color: !_showMapTab
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Pusula',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: !_showMapTab
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() => _showMapTab = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: _showMapTab
                                    ? theme.colorScheme.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Icon(
                                    Icons.map_outlined,
                                    size: 18,
                                    color: _showMapTab
                                        ? theme.colorScheme.onPrimary
                                        : theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Harita',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      fontWeight: FontWeight.w800,
                                      color: _showMapTab
                                          ? theme.colorScheme.onPrimary
                                          : theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_error != null)
                  StatusBanner(
                    icon: Icons.warning_amber_rounded,
                    message: _error!,
                  ),
                if (activeReading?.needsCalibration ?? false)
                  StatusBanner(
                    icon: Icons.screen_rotation_alt_rounded,
                    message: activeReading!.calibrationMessage,
                  ),
                if (!_supported)
                  const StatusBanner(
                    icon: Icons.sensors_off_rounded,
                    message:
                        'Cihazınızda pusula sensörü bulunamadı. Aşağıdaki dereceyi '
                        'kullanarak yönünüzü ayarlayabilirsiniz.',
                  ),
                if (_showMapTab)
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: _QiblaMapViewCard(
                      location: location,
                      trueQibla: trueQibla,
                      distanceKm: distance,
                      heading: activeReading?.heading,
                      onOpenPin: () => _openExactPin(location, compassQibla),
                      onOpenRoute: () => _openMap(location),
                    ),
                  )
                else ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Center(
                    // 320 dp'lik küçük ekranlarda taşmayı önler; tablette
                    // aynı oranda büyütür.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: _CompassDial(
                        reading: activeReading,
                        qibla: trueQibla,
                        displayQibla: compassQibla,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                    ),
                    child: _QiblaDirectionBanner(
                      reading: activeReading,
                      qibla: compassQibla,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.lg),
                _InfoRow(
                  icon: Icons.mosque_rounded,
                  label: 'Kıble açısı (gerçek kuzey · Diyanet)',
                  value: '${trueQibla.toStringAsFixed(1)}°',
                ),
                _InfoRow(
                  icon: Icons.explore_outlined,
                  label: 'Elde pusula için Kıble açısı',
                  value:
                      '${GeoUtils.magneticNeedleQiblaBearing(location.latitude, location.longitude).toStringAsFixed(1)}°',
                ),
                _InfoRow(
                  icon: Icons.straighten_rounded,
                  label: 'Kâbe\'ye mesafe',
                  value: '${distance.toStringAsFixed(0)} km',
                ),
                _InfoRow(
                  icon: Icons.location_city_rounded,
                  label: 'Bulunduğunuz koordinat',
                  value: location.coordinates,
                ),
                _InfoRow(
                  icon: Icons.compass_calibration_outlined,
                  label: 'Manyetik sapma (WMM)',
                  value:
                      '${declination >= 0 ? '+' : ''}${declination.toStringAsFixed(1)}°',
                ),
                _InfoRow(
                  icon: Icons.verified_rounded,
                  label: 'Sapma modeli',
                  value: _declinationFromHardware
                      ? 'Android GeomagneticField (WMM)'
                      : 'WMM-2025 dahili model',
                ),
                _InfoRow(
                  icon: Icons.speed_rounded,
                  label: 'Ölçüm hassasiyeti',
                  value: activeReading == null
                      ? 'Ölçülüyor…'
                      : '±${activeReading.accuracy.toStringAsFixed(0)}°',
                ),
                _InfoRow(
                  icon: Icons.phone_android_rounded,
                  label: 'Telefon tutuşu',
                  value: switch (activeReading?.pose) {
                    'upright' => 'Dik · arka kamera yönü',
                    'blend' => 'Geçiş açısı · düz tutun',
                    _ =>
                      activeReading == null
                          ? 'Ölçülüyor…'
                          : 'Yatay · üst kenar',
                  },
                ),
                if (activeReading != null)
                  _InfoRow(
                    icon: Icons.screen_lock_rotation_rounded,
                    label: 'Telefonun baktığı yön',
                    value:
                        '${activeReading.heading.toStringAsFixed(1)}° · '
                        'Kıble farkı ${activeReading.differenceToQibla!.abs().toStringAsFixed(1)}°',
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    0,
                  ),
                  child: FilledButton.tonalIcon(
                    onPressed: () => context.push(AppRoutes.mosques),
                    icon: const Icon(Icons.mosque_rounded, size: 18),
                    label: const Text('Yakındaki Camileri Bul & Yol Tarifi Al'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.sm,
                    AppSpacing.xl,
                    0,
                  ),
                  child: OutlinedButton.icon(
                    onPressed: () => _showSensorTestSheet(
                      context,
                      location: location,
                      trueQibla: trueQibla,
                      declination: declination,
                      reading: activeReading,
                    ),
                    icon: const Icon(Icons.fact_check_outlined, size: 18),
                    label: const Text(
                      'Hata & Sensör Test Modu (Canlı Tanılama)',
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.md,
                    AppSpacing.xl,
                    0,
                  ),
                  child: _SunVerificationCard(
                    today: _sunToday,
                    upcoming: _sunBest,
                    now: _sunNow,
                    qibla: trueQibla,
                  ),
                ),
                const SectionHeader(
                  title: 'Kıble nasıl bulunur? (Diyanet Yöntemi)',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                  ),
                  child: Text(
                    '1. Telefonu yere paralel (avuç içinde veya masada düz) tutun.\n'
                    '2. Üstteki Kıble kutusunda (${compassQibla.toStringAsFixed(1)}°) ve çember üzerindeki Kâbe simgesinde tam Kıble yönü görünür.\n'
                    '3. Ortadaki ibre ve Kâbe simgesi en üst noktaya (12 yönüne) geldiğinde "✓ Kıble" onayını görürsünüz.\n'
                    '4. Mıknatıs, mıknatıslı kılıf ve elektronik parazitlerden uzak durun.',
                    style: const TextStyle(height: 1.6),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _openExactPin(UserLocation location, double qibla) async {
    final String label =
        'Konumum (${location.label}) • Kıble Açısı: ${qibla.toStringAsFixed(1)}°';
    final Uri geoUri = Uri.parse(
      'geo:${location.latitude},${location.longitude}?q=${location.latitude},${location.longitude}(${Uri.encodeComponent(label)})',
    );
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
    );
    bool opened = false;
    try {
      opened = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!opened) {
      try {
        opened = await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<void> _openMap(UserLocation location) async {
    // Araba yolu (otoyol) yerine kullanıcının tam konumunu ve Kıble açısını
    // harita üzerinde doğrudan işaretler.
    final double qibla = GeoUtils.qiblaBearing(
      location.latitude,
      location.longitude,
    );
    await _openExactPin(location, qibla);
  }

  Future<void> _showSensorTestSheet(
    BuildContext context, {
    required UserLocation location,
    required double trueQibla,
    required double declination,
    required CompassReading? reading,
  }) async {
    final Map<String, Object?> diag = await ref
        .read(compassServiceProvider)
        .getDiagnostics();
    if (!context.mounted) return;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (BuildContext sheetContext) {
        final ThemeData theme = Theme.of(sheetContext);
        final NotificationSettings notif = ref
            .watch(settingsProvider)
            .notifications;
        final String sourceLabel = switch (reading?.sensorSource ??
            diag['sensorSource']) {
          'fusion_mag_anchored' =>
            'Gerçek Manyetik Kuzeye Çapalı Jiroskop (Hibrit 60 Hz)',
          'geomagnetic_matrix' =>
            'Doğrudan İvmeölçer + Manyetometre Matrisi (Gerçek Kuzey)',
          'geomagnetic_vector' => 'Jeomanyetik Rotasyon Vektörü',
          'rotation_vector' => 'Rotasyon Vektörü',
          _ => 'Aktif Pusula Sensörü',
        };
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              0,
              AppSpacing.xl,
              AppSpacing.xl,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                    'Hata & Sensör Test Modu (Canlı Kontrol)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Kıble sensörü, GPS ilçe eşleşmesi ve bildirim/ezan sesi kanallarının canlı doğrulama raporu:',
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _InfoRow(
                    icon: Icons.sensors_rounded,
                    label: 'Sensör Motoru',
                    value: sourceLabel,
                  ),
                  _InfoRow(
                    icon: Icons.explore_rounded,
                    label: 'Ham Manyetik Kuzey',
                    value: reading?.magneticHeading != null
                        ? '${reading!.magneticHeading!.toStringAsFixed(1)}°'
                        : 'Okunuyor…',
                  ),
                  _InfoRow(
                    icon: Icons.navigation_rounded,
                    label:
                        'Gerçek Kuzey (Sapma +${declination.toStringAsFixed(1)}°)',
                    value: reading != null
                        ? '${reading.heading.toStringAsFixed(1)}°'
                        : 'Okunuyor…',
                  ),
                  _InfoRow(
                    icon: Icons.mosque_rounded,
                    label: 'Hedef Kıble Açısı (${location.label})',
                    value: '${trueQibla.toStringAsFixed(1)}°',
                  ),
                  _InfoRow(
                    icon: Icons.bolt_rounded,
                    label: 'Manyetik Alan Şiddeti',
                    value: reading?.fieldStrengthMicroTesla != null
                        ? '${reading!.fieldStrengthMicroTesla!.toStringAsFixed(1)} µT'
                        : 'Normal (25–65 µT)',
                  ),
                  _InfoRow(
                    icon: Icons.notifications_active_outlined,
                    label: 'Aktif Bildirim / Ezan Modu',
                    value: notif.adhanSound == AdhanSound.systemDefault
                        ? 'Telefon Bildirim Sesi (Ezan Okunmaz)'
                        : notif.adhanSound.label,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton.icon(
                    onPressed: () async {
                      await ref.read(compassServiceProvider).resetCompass();
                      await ref
                          .read(locationControllerProvider.notifier)
                          .refreshFromGps(requestPermission: true);
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                      }
                    },
                    icon: const Icon(Icons.compass_calibration_rounded),
                    label: const Text('Pusulayı Sıfırla & GPS Konumunu Yenile'),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await ref.read(runtimeProvider).audio.stop();
                      await ref
                          .read(settingsControllerProvider.notifier)
                          .updateNotifications(
                            notif.copyWith(
                              adhanSound: AdhanSound.systemDefault,
                              perPrayerSound: const <Prayer, AdhanSound>{},
                              inAppAdhanEnabled: false,
                            ),
                          );
                      await ref
                          .read(compassServiceProvider)
                          .playSystemNotificationSound();
                      if (sheetContext.mounted) {
                        Navigator.of(sheetContext).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Tüm vakitler "Telefon Bildirim Sesi (Ezan Okunmaz)" moduna alındı.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.notifications_outlined),
                    label: const Text(
                      'Sadece Telefon Bildirim Sesine Geç (Ezan Okumasın)',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// e-Diyanet Kıble Pusulası "Pusula Kalibrasyonu" tam ekran rehberi (8 rakamı çizimi).
class _DiyanetCalibrationGuideView extends StatelessWidget {
  const _DiyanetCalibrationGuideView({required this.onContinue});

  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.xl,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 190,
              height: 110,
              child: CustomPaint(painter: _InfinityPhoneCalibrationPainter()),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Pusula Kalibrasyonu',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Doğru yönü bulmak için telefonunuzu kalibre\nedin:',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
            ),
            const SizedBox(height: AppSpacing.xl),
            const _CalibrationStepRow(
              icon: Icons.gesture_rounded,
              text: 'Telefonunuzu 8 rakamı çizer gibi döndürün',
            ),
            const SizedBox(height: AppSpacing.md),
            const _CalibrationStepRow(
              icon: Icons.phonelink_ring_rounded,
              text: 'Manyetik alanlardan uzak durun (bilgisayar, hoparlör vb.)',
            ),
            const SizedBox(height: AppSpacing.md),
            const _CalibrationStepRow(
              icon: Icons.rotate_right_rounded,
              text: 'Telefonu yavaşça farklı yönlere doğru hareket ettirin',
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 220,
              height: 48,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF455A64),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                onPressed: onContinue,
                child: const Text(
                  'Anladım, Devam Et',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalibrationStepRow extends StatelessWidget {
  const _CalibrationStepRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Icon(icon, size: 26, color: const Color(0xFF455A64)),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.38,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// e-Diyanet tarzı 8 (sonsuzluk) halkası ve elde telefon kalibrasyon ikonu.
class _InfinityPhoneCalibrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    const double loopRadius = 32.0;
    final Offset leftCenter = Offset(center.dx - 34, center.dy + 4);
    final Offset rightCenter = Offset(center.dx + 34, center.dy + 4);

    // Turkuvaz alt gölge halkalar
    final Paint tealPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.0
      ..color = const Color(0xFF00796B);
    canvas.drawArc(
      Rect.fromCircle(
        center: leftCenter + const Offset(0, 3),
        radius: loopRadius,
      ),
      0.2,
      math.pi * 1.3,
      false,
      tealPaint,
    );
    canvas.drawArc(
      Rect.fromCircle(
        center: rightCenter + const Offset(0, -3),
        radius: loopRadius,
      ),
      math.pi + 0.2,
      math.pi * 1.3,
      false,
      tealPaint,
    );

    // Siyah ana 8 (sonsuzluk) halkaları
    final Paint blackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 10.5
      ..color = const Color(0xFF111111);
    canvas.drawCircle(leftCenter, loopRadius, blackPaint);
    canvas.drawCircle(rightCenter, loopRadius, blackPaint);

    // Yön oku (yeşil üçgen)
    final Path arrow = Path()
      ..moveTo(center.dx - 16, center.dy - 22)
      ..lineTo(center.dx - 2, center.dy - 14)
      ..lineTo(center.dx - 14, center.dy - 6)
      ..close();
    canvas.drawPath(arrow, Paint()..color = const Color(0xFF00796B));

    // Ortada telefon çerçevesi
    final RRect phoneRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 26, height: 48),
      const Radius.circular(5),
    );
    canvas.drawRRect(phoneRect, Paint()..color = Colors.white);
    canvas.drawRRect(
      phoneRect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = const Color(0xFF00796B),
    );
    // Telefon ekran içi çapraz çizgiler
    canvas.drawLine(
      center + const Offset(-7, -10),
      center + const Offset(7, -2),
      Paint()
        ..strokeWidth = 1.6
        ..color = const Color(0xFF00796B),
    );
    canvas.drawLine(
      center + const Offset(-7, 2),
      center + const Offset(7, 10),
      Paint()
        ..strokeWidth = 1.6
        ..color = const Color(0xFF00796B),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// e-Diyanet minareli yuvarlak Kâbe rozeti.
class _DiyanetKaabaBadge extends StatelessWidget {
  const _DiyanetKaabaBadge({this.size = 46});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Color(0xFF81D4FA), Color(0xFFB3E5FC)],
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          // Sol ve sağ minareler
          Positioned(
            left: size * 0.22,
            top: size * 0.14,
            child: Container(
              width: 3,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Positioned(
            right: size * 0.22,
            top: size * 0.14,
            child: Container(
              width: 3,
              height: size * 0.45,
              decoration: BoxDecoration(
                color: const Color(0xFFFFD54F),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Kâbe-i Muazzama siyah küp + altın kuşak
          Positioned(
            bottom: size * 0.12,
            child: Container(
              width: size * 0.48,
              height: size * 0.42,
              decoration: BoxDecoration(
                color: const Color(0xFF1A233A),
                borderRadius: BorderRadius.circular(3),
              ),
              child: Column(
                children: <Widget>[
                  SizedBox(height: size * 0.10),
                  Container(
                    height: 3.5,
                    width: double.infinity,
                    color: const Color(0xFFFFD54F),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Canlı sağ/sol yönlendirme bandı — e-Diyanet Kıble Pusulası birebir onay çubuğu.
class _QiblaDirectionBanner extends StatelessWidget {
  const _QiblaDirectionBanner({required this.reading, required this.qibla});

  final CompassReading? reading;
  final double qibla;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double? diff = reading?.differenceToQibla;
    final bool aligned = reading?.isAligned ?? false;
    final bool close = reading?.isClose ?? false;

    final Color borderColor = aligned
        ? const Color(0xFF2E7D32)
        : close
        ? AppColors.warning
        : const Color(0xFF00897B);
    final Color fillColor = aligned
        ? const Color(0xFFDCEEDC)
        : borderColor.withValues(alpha: 0.12);

    final String instruction;
    final IconData icon;
    if (diff == null) {
      instruction =
          'Kıble Açısı: ${qibla.toStringAsFixed(1)}° — Pusula bekleniyor';
      icon = Icons.explore_outlined;
    } else if (aligned) {
      instruction = 'Kıble';
      icon = Icons.check_circle_outline_rounded;
    } else if (diff > 0) {
      instruction = 'Telefonu ${diff.abs().round()}° SAĞA çevirin ▶';
      icon = Icons.turn_right_rounded;
    } else {
      instruction = '◀ Telefonu ${diff.abs().round()}° SOLA çevirin';
      icon = Icons.turn_left_rounded;
    }

    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1.4),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Align(
            alignment: Alignment.centerLeft,
            child: Icon(icon, color: borderColor, size: 26),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 34),
            child: Text(
              instruction,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: aligned
                    ? const Color(0xFF1B5E20)
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pusula kadranı — e-Diyanet Kıble Pusulası birebir beyaz kadran & Kâbe oku tasarımı.
class _CompassDial extends StatelessWidget {
  const _CompassDial({
    required this.reading,
    required this.qibla,
    required this.displayQibla,
  });

  final CompassReading? reading;
  final double qibla;
  final double displayQibla;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;
    final double heading = reading?.heading ?? 0;
    // e-Diyanet geometrisi tek bir test edilebilir kaynaktan gelir (QiblaMath).
    final double qiblaRelative =
        reading?.differenceToQibla ??
        QiblaMath.badgeScreenAngle(qibla: qibla, heading: heading);
    final bool aligned = reading?.isAligned ?? false;
    // e-Diyanet üst kutu: Canlı pusula derecesi (ör. 153.7°) 60 FPS güncellenir.
    // Ölçüm gelmeden **uydurma bir açı gösterilmez** ("—").
    final String shownTopText = reading == null
        ? '—'
        : '${reading!.heading.toStringAsFixed(1)}°';

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // e-Diyanet üst yeşil Kıble kutusu (Kâbe rozeti + Kıble + Canlı Derece)
        Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
          decoration: BoxDecoration(
            color: aligned ? const Color(0xFFB9E4C9) : const Color(0xFFE0F2F1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: aligned
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF26A69A),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const _DiyanetKaabaBadge(size: 42),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Kıble (${displayQibla.toStringAsFixed(1)}°)',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF37474F),
                    ),
                  ),
                  Text(
                    shownTopText,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: aligned
                          ? const Color(0xFF1B5E20)
                          : const Color(0xFF263238),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(
          width: 310,
          height: 310,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // e-Diyanet beyaz dairesel kadran zemini ve açık yeşil dış çember
              AnimatedContainer(
                duration: const Duration(milliseconds: 120),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  border: Border.all(
                    color: aligned
                        ? const Color(0xFF81C784)
                        : const Color(0xFFB2DFDB),
                    width: 2.4,
                  ),
                ),
              ),
              // Dış derece çizgileri, artı (+) eksen çizgisi ve N/E/S/W yön harfleri
              Transform.rotate(
                angle: QiblaMath.dialRotation(heading: heading) * math.pi / 180,
                child: CustomPaint(
                  size: const Size(310, 310),
                  painter: _CompassPainter(
                    color: theme.colorScheme.onSurfaceVariant,
                    textColor: theme.colorScheme.onSurface,
                    qiblaDegrees: qibla,
                    headingDegrees: heading,
                  ),
                ),
              ),
              // Kâbe yuvarlak rozeti: Pusula kadranı üzerinde Kıble açısına (151.4°) bağlı döner
              Transform.rotate(
                angle: qiblaRelative * math.pi / 180,
                child: const Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: _DiyanetKaabaBadge(size: 52),
                  ),
                ),
              ),
              // e-Diyanet sabit telefon üst yön oku (12 yönü) + Kâbe rozeti hiza rehberi:
              // Telefonu çevirdikçe Kâbe rozeti 12 yönündeki bu sabit okun ucuna gelir.
              CustomPaint(
                size: const Size(310, 310),
                painter: _QiblaNeedlePainter(
                  needleColor: aligned
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFF2E7D32).withValues(alpha: 0.85),
                  aligned: aligned,
                  qiblaRelativeDegrees: qiblaRelative,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kıble Harita Sekmesi — Konumdan Kâbe'ye direkt açı ve görsel coğrafi Kâbe hattı.
class _QiblaMapViewCard extends StatelessWidget {
  const _QiblaMapViewCard({
    required this.location,
    required this.trueQibla,
    required this.distanceKm,
    required this.heading,
    required this.onOpenPin,
    required this.onOpenRoute,
  });

  final UserLocation location;
  final double trueQibla;
  final double distanceKm;
  final double? heading;
  final VoidCallback onOpenPin;
  final VoidCallback onOpenRoute;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.emerald500.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mosque_rounded,
                  color: AppColors.emerald500,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      'Haritada Kâbe Hattı',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      '${location.label} → Kâbe-i Muazzama (${distanceKm.toStringAsFixed(0)} km)',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          // e-Diyanet & Ezan Vakti Pro tarzı Canlı Uydu/Sokak Kıble Haritası (Bina çatısı üzerinden Kâbe hattı)
          Container(
            height: 320,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF26A69A).withValues(alpha: 0.45),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: _LiveQiblaInteractiveMap(
              latitude: location.latitude,
              longitude: location.longitude,
              trueQiblaDegrees: trueQibla,
              headingDegrees: heading,
              locationLabel: location.label,
              distanceKm: distanceKm,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Kıble açısı (gerçek kuzey)'),
                    Text(
                      '${trueQibla.toStringAsFixed(1)}°',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.emerald500,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text('Elde pusula için açı'),
                    Text(
                      '${GeoUtils.magneticNeedleQiblaBearing(location.latitude, location.longitude).toStringAsFixed(1)}°',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          FilledButton.icon(
            onPressed: onOpenRoute,
            icon: const Icon(Icons.map_rounded),
            label: const Text('Haritada Kâbe Yönünü ve Rotayı Aç'),
          ),
          const SizedBox(height: AppSpacing.sm),
          OutlinedButton.icon(
            onPressed: onOpenPin,
            icon: const Icon(Icons.my_location_rounded),
            label: const Text('Tam Konumumu Haritada İşaretle'),
          ),
        ],
      ),
    );
  }
}

/// e-Diyanet tarzı uygulama içi görsel Kâbe Hattı ve Coğrafi Radar Haritası.
class _QiblaGeodesicMapPainter extends CustomPainter {
  const _QiblaGeodesicMapPainter({
    required this.trueQiblaDegrees,
    required this.headingDegrees,
    required this.locationLabel,
    required this.distanceKm,
  });

  final double trueQiblaDegrees;
  final double? headingDegrees;
  final String locationLabel;
  final double distanceKm;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width * 0.38, size.height * 0.36);

    // 1. Coğrafi enlem/boylam ızgara çizgileri
    final Paint gridPaint = Paint()
      ..strokeWidth = 0.8
      ..color = const Color(0xFF00796B).withValues(alpha: 0.14);
    for (double x = 24; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 24; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // 2. Mesafe halkaları (radar)
    for (final double r in <double>[36, 72, 108]) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..color = const Color(0xFF00796B).withValues(alpha: 0.18),
      );
    }

    // 3. Eğer pusula verisi varsa telefonun baktığı görüş konisi
    if (headingDegrees != null) {
      final double hRad = (headingDegrees! - 90) * math.pi / 180;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: 68),
        hRad - 0.32,
        0.64,
        true,
        Paint()
          ..style = PaintingStyle.fill
          ..color = const Color(0xFF00897B).withValues(alpha: 0.22),
      );
    }

    // 4. Konumdan Kâbe'ye Büyük Daire (Jeodezik) Kıble Hattı
    final double qRad = (trueQiblaDegrees - 90) * math.pi / 180;
    final Offset kaabaPos =
        center + Offset(math.cos(qRad) * 112, math.sin(qRad) * 112);

    canvas.drawLine(
      center,
      kaabaPos,
      Paint()
        ..strokeWidth = 3.2
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF00796B),
    );

    // 5. Kullanıcı konumu pimi
    canvas.drawCircle(center, 8, Paint()..color = const Color(0xFF00897B));
    canvas.drawCircle(center, 3.5, Paint()..color = Colors.white);

    // 6. Kâbe-i Muazzama pimi
    canvas.drawCircle(kaabaPos, 14, Paint()..color = const Color(0xFF1C1C1C));
    canvas.drawRect(
      Rect.fromCenter(
        center: kaabaPos - const Offset(0, 3),
        width: 16,
        height: 3,
      ),
      Paint()..color = const Color(0xFFFFD54F),
    );

    // 7. Etiketler
    final TextPainter userLabel = TextPainter(
      text: TextSpan(
        text: 'Konumunuz\n(${trueQiblaDegrees.toStringAsFixed(1)}°)',
        style: const TextStyle(
          color: Color(0xFF004D40),
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    userLabel.paint(canvas, center - Offset(userLabel.width / 2, 34));

    final TextPainter kaabaLabel = TextPainter(
      text: TextSpan(
        text: 'Kâbe (${distanceKm.toStringAsFixed(0)} km)',
        style: const TextStyle(
          color: Color(0xFF1C1C1C),
          fontSize: 11,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    kaabaLabel.paint(
      canvas,
      Offset(
        (kaabaPos.dx - kaabaLabel.width / 2).clamp(
          8,
          size.width - kaabaLabel.width - 8,
        ),
        (kaabaPos.dy + 16).clamp(8, size.height - 20),
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _QiblaGeodesicMapPainter oldDelegate) =>
      oldDelegate.trueQiblaDegrees != trueQiblaDegrees ||
      oldDelegate.headingDegrees != headingDegrees;
}

/// Merkezden 12 yönüne (telefonun baktığı yöne) uzanan e-Diyanet Kıble Oku.
class _QiblaNeedlePainter extends CustomPainter {
  const _QiblaNeedlePainter({
    required this.needleColor,
    required this.aligned,
    required this.qiblaRelativeDegrees,
  });

  final Color needleColor;
  final bool aligned;
  final double qiblaRelativeDegrees;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    const double tipY = 74.0;

    // Kıble henüz hizalı değilse, Kâbe rozetinin olduğu yöne ince kesikli rehber çizgi
    // ve 12 yönüne dönüş yayını çiz ki kullanıcı Kâbe rozetini okun ucuna nasıl getireceğini anında görsün.
    if (!aligned && qiblaRelativeDegrees.abs() > 3.0) {
      final double rad = (qiblaRelativeDegrees - 90.0) * math.pi / 180.0;
      final Paint guidePaint = Paint()
        ..strokeWidth = 1.8
        ..strokeCap = StrokeCap.round
        ..color = const Color(0xFF2E7D32).withValues(alpha: 0.32);
      for (double r = 22.0; r < 92.0; r += 10.0) {
        final Offset p1 = center + Offset(math.cos(rad) * r, math.sin(rad) * r);
        final Offset p2 =
            center +
            Offset(
              math.cos(rad) * math.min(r + 5.0, 92.0),
              math.sin(rad) * math.min(r + 5.0, 92.0),
            );
        canvas.drawLine(p1, p2, guidePaint);
      }
    }

    // Ana Kıble ok gövdesi (e-Diyanet birebir: merkez yeşil noktadan 12 yönüne sabit dikey ok)
    canvas.drawLine(
      center,
      Offset(center.dx, tipY + 12),
      Paint()
        ..strokeWidth = 3.6
        ..strokeCap = StrokeCap.round
        ..color = needleColor,
    );

    // Belirgin yeşil ok ucu (12 yönü üçgeni)
    final Path arrowHead = Path()
      ..moveTo(center.dx, tipY)
      ..lineTo(center.dx - 7.5, tipY + 15)
      ..lineTo(center.dx + 7.5, tipY + 15)
      ..close();
    canvas.drawPath(
      arrowHead,
      Paint()
        ..style = PaintingStyle.fill
        ..color = needleColor,
    );

    // Merkez yeşil pivot noktası (e-Diyanet birebir görünümü)
    canvas.drawCircle(center, 8.5, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) =>
      oldDelegate.needleColor != needleColor ||
      oldDelegate.aligned != aligned ||
      oldDelegate.qiblaRelativeDegrees != qiblaRelativeDegrees;
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter({
    required this.color,
    required this.textColor,
    required this.qiblaDegrees,
    this.headingDegrees = 0,
  });

  final Color color;
  final Color textColor;
  final double qiblaDegrees;
  final double headingDegrees;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 8;

    // e-Diyanet tarzı merkez artı (+) eksen çizgileri (N-S ve E-W)
    final Paint crossPaint = Paint()
      ..strokeWidth = 1.0
      ..color = color.withValues(alpha: 0.35);
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 72),
      Offset(center.dx, center.dy + radius - 72),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius + 72, center.dy),
      Offset(center.dx + radius - 72, center.dy),
      crossPaint,
    );

    // 15° (ince gri), 30° (siyah) ve 90° (kalın yeşil) kadran çizgileri
    for (int degree = 0; degree < 360; degree += 15) {
      final bool major = degree % 30 == 0;
      final bool cardinal = degree % 90 == 0;
      final double angle = (degree - 90) * math.pi / 180;
      final double outer = radius - 4;
      final double inner = outer - (cardinal ? 28 : (major ? 22 : 12));
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        Paint()
          ..strokeWidth = cardinal ? 2.8 : (major ? 1.5 : 1.0)
          ..color = cardinal
              ? const Color(0xFF2E7D32)
              : major
              ? textColor.withValues(alpha: 0.85)
              : color.withValues(alpha: 0.38),
      );
    }

    // e-Diyanet N / E / S / W yön harfleri
    const List<String> labels = <String>['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final double angle = (i * 90 - 90) * math.pi / 180;
      final bool isNorth = i == 0;
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: isNorth ? const Color(0xFF2E7D32) : textColor,
            fontSize: isNorth ? 22 : 16,
            fontWeight: FontWeight.w900,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final Offset labelCenter =
          center +
          Offset(
            math.cos(angle) * (radius - 50),
            math.sin(angle) * (radius - 50),
          );
      canvas.save();
      canvas.translate(labelCenter.dx, labelCenter.dy);
      canvas.rotate(i * math.pi / 2);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.color != color ||
      oldDelegate.textColor != textColor ||
      oldDelegate.qiblaDegrees != qiblaDegrees ||
      oldDelegate.headingDegrees != headingDegrees;
}

/// e-Diyanet & Ezan Vakti Pro tarzı Canlı Uydu ve Sokak Haritası üzerinde Kâbe Hattı.
///
/// Kullanıcının tam sokak/bina çatısı üzerinde Kâbe'ye uzanan jeodezik Kıble
/// çizgisini gösterir; WebView desteklenmeyen test ortamlarında otomatik olarak
/// [_QiblaGeodesicMapPainter] yedeğine düşer.
class _LiveQiblaInteractiveMap extends StatefulWidget {
  const _LiveQiblaInteractiveMap({
    required this.latitude,
    required this.longitude,
    required this.trueQiblaDegrees,
    required this.headingDegrees,
    required this.locationLabel,
    required this.distanceKm,
  });

  final double latitude;
  final double longitude;
  final double trueQiblaDegrees;
  final double? headingDegrees;
  final String locationLabel;
  final double distanceKm;

  @override
  State<_LiveQiblaInteractiveMap> createState() =>
      _LiveQiblaInteractiveMapState();
}

class _LiveQiblaInteractiveMapState extends State<_LiveQiblaInteractiveMap> {
  WebViewController? _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    try {
      if (WebViewPlatform.instance == null) return;
      final WebViewController ctrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFE0F2F1))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              if (mounted) {
                setState(() => _ready = true);
                _syncHeading();
              }
            },
          ),
        )
        ..loadHtmlString(_buildHtml());
      _controller = ctrl;
    } catch (_) {
      _controller = null;
    }
  }

  @override
  void didUpdateWidget(covariant _LiveQiblaInteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.latitude - widget.latitude).abs() > 1e-4 ||
        (oldWidget.longitude - widget.longitude).abs() > 1e-4) {
      try {
        _controller?.loadHtmlString(_buildHtml());
      } catch (_) {}
    } else if (oldWidget.headingDegrees != widget.headingDegrees && _ready) {
      _syncHeading();
    }
  }

  void _syncHeading() {
    final double? h = widget.headingDegrees;
    if (h == null || _controller == null) return;
    try {
      _controller!.runJavaScript(
        'window.updateHeading && window.updateHeading(${h.toStringAsFixed(1)});',
      );
    } catch (_) {}
  }

  String _buildHtml() {
    final double lat = widget.latitude;
    final double lon = widget.longitude;
    const double kaabaLat = AppConstants.kaabaLat;
    const double kaabaLon = AppConstants.kaabaLng;
    final double qibla = widget.trueQiblaDegrees;
    return '''
<!DOCTYPE html>
<html>
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width,initial-scale=1.0,maximum-scale=1.0,user-scalable=no"/>
<link rel="stylesheet" href="https://unpkg.com/leaflet@1.9.4/dist/leaflet.css"/>
<script src="https://unpkg.com/leaflet@1.9.4/dist/leaflet.js"></script>
<style>
  html, body, #map { margin:0; padding:0; width:100%; height:100%; background:#E0F2F1; font-family:sans-serif; }
  .ctrl-bar {
    position:absolute; top:8px; right:8px; z-index:1000;
    display:flex; gap:6px;
  }
  .btn {
    background:#ffffff; color:#00695C; border:1.5px solid #26A69A;
    border-radius:10px; padding:6px 10px; font-size:11px; font-weight:800;
    box-shadow:0 2px 6px rgba(0,0,0,0.18); cursor:pointer;
  }
  .btn.active { background:#00796B; color:#ffffff; }
  .badge {
    position:absolute; bottom:8px; left:8px; z-index:1000;
    background:rgba(0,77,64,0.9); color:#fff; padding:6px 10px;
    border-radius:10px; font-size:11px; font-weight:700;
  }
</style>
</head>
<body>
<div id="map"></div>
<div class="ctrl-bar">
  <button id="btnSat" class="btn active" onclick="setLayer('sat')">Uydu (Bina)</button>
  <button id="btnOsm" class="btn" onclick="setLayer('osm')">Sokak</button>
  <button class="btn" onclick="focusUser()">Binama Yakınlaş</button>
</div>
<div class="badge">Yeşil-Altın Çizgi = Tam Kıble Yönü (${qibla.toStringAsFixed(1)}°)</div>
<script>
  var userLat = $lat;
  var userLon = $lon;
  var kaabaLat = $kaabaLat;
  var kaabaLon = $kaabaLon;
  var qiblaDeg = $qibla;

  var map = L.map('map', { zoomControl: true }).setView([userLat, userLon], 18);
  var satLayer = L.tileLayer('https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}', {
    maxZoom: 19, attribution: 'Esri'
  });
  var osmLayer = L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19, attribution: 'OSM'
  });
  satLayer.addTo(map);

  function setLayer(mode) {
    if (mode === 'sat') {
      map.removeLayer(osmLayer); satLayer.addTo(map);
      document.getElementById('btnSat').className = 'btn active';
      document.getElementById('btnOsm').className = 'btn';
    } else {
      map.removeLayer(satLayer); osmLayer.addTo(map);
      document.getElementById('btnOsm').className = 'btn active';
      document.getElementById('btnSat').className = 'btn';
    }
  }
  function focusUser() { map.setView([userLat, userLon], 18); }

  // Kullanıcının noktasından tam Kıble açısıyla (qiblaDeg) yakın sokak/bina hattı + Kâbe hattı
  var rad = qiblaDeg * Math.PI / 180.0;
  var dLat = Math.cos(rad) * 0.015;
  var dLon = Math.sin(rad) * 0.015 / Math.cos(userLat * Math.PI / 180.0);
  var nearTarget = [userLat + dLat, userLon + dLon];

  // Dış altın hale + iç zümrüt Kıble çizgisi
  L.polyline([[userLat, userLon], nearTarget, [kaabaLat, kaabaLon]], {
    color: '#FFD54F', weight: 7, opacity: 0.9
  }).addTo(map);
  L.polyline([[userLat, userLon], nearTarget, [kaabaLat, kaabaLon]], {
    color: '#00897B', weight: 3.5, opacity: 1.0
  }).addTo(map);

  L.circleMarker([userLat, userLon], {
    radius: 9, fillColor: '#00E676', color: '#ffffff', weight: 3, fillOpacity: 1
  }).addTo(map).bindPopup('Konumunuz • Kıble: ' + qiblaDeg.toFixed(1) + '°');

  var headingLine = null;
  window.updateHeading = function(deg) {
    var r = deg * Math.PI / 180.0;
    var hLat = userLat + Math.cos(r) * 0.003;
    var hLon = userLon + Math.sin(r) * 0.003 / Math.cos(userLat * Math.PI / 180.0);
    if (headingLine) {
      headingLine.setLatLngs([[userLat, userLon], [hLat, hLon]]);
    } else {
      headingLine = L.polyline([[userLat, userLon], [hLat, hLon]], {
        color: '#29B6F6', weight: 3, dashArray: '6,6'
      }).addTo(map);
    }
  };
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return CustomPaint(
        painter: _QiblaGeodesicMapPainter(
          trueQiblaDegrees: widget.trueQiblaDegrees,
          headingDegrees: widget.headingDegrees,
          locationLabel: widget.locationLabel,
          distanceKm: widget.distanceKm,
        ),
        child: const SizedBox.expand(),
      );
    }
    return Stack(
      children: <Widget>[
        WebViewWidget(controller: _controller!),
        if (!_ready)
          Positioned.fill(
            child: CustomPaint(
              painter: _QiblaGeodesicMapPainter(
                trueQiblaDegrees: widget.trueQiblaDegrees,
                headingDegrees: widget.headingDegrees,
                locationLabel: widget.locationLabel,
                distanceKm: widget.distanceKm,
              ),
              child: const SizedBox.expand(),
            ),
          ),
      ],
    );
  }
}

/// **Güneşle Kıble doğrulama kartı** — pusuladan tamamen bağımsız kontrol.
///
/// Güneş, yılda iki kez (mayıs sonu / temmuz ortası) Kâbe doğrultusuna gelir.
/// O anda bir çubuğun gölgesi Kıble yönünü **kesin** gösterir; kullanıcı hem
/// uygulamanın açısını hem de kendi yönünü doğrulayabilir.
class _SunVerificationCard extends StatelessWidget {
  const _SunVerificationCard({
    required this.today,
    required this.upcoming,
    required this.now,
    required this.qibla,
  });

  final QiblaSunAlignment? today;
  final QiblaSunAlignment? upcoming;
  final SunCoordinates? now;
  final double qibla;

  static const List<String> _months = <String>[
    'Ocak',
    'Şubat',
    'Mart',
    'Nisan',
    'Mayıs',
    'Haziran',
    'Temmuz',
    'Ağustos',
    'Eylül',
    'Ekim',
    'Kasım',
    'Aralık',
  ];

  String _dateLabel(DateTime d) => '${d.day} ${_months[d.month - 1]}';

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final QiblaSunAlignment? reliable = (today?.isReliable ?? false)
        ? today
        : upcoming;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.gold500.withValues(alpha: 0.10),
        borderRadius: AppRadius.allLg,
        border: Border.all(color: AppColors.gold500.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.wb_sunny_outlined, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  'Güneşle Kıble Doğrulama',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (now != null)
                Text(
                  now!.isDaylight ? 'Gündüz' : 'Gece',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Pusuladan bağımsız ikinci kaynak: yılda iki kez güneş tam Kâbe '
            'doğrultusuna gelir. O anda gölgeniz Kıble yönünü gösterir.',
            style: theme.textTheme.bodySmall?.copyWith(height: 1.45),
          ),
          const SizedBox(height: AppSpacing.sm),
          if (reliable != null)
            Text(
              '${(today?.isReliable ?? false) ? 'Bugün' : _dateLabel(reliable.time)}'
              ' ${reliable.windowLabel} · güneş Kıble yönünde '
              '(fark ${reliable.differenceDegrees.toStringAsFixed(2)}°)',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            )
          else if (today != null)
            Text(
              'Bugün en yakın an ${today!.clockLabel} '
              '(fark ${today!.differenceDegrees.toStringAsFixed(1)}°) · '
              'tam doğrulama için sonraki uygun gün beklenmeli.',
              style: theme.textTheme.bodyMedium,
            )
          else
            Text(
              'Bu konumda güneş Kıble doğrultusuna yaklaşmıyor; '
              'pusula ölçümünü kullanın.',
              style: theme.textTheme.bodyMedium,
            ),
          if (now != null) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Şu an güneş: ${now!.azimuth.toStringAsFixed(1)}° yönünde, '
              'ufkun ${now!.altitude.toStringAsFixed(0)}° üzerinde · '
              'Kıble ${qibla.toStringAsFixed(1)}°',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (reliable != null && reliable.isReliable) ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'O an: güneşe sırtınızı dönün, gölgeniz '
              '${reliable.shadowBearing.toStringAsFixed(0)}° yönünü gösterir '
              '= Kıble.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            icon,
            size: 17,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
