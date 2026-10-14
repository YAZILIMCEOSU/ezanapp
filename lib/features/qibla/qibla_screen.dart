import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
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
  CompassReading? _reading;
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
    final UserLocation location = ref.read(activeLocationProvider);
    if (location.mode == LocationMode.gps) {
      unawaited(
        ref
            .read(locationControllerProvider.notifier)
            .refreshFromGps(requestPermission: false),
      );
    }
    final double compassQibla = GeoUtils.compassQiblaBearing(
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
        final double currentCompassQibla = GeoUtils.compassQiblaBearing(
          currentLocation.latitude,
          currentLocation.longitude,
        );
        setState(() {
          _reading = reading?.withQibla(currentCompassQibla, declination: 0);
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
    service.start(qiblaDirection: compassQibla, declination: 0);
  }

  @override
  void dispose() {
    _subscription?.cancel();
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
      compassQibla,
      declination: 0,
    );
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble Pusulası'),
        actions: <Widget>[
          IconButton(
            tooltip: 'GPS ile tam konumumu güncelle',
            onPressed: () =>
                ref.read(locationControllerProvider.notifier).refreshFromGps(),
            icon: const Icon(Icons.my_location_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Haritada tam konumumu işaretle',
            onPressed: () => _openExactPin(location, compassQibla),
            icon: const Icon(Icons.location_on_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'Kâbe rotası ile haritada aç',
            onPressed: () => _openMap(location),
            icon: const Icon(Icons.map_outlined, size: 20),
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
                onOpenPin: () => _openExactPin(location, compassQibla),
                onOpenRoute: () => _openMap(location),
              ),
            )
          else ...<Widget>[
            const SizedBox(height: AppSpacing.xs),
            Center(
              child: _CompassDial(
                reading: activeReading,
                qibla: compassQibla,
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
          const SectionHeader(title: 'Kıble nasıl bulunur? (Diyanet Yöntemi)'),
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
    // Kâbe yönünü haritada göstermek için kullanıcının konumu ve Kâbe'yi
    // içeren bir yol tarifi bağlantısı açılır.
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&origin=${location.latitude},${location.longitude}'
      '&destination=${AppConstants.kaabaLat},${AppConstants.kaabaLng}'
      '&travelmode=driving',
    );
    try {
      final bool opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harita uygulaması açılamadı.')),
        );
      }
    } catch (error) {
      AppLog.warning('Harita açılamadı: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Harita uygulaması açılamadı.')),
        );
      }
    }
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

/// Pusula kadranı — ortadaki ana ibre doğrudan Kâbe/Kıble yönünü gösterir.
class _CompassDial extends StatelessWidget {
  const _CompassDial({required this.reading, required this.qibla});

  final CompassReading? reading;
  final double qibla;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double heading = reading?.heading ?? 0;
    final double qiblaRelative = GeoUtils.normalizeSigned(qibla - heading);
    final bool aligned = reading?.isAligned ?? false;
    final bool close = reading?.isClose ?? false;
    final Color accent = aligned
        ? AppColors.success
        : close
        ? AppColors.warning
        : AppColors.gold500;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        // Diyanet tarzı üst Kıble derece kartı (ör. Kıble 157.7°)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.emerald500.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.emerald500.withValues(alpha: 0.55),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.mosque_rounded,
                size: 22,
                color: AppColors.emerald500,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Kıble',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${qibla.toStringAsFixed(1)}°',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: AppColors.emerald500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Sabit üst telefon nişangâhı (Kâbe ibresi buraya hizalanır)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: aligned
                ? AppColors.success
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: accent, width: 1.5),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.navigation_rounded,
                size: 14,
                color: aligned ? Colors.white : accent,
              ),
              const SizedBox(width: 4),
              Text(
                aligned
                    ? '✓ KIBLE HİZALANDI'
                    : 'TELEFON YÖNÜ (${heading.toStringAsFixed(1)}°)',
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: aligned ? Colors.white : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),
        SizedBox(
          width: 300,
          height: 300,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.withValues(alpha: aligned ? 0.14 : 0.07),
                  border: Border.all(
                    color: accent.withValues(alpha: aligned ? 0.85 : 0.5),
                    width: aligned ? 3.0 : 2.0,
                  ),
                ),
              ),
              // Dış derece ve yön (K/D/G/B) halkası — harfler her zaman düz durur.
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
              // ANA KIBLE İBRESİ: Merkezden doğrudan Kâbe yönüne uzanan büyük ibre.
              Transform.rotate(
                angle: qiblaRelative * math.pi / 180,
                child: CustomPaint(
                  size: const Size(300, 300),
                  painter: _QiblaNeedlePainter(
                    needleColor: aligned
                        ? AppColors.success
                        : AppColors.gold500,
                    aligned: aligned,
                  ),
                ),
              ),
              // Kâbe rozeti — Kıble ibresinin ucunda gerçek Kıble yönünde durur.
              Transform.rotate(
                angle: qiblaRelative * math.pi / 180,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: aligned ? AppColors.success : AppColors.gold500,
                        borderRadius: BorderRadius.circular(999),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.25),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.mosque_rounded,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Kâbe ${qibla.toStringAsFixed(1)}°',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Merkez bilgi dairesi
              Container(
                width: 98,
                height: 98,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface.withValues(alpha: 0.92),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.65),
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '${qibla.toStringAsFixed(1)}°',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent,
                      ),
                    ),
                    Text(
                      aligned
                          ? '✓ KIBLE'
                          : close
                          ? 'ÇOK YAKIN'
                          : 'KIBLE AÇISI',
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        letterSpacing: 0.8,
                        color: accent,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Kıble Harita Sekmesi — Konumdan Kâbe'ye direkt açı ve uydu haritası kartı.
class _QiblaMapViewCard extends StatelessWidget {
  const _QiblaMapViewCard({
    required this.location,
    required this.compassQibla,
    required this.trueQibla,
    required this.distanceKm,
    required this.onOpenPin,
    required this.onOpenRoute,
  });

  final UserLocation location;
  final double compassQibla;
  final double trueQibla;
  final double distanceKm;
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

/// Merkezden doğrudan Kâbe'ye uzanan büyük altın/zümrüt Kıble İbresi.
class _QiblaNeedlePainter extends CustomPainter {
  const _QiblaNeedlePainter({required this.needleColor, required this.aligned});

  final Color needleColor;
  final bool aligned;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 18;

    // İleri (Kâbe) ucu
    final Path forwardNeedle = Path()
      ..moveTo(center.dx, center.dy - radius + 24)
      ..lineTo(center.dx - 11, center.dy - 18)
      ..lineTo(center.dx + 11, center.dy - 18)
      ..close();
    canvas.drawPath(
      forwardNeedle,
      Paint()
        ..style = PaintingStyle.fill
        ..color = needleColor,
    );

    // Arka denge kuyruğu
    final Path tailNeedle = Path()
      ..moveTo(center.dx, center.dy + radius - 48)
      ..lineTo(center.dx - 7, center.dy + 18)
      ..lineTo(center.dx + 7, center.dy + 18)
      ..close();
    canvas.drawPath(
      tailNeedle,
      Paint()
        ..style = PaintingStyle.fill
        ..color = needleColor.withValues(alpha: 0.32),
    );
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
    final double radius = size.width / 2 - 18;

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = color.withValues(alpha: 0.5);
    canvas.drawCircle(center, radius, ring);

    for (int degree = 0; degree < 360; degree += 5) {
      final bool major = degree % 30 == 0;
      final double angle = (degree - 90) * math.pi / 180;
      final double outer = radius;
      final double inner = radius - (major ? 14 : 7);
      canvas.drawLine(
        center + Offset(math.cos(angle) * inner, math.sin(angle) * inner),
        center + Offset(math.cos(angle) * outer, math.sin(angle) * outer),
        Paint()
          ..strokeWidth = major ? 1.8 : 0.9
          ..color = degree == 0
              ? AppColors.danger
              : color.withValues(alpha: major ? 0.85 : 0.4),
      );
    }

    const List<String> labels = <String>['N', 'E', 'S', 'W'];
    for (int i = 0; i < 4; i++) {
      final double angle = (i * 90 - 90) * math.pi / 180;
      final TextPainter painter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: i == 0 ? AppColors.danger : textColor,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      final Offset labelCenter =
          center +
          Offset(
            math.cos(angle) * (radius - 30),
            math.sin(angle) * (radius - 30),
          );
      // Harfleri cihaz açısı kadar ters döndürerek her zaman dik ve okunaklı tut.
      canvas.save();
      canvas.translate(labelCenter.dx, labelCenter.dy);
      canvas.rotate(headingDegrees * math.pi / 180);
      painter.paint(canvas, Offset(-painter.width / 2, -painter.height / 2));
      canvas.restore();
    }

    // Dış halkada Kuzey (0°) küçük kırmızı üçgen işareti
    final Path northTick = Path()
      ..moveTo(center.dx, center.dy - radius + 3)
      ..lineTo(center.dx - 5, center.dy - radius + 14)
      ..lineTo(center.dx + 5, center.dy - radius + 14)
      ..close();
    canvas.drawPath(northTick, Paint()..color = AppColors.danger);
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
