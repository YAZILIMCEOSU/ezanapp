import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/services/compass_service.dart';
import '../../core/utils/geo.dart';
import '../../core/utils/logger.dart';
import '../../data/models/city.dart';
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
  bool _wasAligned = false;
  bool _supported = true;
  bool _showMapTab = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final CompassService service = ref.read(compassServiceProvider);
    _compassService = service;
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
    final double declination = GeoUtils.magneticDeclination(
      location.latitude,
      location.longitude,
    );

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
        final double currentDeclination = GeoUtils.magneticDeclination(
          currentLocation.latitude,
          currentLocation.longitude,
        );
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

  @override
  void dispose() {
    _subscription?.cancel();
    unawaited(_compassService?.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double trueQibla = ref.watch(qiblaDirectionProvider);
    final double distance = ref.watch(qiblaDistanceProvider);
    final UserLocation location = ref.watch(activeLocationProvider);
    final double declination = GeoUtils.magneticDeclination(
      location.latitude,
      location.longitude,
    );
    final double compassQibla = GeoUtils.compassQiblaBearing(
      location.latitude,
      location.longitude,
    );
    final CompassReading? activeReading = _reading?.withQibla(
      trueQibla,
      declination: declination,
    );
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble Pusulası'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Pusulayı kalibre et ve sıfırla',
            onPressed: () async {
              await ref.read(compassServiceProvider).resetCompass();
              unawaited(
                ref
                    .read(locationControllerProvider.notifier)
                    .refreshFromGps(requestPermission: true),
              );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Pusula sensörü sıfırlandı ve GPS konumu güncelleniyor.',
                    ),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
            icon: const Icon(Icons.compass_calibration_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'GPS ile tam konumumu güncelle',
            onPressed: () =>
                ref.read(locationControllerProvider.notifier).refreshFromGps(),
            icon: const Icon(Icons.my_location_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Yakındaki Camiler ve Navigasyon',
            onPressed: () => context.push(AppRoutes.mosques),
            icon: const Icon(Icons.mosque_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Haritada tam konumumu işaretle',
            onPressed: () => _openExactPin(location, compassQibla),
            icon: const Icon(Icons.location_on_outlined, size: 20),
          ),
        ],
      ),
      body: ListView(
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
            StatusBanner(icon: Icons.warning_amber_rounded, message: _error!),
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
                compassQibla: compassQibla,
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
              child: _CompassDial(
                reading: activeReading,
                qibla: trueQibla,
                displayQibla: compassQibla,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: _QiblaDirectionBanner(
                reading: activeReading,
                qibla: compassQibla,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          _InfoRow(
            icon: Icons.mosque_rounded,
            label: 'Diyanet Kıble Pusulası Açısı',
            value: '${compassQibla.toStringAsFixed(1)}°',
          ),
          _InfoRow(
            icon: Icons.explore_outlined,
            label: 'Coğrafi Kıble Açısı (Gerçek Kuzey)',
            value: '${trueQibla.toStringAsFixed(1)}°',
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
          const SectionHeader(title: 'Kıble nasıl bulunur? (Diyanet Yöntemi)'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
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
}

/// Canlı sağ/sol yönlendirme bandı — Diyanet Kıble Pusulası tarzı.
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

    final Color bannerColor = aligned
        ? AppColors.success
        : close
        ? AppColors.warning
        : AppColors.gold500;

    final String instruction;
    final IconData icon;
    if (diff == null) {
      instruction =
          'Kıble Açısı: ${qibla.toStringAsFixed(0)}° — Pusula bekleniyor';
      icon = Icons.explore_outlined;
    } else if (aligned) {
      instruction = '✓ KIBLE YÖNÜ DOĞRU — Kâbe Tam Karşınızda';
      icon = Icons.check_circle_rounded;
    } else if (diff > 0) {
      instruction = 'Telefonu ${diff.abs().round()}° SAĞA çevirin ▶';
      icon = Icons.turn_right_rounded;
    } else {
      instruction = '◀ Telefonu ${diff.abs().round()}° SOLA çevirin';
      icon = Icons.turn_left_rounded;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: bannerColor.withValues(alpha: 0.55),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(icon, color: bannerColor, size: 22),
          const SizedBox(width: AppSpacing.sm),
          Flexible(
            child: Text(
              instruction,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: aligned
                    ? AppColors.success
                    : theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pusula kadranı — Diyanet Kıble Pusulası birebir beyaz kadran & Kâbe oku tasarımı.
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
    final double qiblaRelative =
        reading?.differenceToQibla ?? GeoUtils.normalizeSigned(qibla - heading);
    final bool aligned = reading?.isAligned ?? false;
    final bool close = reading?.isClose ?? false;
    final Color accent = aligned
        ? AppColors.success
        : close
        ? const Color(0xFF00897B)
        : const Color(0xFF26A69A);
    final double tilt = reading?.tilt ?? 0;
    final double roll = reading?.roll ?? 0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Diyanet tarzı üst Kıble derece kartları (Pusula Kıble & Coğrafi Kıble)
        Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF26A69A).withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFF26A69A).withValues(alpha: 0.55),
              width: 1.4,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Container(
                width: 30,
                height: 30,
                decoration: const BoxDecoration(
                  color: Color(0xFFE0F2F1),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.mosque_rounded,
                  size: 18,
                  color: Color(0xFF00796B),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Pusula Kıble',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${displayQibla.toStringAsFixed(1)}°',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF00796B),
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 14),
                color: const Color(0xFF26A69A).withValues(alpha: 0.35),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Coğrafi Kıble',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${qibla.toStringAsFixed(1)}°',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Sabit üst nişangâh (12 yönü — Kâbe rozeti buraya hizalanır)
        Container(
          margin: const EdgeInsets.only(bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
          decoration: BoxDecoration(
            color: aligned ? AppColors.success : accent.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                aligned
                    ? Icons.check_circle_rounded
                    : Icons.arrow_downward_rounded,
                size: 14,
                color: aligned ? Colors.white : accent,
              ),
              const SizedBox(width: 4),
              Text(
                aligned
                    ? 'KIBLE HİZALANDI (0°)'
                    : 'KÂBE SİMGESİNİ BURAYA GETİRİN (${qiblaRelative.abs().toStringAsFixed(0)}°)',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 10.5,
                  color: aligned ? Colors.white : const Color(0xFF00796B),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              // Beyaz/Açık Diyanet dairesel kadran zemini
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? theme.colorScheme.surface : Colors.white,
                  border: Border.all(
                    color: aligned
                        ? AppColors.success
                        : theme.colorScheme.outlineVariant,
                    width: aligned ? 3.2 : 1.6,
                  ),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (aligned ? AppColors.success : Colors.black)
                          .withValues(alpha: aligned ? 0.22 : 0.06),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
              ),
              // Dış derece, artı (+) eksen çizgisi ve yön (N/E/S/W) halkası
              Transform.rotate(
                angle: -heading * math.pi / 180,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: _CompassPainter(
                    color: theme.colorScheme.onSurfaceVariant,
                    textColor: theme.colorScheme.onSurface,
                    qiblaDegrees: qibla,
                    headingDegrees: heading,
                  ),
                ),
              ),
              // Sabit Telefon Hiza Çizgisi (12 yönü) + Dönüş Yönü Yayı + Su Terazisi
              CustomPaint(
                size: const Size(300, 300),
                painter: _FixedSightlineAndLevelPainter(
                  qiblaRelativeDegrees: qiblaRelative,
                  tiltDegrees: tilt,
                  rollDegrees: roll,
                  aligned: aligned,
                  accentColor: accent,
                ),
              ),
              // Kâbe yuvarlak rozeti — çember üzerinde tam Kıble açısında (qibla - heading) durur
              Transform.rotate(
                angle: qiblaRelative * math.pi / 180,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[Color(0xFF81D4FA), Color(0xFFE1F5FE)],
                        ),
                        border: Border.all(color: accent, width: 2.2),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      alignment: Alignment.center,
                      child: Container(
                        width: 22,
                        height: 20,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1C1C1C),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Column(
                          children: <Widget>[
                            const SizedBox(height: 4),
                            Container(
                              height: 3.5,
                              width: double.infinity,
                              color: const Color(0xFFFFD54F),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Merkezden Kâbe rozetine uzanan ince Diyanet Kıble Oku
              Transform.rotate(
                angle: qiblaRelative * math.pi / 180,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: _QiblaNeedlePainter(
                    needleColor: accent,
                    aligned: aligned,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Sabit telefon üst nişangâh çizgisi (12 yönü), dönüş yayı ve merkez su terazisi.
class _FixedSightlineAndLevelPainter extends CustomPainter {
  const _FixedSightlineAndLevelPainter({
    required this.qiblaRelativeDegrees,
    required this.tiltDegrees,
    required this.rollDegrees,
    required this.aligned,
    required this.accentColor,
  });

  final double qiblaRelativeDegrees;
  final double tiltDegrees;
  final double rollDegrees;
  final bool aligned;
  final Color accentColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);

    // 1. 12 yönünde sabit hedef halkası (Kâbe rozetinin içine oturacağı yuva)
    final Offset targetCenter = Offset(center.dx, 32);
    canvas.drawCircle(
      targetCenter,
      24,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = aligned ? 2.6 : 1.5
        ..color = aligned
            ? AppColors.success
            : accentColor.withValues(alpha: 0.45),
    );

    // 2. Merkezden 12 yönüne (telefonun üst ucuna) sabit referans nişangâh çizgisi
    final Paint sightPaint = Paint()
      ..strokeWidth = 1.6
      ..color = aligned
          ? AppColors.success.withValues(alpha: 0.7)
          : accentColor.withValues(alpha: 0.32);
    for (double y = center.dy - 26; y > 60; y -= 10) {
      canvas.drawLine(
        Offset(center.dx, y),
        Offset(center.dx, math.max(60, y - 5)),
        sightPaint,
      );
    }

    // 3. Eğer Kıble hizalı değilse, Kıble ibresinden 12 yönüne dönüş yayını çiz
    if (!aligned && qiblaRelativeDegrees.abs() > 5) {
      final Rect arcRect = Rect.fromCircle(center: center, radius: 92);
      const double startAngle = -math.pi / 2;
      final double sweepAngle = qiblaRelativeDegrees * math.pi / 180;
      canvas.drawArc(
        arcRect,
        startAngle,
        sweepAngle,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..strokeCap = StrokeCap.round
          ..color = AppColors.gold500.withValues(alpha: 0.55),
      );
    }

    // 4. Merkez Su Terazisi (Bubble Level) halkası
    canvas.drawCircle(
      center,
      20,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = accentColor.withValues(alpha: 0.35),
    );
    final double bx = (rollDegrees / 45.0).clamp(-1.0, 1.0) * 14.0;
    final double by = (tiltDegrees / 45.0).clamp(-1.0, 1.0) * 14.0;
    canvas.drawCircle(
      center + Offset(bx, by),
      5.0,
      Paint()
        ..style = PaintingStyle.fill
        ..color = (tiltDegrees.abs() < 15 && rollDegrees.abs() < 15)
            ? AppColors.success.withValues(alpha: 0.45)
            : AppColors.warning.withValues(alpha: 0.55),
    );
  }

  @override
  bool shouldRepaint(covariant _FixedSightlineAndLevelPainter oldDelegate) =>
      oldDelegate.qiblaRelativeDegrees != qiblaRelativeDegrees ||
      oldDelegate.tiltDegrees != tiltDegrees ||
      oldDelegate.rollDegrees != rollDegrees ||
      oldDelegate.aligned != aligned;
}

/// Kıble Harita Sekmesi — Konumdan Kâbe'ye direkt açı ve görsel coğrafi Kâbe hattı.
class _QiblaMapViewCard extends StatelessWidget {
  const _QiblaMapViewCard({
    required this.location,
    required this.compassQibla,
    required this.trueQibla,
    required this.distanceKm,
    required this.heading,
    required this.onOpenPin,
    required this.onOpenRoute,
  });

  final UserLocation location;
  final double compassQibla;
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
          // e-Diyanet tarzı uygulama içi görsel Kâbe Hattı & Coğrafi Radar Haritası
          Container(
            height: 230,
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF26A69A).withValues(alpha: 0.45),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: CustomPaint(
              painter: _QiblaGeodesicMapPainter(
                trueQiblaDegrees: trueQibla,
                headingDegrees: heading,
                locationLabel: location.label,
                distanceKm: distanceKm,
              ),
              child: const SizedBox.expand(),
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
                    const Text('Diyanet Pusula Kıble Açısı'),
                    Text(
                      '${compassQibla.toStringAsFixed(1)}°',
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
                    const Text('Harita / Gerçek Kuzey Açısı'),
                    Text(
                      '${trueQibla.toStringAsFixed(1)}°',
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

/// Merkezden doğrudan Kâbe rozetine uzanan zarif Diyanet Kıble Oku.
class _QiblaNeedlePainter extends CustomPainter {
  const _QiblaNeedlePainter({required this.needleColor, required this.aligned});

  final Color needleColor;
  final bool aligned;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    const double tipY = 64.0;

    // İnce ok gövdesi (merkezden Kâbe rozetine)
    canvas.drawLine(
      center,
      Offset(center.dx, tipY + 10),
      Paint()
        ..strokeWidth = 2.6
        ..strokeCap = StrokeCap.round
        ..color = needleColor,
    );

    // Ok ucu (üçgen)
    final Path arrowHead = Path()
      ..moveTo(center.dx, tipY)
      ..lineTo(center.dx - 7, tipY + 14)
      ..lineTo(center.dx + 7, tipY + 14)
      ..close();
    canvas.drawPath(
      arrowHead,
      Paint()
        ..style = PaintingStyle.fill
        ..color = needleColor,
    );

    // Merkez nokta (Diyanet yeşil/turkuvaz pivot noktası)
    canvas.drawCircle(center, 6.0, Paint()..color = needleColor);
  }

  @override
  bool shouldRepaint(covariant _QiblaNeedlePainter oldDelegate) =>
      oldDelegate.needleColor != needleColor || oldDelegate.aligned != aligned;
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
    final double radius = size.width / 2 - 14;

    // İnce dış çember
    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = color.withValues(alpha: 0.28);
    canvas.drawCircle(center, radius, ring);

    // Diyanet tarzı merkez artı (+) eksen çizgileri (N-S ve E-W)
    final Paint crossPaint = Paint()
      ..strokeWidth = 0.9
      ..color = color.withValues(alpha: 0.22);
    canvas.drawLine(
      Offset(center.dx, center.dy - radius + 48),
      Offset(center.dx, center.dy + radius - 48),
      crossPaint,
    );
    canvas.drawLine(
      Offset(center.dx - radius + 48, center.dy),
      Offset(center.dx + radius - 48, center.dy),
      crossPaint,
    );

    // 15° ve 30° kadran çizgileri
    for (int degree = 0; degree < 360; degree += 15) {
      final bool major = degree % 30 == 0;
      final bool cardinal = degree % 90 == 0;
      final double angle = (degree - 90) * math.pi / 180;
      final double outer = radius - 4;
      final double inner = outer - (cardinal ? 18 : (major ? 14 : 8));
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        Paint()
          ..strokeWidth = cardinal ? 2.0 : (major ? 1.4 : 1.0)
          ..color = cardinal
              ? const Color(0xFF00897B)
              : color.withValues(alpha: major ? 0.65 : 0.35),
      );
    }

    const List<String> labels = <String>['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final double angle = (i * 90 - 90) * math.pi / 180;
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: i == 0 ? const Color(0xFF00897B) : textColor,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final Offset labelCenter =
          center +
          Offset(
            math.cos(angle) * (radius - 36),
            math.sin(angle) * (radius - 36),
          );
      // Harfleri cihaz açısı kadar ters döndürerek her zaman dik ve okunaklı tut.
      canvas.save();
      canvas.translate(labelCenter.dx, labelCenter.dy);
      canvas.rotate(headingDegrees * math.pi / 180);
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
