import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_constants.dart';
import '../../core/services/compass_service.dart';
import '../../core/utils/logger.dart';
import '../../data/models/city.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';
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
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _start());
  }

  Future<void> _start() async {
    final CompassService service = ref.read(compassServiceProvider);
    final double qibla = ref.read(qiblaDirectionProvider);

    final bool supported = await service.checkSupport();
    if (!mounted) return;
    if (!supported) {
      setState(() => _supported = false);
      return;
    }

    _subscription = service.readings.listen(
      (CompassReading? reading) {
        if (!mounted) return;
        setState(() {
          _reading = reading?.withQibla(qibla);
          _error = reading == null ? 'Pusula verisi okunamadı. Telefonu 8 çizer gibi hareket ettirip tekrar deneyin.' : null;
        });
      },
      onError: (Object error) {
        AppLog.warning('Pusula akışı hata verdi: $error');
        if (mounted) setState(() => _error = 'Pusula okunamadı.');
      },
    );
    service.start(qiblaDirection: qibla);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double qibla = ref.watch(qiblaDirectionProvider);
    final double distance = ref.watch(qiblaDistanceProvider);
    final UserLocation location = ref.watch(activeLocationProvider);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kıble'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Haritada aç',
            onPressed: () => _openMap(location),
            icon: const Icon(Icons.map_outlined, size: 20),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
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
          if (_error != null)
            StatusBanner(icon: Icons.warning_amber_rounded, message: _error!),
          if (_reading?.needsCalibration ?? false)
            const StatusBanner(
              icon: Icons.screen_rotation_alt_rounded,
              message: 'Pusula kalibrasyonu gerekiyor: telefonu havada 8 çizer gibi '
                  'hareket ettirin ve metal eşyalardan uzaklaşın.',
            ),
          if (!_supported)
            const StatusBanner(
              icon: Icons.sensors_off_rounded,
              message: 'Cihazınızda pusula sensörü bulunamadı. Aşağıdaki dereceyi '
                  'kullanarak yönünüzü ayarlayabilirsiniz.',
            ),
          Center(
            child: _CompassDial(reading: _reading, qibla: qibla),
          ),
          const SizedBox(height: AppSpacing.lg),
          _InfoRow(
            icon: Icons.explore_rounded,
            label: 'Kâbe yönü',
            value: '${qibla.toStringAsFixed(1)}° (kuzeyden saat yönünde)',
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
          if (_reading != null)
            _InfoRow(
              icon: Icons.screen_lock_rotation_rounded,
              label: 'Cihaz yönü',
              value: '${_reading!.heading.toStringAsFixed(0)}° · '
                  'sapma ${_reading!.differenceToQibla!.toStringAsFixed(0)}°',
            ),
          const SectionHeader(title: 'Kıble nasıl bulunur?'),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
            child: Text(
              '1. Telefonu düz tutun ve yavaşça döndürün.\n'
              '2. Altın iğne Kâbe yönünü gösterir; halka yeşile döndüğünde yön doğrudur.\n'
              '3. Manyetik alanı bozan eşyalardan (mıknatıs, hoparlör, metal masa) uzak durun.\n'
              '4. Pusula güvenilir değilse, güneşin konumundan veya bir camiden yararlanabilirsiniz.',
              style: TextStyle(height: 1.6),
            ),
          ),
        ],
      ),
    );
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
      final bool opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
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

/// Pusula kadranı — iğne Kâbe yönünü gösterir.
class _CompassDial extends StatelessWidget {
  const _CompassDial({required this.reading, required this.qibla});

  final CompassReading? reading;
  final double qibla;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double heading = reading?.heading ?? 0;
    final bool aligned = reading?.isAligned ?? false;
    final bool close = reading?.isClose ?? false;
    final Color accent = aligned
        ? AppColors.success
        : close
            ? AppColors.warning
            : theme.colorScheme.primary;

    return SizedBox(
      width: 300,
      height: 300,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: accent.withValues(alpha: 0.08),
              border: Border.all(color: accent.withValues(alpha: 0.5), width: 2),
            ),
          ),
          // Kadran, cihazın dönüşünü telafi etmek için ters yönde döner.
          Transform.rotate(
            angle: -heading * math.pi / 180,
            child: CustomPaint(
              size: const Size(300, 300),
              painter: _CompassPainter(
                color: theme.colorScheme.onSurfaceVariant,
                textColor: theme.colorScheme.onSurface,
              ),
            ),
          ),
          // Kâbe işareti her zaman gerçek kıble yönünde durur.
          Transform.rotate(
            angle: (qibla - heading) * math.pi / 180,
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.gold500,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const Icon(Icons.mosque_rounded, size: 13, color: Colors.white),
                      const SizedBox(width: 4),
                      Text(
                        'Kâbe',
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
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                '${qibla.toStringAsFixed(0)}°',
                style: theme.textTheme.displaySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accent,
                ),
              ),
              Text(
                aligned
                    ? 'YÖN DOĞRU'
                    : close
                        ? 'ÇOK YAKIN'
                        : 'Döndürün',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.6,
                  color: accent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompassPainter extends CustomPainter {
  const _CompassPainter({required this.color, required this.textColor});

  final Color color;
  final Color textColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = size.width / 2 - 18;

    final Paint ring = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
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
          ..color = color.withValues(alpha: major ? 0.85 : 0.4),
      );
    }

    const List<String> labels = <String>['K', 'D', 'G', 'B'];
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
      painter.paint(
        canvas,
        center + Offset(math.cos(angle) * (radius - 30), math.sin(angle) * (radius - 30)) - Offset(painter.width / 2, painter.height / 2),
      );
    }

    // Kuzey iğnesi
    final Path needle = Path()
      ..moveTo(center.dx, center.dy - radius + 18)
      ..lineTo(center.dx - 8, center.dy)
      ..lineTo(center.dx + 8, center.dy)
      ..close();
    canvas.drawPath(needle, Paint()..color = AppColors.danger);
    canvas.drawCircle(center, 5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _CompassPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.textColor != textColor;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.sm),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 17, color: Theme.of(context).colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.md),
          Expanded(child: Text(label, style: Theme.of(context).textTheme.bodyMedium)),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
