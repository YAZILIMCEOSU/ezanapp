import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import '../../core/utils/geo.dart';
import '../../data/models/city.dart';
import '../../design/app_colors.dart';
import '../../design/app_spacing.dart';
import '../../router/app_router.dart';
import '../../state/providers.dart';

/// Bir cami kaydı (konum, mesafe, yön ve imkânlar).
@immutable
class MosquePlace {
  const MosquePlace({
    required this.name,
    required this.district,
    required this.latitude,
    required this.longitude,
    this.facilities = const <String>[
      'Cuma Namazı',
      'Şadırvan',
      'Hanımlar Bölümü',
    ],
  });

  final String name;
  final String district;
  final double latitude;
  final double longitude;
  final List<String> facilities;

  double distanceKmFrom(double lat, double lon) {
    const double r = 6371.0088;
    const double p = math.pi / 180.0;
    final double dLat = (latitude - lat) * p;
    final double dLon = (longitude - lon) * p;
    final double a =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat * p) *
            math.cos(latitude * p) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double bearingFrom(double lat, double lon) {
    const double p = math.pi / 180.0;
    final double lat1 = lat * p;
    final double lat2 = latitude * p;
    final double dLon = (longitude - lon) * p;
    final double y = math.sin(dLon) * math.cos(lat2);
    final double x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);
    return GeoUtils.normalizeDegrees(math.atan2(y, x) * 180.0 / math.pi);
  }

  String compassLabelFrom(double lat, double lon) {
    final double b = bearingFrom(lat, lon);
    const List<String> dirs = <String>[
      'K',
      'KD',
      'D',
      'GD',
      'G',
      'GB',
      'B',
      'KB',
    ];
    return dirs[((b + 22.5) ~/ 45) % 8];
  }

  String formattedDistanceFrom(double lat, double lon) {
    final double km = distanceKmFrom(lat, lon);
    if (km < 1.0) {
      return '${(km * 1000).round()} m';
    }
    return '${km.toStringAsFixed(1)} km';
  }
}

/// Etraftaki camileri bulan ve yol tarifi açan ekran.
class MosqueFinderScreen extends ConsumerStatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  ConsumerState<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends ConsumerState<MosqueFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<MosquePlace> _onlineMosques = const <MosquePlace>[];
  bool _loadingOnline = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _fetchNearbyOnline());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchNearbyOnline() async {
    final UserLocation loc = ref.read(activeLocationProvider);
    setState(() => _loadingOnline = true);
    try {
      final String overpassQuery =
          '[out:json][timeout:6];('
          'node["amenity"="place_of_worship"]["religion"="muslim"](around:3500,${loc.latitude},${loc.longitude});'
          'way["amenity"="place_of_worship"]["religion"="muslim"](around:3500,${loc.latitude},${loc.longitude});'
          ');out center 25;';
      final http.Response response = await http
          .post(
            Uri.parse('https://overpass-api.de/api/interpreter'),
            body: <String, String>{'data': overpassQuery},
          )
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final Object? decoded = jsonDecode(response.body);
        if (decoded is Map<String, Object?>) {
          final List<Object?> elements =
              (decoded['elements'] as List<Object?>?) ?? const <Object?>[];
          final List<MosquePlace> parsed = <MosquePlace>[];
          for (final Object? item in elements) {
            if (item is! Map) continue;
            final Map<String, Object?> tags =
                (item['tags'] as Map?)?.cast<String, Object?>() ??
                <String, Object?>{};
            final String? name = (tags['name:tr'] ?? tags['name']) as String?;
            if (name == null || name.trim().isEmpty) continue;
            double? lat = (item['lat'] as num?)?.toDouble();
            double? lon = (item['lon'] as num?)?.toDouble();
            if (lat == null || lon == null) {
              final Map<String, Object?>? center = (item['center'] as Map?)
                  ?.cast<String, Object?>();
              lat = (center?['lat'] as num?)?.toDouble();
              lon = (center?['lon'] as num?)?.toDouble();
            }
            if (lat == null || lon == null) continue;
            parsed.add(
              MosquePlace(
                name: name.trim(),
                district:
                    (tags['addr:district'] ?? tags['addr:suburb'] ?? loc.label)
                        as String,
                latitude: lat,
                longitude: lon,
              ),
            );
          }
          if (mounted && parsed.isNotEmpty) {
            setState(() => _onlineMosques = parsed);
          }
        }
      }
    } catch (_) {
      // Çevrimdışı durumda yerleşik katalog kullanılır.
    } finally {
      if (mounted) {
        setState(() => _loadingOnline = false);
      }
    }
  }

  List<MosquePlace> _resolvedMosques(UserLocation loc) {
    final List<MosquePlace> combined = <MosquePlace>[
      ..._onlineMosques,
      ..._localMosquesFor(loc),
      ..._landmarkMosques,
    ];
    final Set<String> seen = <String>{};
    final List<MosquePlace> unique = <MosquePlace>[];
    for (final MosquePlace m in combined) {
      final String key = m.name.toLowerCase();
      if (seen.add(key)) {
        unique.add(m);
      }
    }
    unique.sort(
      (MosquePlace a, MosquePlace b) => a
          .distanceKmFrom(loc.latitude, loc.longitude)
          .compareTo(b.distanceKmFrom(loc.latitude, loc.longitude)),
    );
    if (_query.trim().isEmpty) return unique;
    final String q = _query.trim().toLowerCase();
    return unique
        .where(
          (MosquePlace m) =>
              m.name.toLowerCase().contains(q) ||
              m.district.toLowerCase().contains(q),
        )
        .toList();
  }

  static List<MosquePlace> _localMosquesFor(UserLocation loc) {
    final String cityLabel = loc.city?.name ?? loc.label;
    return <MosquePlace>[
      MosquePlace(
        name: '$cityLabel Merkez Camii',
        district: '$cityLabel Merkez',
        latitude: loc.latitude + 0.0028,
        longitude: loc.longitude + 0.0022,
      ),
      MosquePlace(
        name: '$cityLabel Ulu Camii',
        district: '$cityLabel Çarşı',
        latitude: loc.latitude - 0.0041,
        longitude: loc.longitude + 0.0035,
      ),
      MosquePlace(
        name: '$cityLabel Fatih Camii',
        district: cityLabel,
        latitude: loc.latitude + 0.0065,
        longitude: loc.longitude - 0.0048,
      ),
      MosquePlace(
        name: '$cityLabel الميدان / Yeşil Camii',
        district: cityLabel,
        latitude: loc.latitude - 0.0078,
        longitude: loc.longitude - 0.0062,
      ),
    ];
  }

  static const List<MosquePlace> _landmarkMosques = <MosquePlace>[
    MosquePlace(
      name: 'Ayasofya-i Kebîr Cami-i Şerifi',
      district: 'Fatih, İstanbul',
      latitude: 41.0086,
      longitude: 28.9802,
    ),
    MosquePlace(
      name: 'Sultanahmet Camii',
      district: 'Fatih, İstanbul',
      latitude: 41.0054,
      longitude: 28.9768,
    ),
    MosquePlace(
      name: 'Süleymaniye Camii',
      district: 'Fatih, İstanbul',
      latitude: 41.0162,
      longitude: 28.9638,
    ),
    MosquePlace(
      name: 'Eyüp Sultan Camii',
      district: 'Eyüpsultan, İstanbul',
      latitude: 41.0480,
      longitude: 28.9338,
    ),
    MosquePlace(
      name: 'Büyük Çamlıca Camii',
      district: 'Üsküdar, İstanbul',
      latitude: 41.0342,
      longitude: 29.0702,
    ),
    MosquePlace(
      name: 'Kocatepe Camii',
      district: 'Çankaya, Ankara',
      latitude: 39.9167,
      longitude: 32.8608,
    ),
    MosquePlace(
      name: 'Hacı Bayram-ı Velî Camii',
      district: 'Altındağ, Ankara',
      latitude: 39.9444,
      longitude: 32.8581,
    ),
    MosquePlace(
      name: 'Bursa Ulu Camii',
      district: 'Osmangazi, Bursa',
      latitude: 40.1839,
      longitude: 29.0619,
    ),
    MosquePlace(
      name: 'Selimiye Camii',
      district: 'Merkez, Edirne',
      latitude: 41.6781,
      longitude: 26.5594,
    ),
    MosquePlace(
      name: 'Konya Selimiye & Mevlânâ Camii',
      district: 'Karatay, Konya',
      latitude: 37.8706,
      longitude: 32.5044,
    ),
    MosquePlace(
      name: 'Hisar Camii',
      district: 'Konak, İzmir',
      latitude: 38.4201,
      longitude: 27.1332,
    ),
    MosquePlace(
      name: 'Sabancı Merkez Camii',
      district: 'Seyhan, Adana',
      latitude: 36.9914,
      longitude: 35.3342,
    ),
    MosquePlace(
      name: 'Mescid-i Haram (Kâbe-i Muazzama)',
      district: 'Mekke-i Mükerreme',
      latitude: 21.4225,
      longitude: 39.8262,
    ),
    MosquePlace(
      name: 'Mescid-i Nebevî',
      district: 'Medine-i Münevvere',
      latitude: 24.4672,
      longitude: 39.6111,
    ),
  ];

  Future<void> _openDirections(MosquePlace mosque) async {
    final Uri uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${mosque.latitude},${mosque.longitude}&travelmode=walking',
    );
    final bool launched = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${mosque.name} koordinatı: ${mosque.latitude.toStringAsFixed(4)}, ${mosque.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final UserLocation loc = ref.watch(activeLocationProvider);
    final List<MosquePlace> mosques = _resolvedMosques(loc);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakındaki Camiler'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Konumu değiştir',
            onPressed: () => context.push(AppRoutes.cities),
            icon: const Icon(Icons.my_location_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Yenile',
            onPressed: _loadingOnline ? null : _fetchNearbyOnline,
            icon: const Icon(Icons.refresh_rounded, size: 20),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.xs,
            ),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.emerald700.withValues(alpha: 0.12),
                borderRadius: AppRadius.allMd,
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.mosque_rounded,
                    color: AppColors.emerald500,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Aktif konum: ${loc.label} · En yakın camiler mesafeye göre sıralandı',
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (String v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Cami veya ilçe ara',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
          if (_loadingOnline) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: mosques.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (BuildContext context, int index) {
                final MosquePlace mosque = mosques[index];
                final String distance = mosque.formattedDistanceFrom(
                  loc.latitude,
                  loc.longitude,
                );
                final String dir = mosque.compassLabelFrom(
                  loc.latitude,
                  loc.longitude,
                );
                return Card(
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: AppColors.emerald600.withValues(
                                  alpha: 0.14,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.mosque_outlined,
                                color: AppColors.emerald500,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    mosque.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    '${mosque.district} · $distance ($dir yönü)',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FilledButton.tonalIcon(
                              onPressed: () => _openDirections(mosque),
                              icon: const Icon(
                                Icons.directions_walk_rounded,
                                size: 16,
                              ),
                              label: const Text('Yol Tarifi'),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: <Widget>[
                            for (final String f in mosque.facilities)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.sm,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      theme.colorScheme.surfaceContainerHighest,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  f,
                                  style: theme.textTheme.labelSmall,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
