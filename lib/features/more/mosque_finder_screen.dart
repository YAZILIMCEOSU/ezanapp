import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/services/compass_service.dart';
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
    this.isExactCoordinate = true,
    this.facilities = const <String>[],
  });

  final String name;
  final String district;
  final double latitude;
  final double longitude;
  final bool isExactCoordinate;
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

/// Uyarı şeridi (çevrimdışı / kısmi sonuç).
class _InlineNotice extends StatelessWidget {
  const _InlineNotice({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 18, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tek cami kartı.
///
/// **Düzeltilen hatalar**
/// * Sağ taraftaki iki ikon + "Yol Tarifi" düğmesi 320 dp ekranlarda satırı
///   taşırıyordu (RenderFlex overflow). Düğmeler alt satıra alındı.
/// * Tesis çipleri cami verisinde yokken boş bir boşluk bırakıyordu; artık
///   yalnızca gerçek veri varsa gösterilir (uydurma etiket yok).
/// * Çok uzun cami adları taşmadan kesiliyor.
class _MosqueCard extends StatelessWidget {
  const _MosqueCard({
    required this.mosque,
    required this.distanceLabel,
    required this.directionLabel,
    required this.onCompass,
    required this.onDirections,
    required this.theme,
    this.onExactPin,
  });

  final MosquePlace mosque;
  final String distanceLabel;
  final String directionLabel;
  final VoidCallback onCompass;
  final VoidCallback? onExactPin;
  final VoidCallback onDirections;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.emerald600.withValues(alpha: 0.14),
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
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        mosque.district.isEmpty
                            ? '$distanceLabel ($directionLabel yönü)'
                            : '${mosque.district} · $distanceLabel '
                                  '($directionLabel yönü)',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (mosque.facilities.isNotEmpty) ...<Widget>[
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
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(f, style: theme.textTheme.labelSmall),
                    ),
                ],
              ),
            ],
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.xs,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: <Widget>[
                FilledButton.tonalIcon(
                  onPressed: onDirections,
                  icon: const Icon(Icons.directions_walk_rounded, size: 16),
                  label: const Text('Yol Tarifi'),
                ),
                OutlinedButton.icon(
                  onPressed: onCompass,
                  icon: const Icon(Icons.explore_rounded, size: 16),
                  label: const Text('Pusula'),
                ),
                if (onExactPin != null)
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Haritada Tam Yeri İşaretle',
                    onPressed: onExactPin,
                    icon: const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.emerald500,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// **Türkçe'ye duyarlı arama normalizasyonu.**
///
/// `'İ'.toLowerCase()` Dart'ta `i̇` (i + birleşik nokta) üretir; bu yüzden
/// "ŞİŞLİ" ile "şişli" eşleşmez. Ayrıca kullanıcı çoğu zaman Türkçe karakter
/// yazmaz ("cami", "sisli"). Bu yardımcı tüm aksanları sadeleştirir:
/// `Şişli Camii` → `sisli camii`.
String normalizeTurkish(String input) {
  const Map<String, String> fold = <String, String>{
    'İ': 'i',
    'I': 'i',
    'ı': 'i',
    'Ş': 's',
    'ş': 's',
    'Ğ': 'g',
    'ğ': 'g',
    'Ü': 'u',
    'ü': 'u',
    'Ö': 'o',
    'ö': 'o',
    'Ç': 'c',
    'ç': 'c',
    'Â': 'a',
    'â': 'a',
    'Î': 'i',
    'î': 'i',
    'Û': 'u',
    'û': 'u',
  };
  final StringBuffer buffer = StringBuffer();
  for (final String ch in input.split('')) {
    buffer.write(fold[ch] ?? ch.toLowerCase());
  }
  return buffer
      .toString()
      .replaceAll('\u0307', '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

/// Camileri tekilleştirir: aynı ad (Türkçe normalleştirilmiş) ve ~120 m içinde
/// olan kayıtlar tek kayda indirilir. OSM + Nominatim birlikte kullanıldığında
/// aynı cami 2–4 kez listelenebiliyordu; bu fonksiyon onu engeller.
List<MosquePlace> dedupeMosques(List<MosquePlace> input) {
  final List<MosquePlace> result = <MosquePlace>[];
  for (final MosquePlace candidate in input) {
    final String key = normalizeTurkish(
      candidate.name,
    ).replaceAll(RegExp(r'[^a-z0-9]'), '');
    final bool duplicate = result.any((MosquePlace existing) {
      final String existingKey = normalizeTurkish(
        existing.name,
      ).replaceAll(RegExp(r'[^a-z0-9]'), '');
      final bool sameName =
          key == existingKey ||
          (key.length > 6 &&
              existingKey.length > 6 &&
              (key.contains(existingKey) || existingKey.contains(key)));
      final double metres =
          existing.distanceKmFrom(candidate.latitude, candidate.longitude) *
          1000;
      return sameName && metres < 120;
    });
    if (!duplicate) result.add(candidate);
  }
  return result;
}

/// Etraftaki camileri canlı konumdan bulan, istenen camiyi arayan ve tam nokta
/// navigasyonu açan ekran.
class MosqueFinderScreen extends ConsumerStatefulWidget {
  const MosqueFinderScreen({super.key});

  @override
  ConsumerState<MosqueFinderScreen> createState() => _MosqueFinderScreenState();
}

class _MosqueFinderScreenState extends ConsumerState<MosqueFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  List<MosquePlace> _onlineMosques = const <MosquePlace>[];
  List<MosquePlace> _searchedMosques = const <MosquePlace>[];
  bool _loadingOnline = false;
  bool _searchingOnline = false;
  bool _showInlineMap = true;
  bool _offlineFallback = false;
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _initLocationAndFetch(),
    );
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _initLocationAndFetch() async {
    if (!mounted) return;
    // Önce mevcut koordinatla beklemeden yakın camileri çekmeye başla.
    unawaited(_fetchNearbyOnline());
    final UserLocation current = ref.read(activeLocationProvider);
    if (current.mode == LocationMode.gps) {
      final bool updated = await ref
          .read(locationControllerProvider.notifier)
          .refreshFromGps(requestPermission: true);
      if (updated && mounted) {
        await _fetchNearbyOnline();
      }
    }
  }

  Future<void> _fetchNearbyOnline() async {
    if (!mounted) return;
    final UserLocation loc = ref.read(activeLocationProvider);
    setState(() {
      _loadingOnline = true;
      _offlineFallback = false;
    });
    // ÖNEMLİ: Overpass QL'de `out center 60;` mesafeye göre değil OSM ID'sine göre
    // ilk 60 kaydı kesip en yakın sokak camilerini düşürüyordu!
    // Bu yüzden 2.5 km mahalle yarıçapındaki TÜM cami ve mescitler (`out center;`)
    // eksiksiz çekilip Dart tarafında metre hassasiyetinde sıralanır.
    final String overpassQuery =
        '[out:json][timeout:12];('
        'node["amenity"="place_of_worship"]["religion"="muslim"](around:2500,${loc.latitude},${loc.longitude});'
        'way["amenity"="place_of_worship"]["religion"="muslim"](around:2500,${loc.latitude},${loc.longitude});'
        'relation["amenity"="place_of_worship"]["religion"="muslim"](around:2500,${loc.latitude},${loc.longitude});'
        'node["building"="mosque"](around:2500,${loc.latitude},${loc.longitude});'
        'way["building"="mosque"](around:2500,${loc.latitude},${loc.longitude});'
        ');out center;';
    const List<String> endpoints = <String>[
      'https://overpass-api.de/api/interpreter',
      'https://lz4.overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];
    final List<MosquePlace> collected = <MosquePlace>[];
    try {
      for (final String endpoint in endpoints) {
        try {
          final http.Response response = await http
              .post(
                Uri.parse(endpoint),
                headers: const <String, String>{
                  'User-Agent': 'EzanVaktimPro/1.0 (https://ezanai.app)',
                  'Accept': 'application/json',
                },
                body: <String, String>{'data': overpassQuery},
              )
              .timeout(const Duration(seconds: 8));
          if (response.statusCode != 200) continue;
          final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is! Map<String, Object?>) continue;
          final List<Object?> elements =
              (decoded['elements'] as List<Object?>?) ?? const <Object?>[];
          for (final Object? item in elements) {
            if (item is! Map) continue;
            final Map<String, Object?> tags =
                (item['tags'] as Map?)?.cast<String, Object?>() ??
                <String, Object?>{};
            final String? name =
                (tags['name:tr'] ?? tags['name'] ?? tags['alt_name'])
                    as String?;
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
            final String sub =
                (tags['addr:neighbourhood'] ??
                        tags['addr:suburb'] ??
                        tags['addr:district'] ??
                        tags['addr:city'] ??
                        loc.label)
                    .toString();
            collected.add(
              MosquePlace(
                name: name.trim(),
                district: sub,
                latitude: lat,
                longitude: lon,
              ),
            );
          }
          if (collected.isNotEmpty) break;
        } catch (_) {
          // Sonraki yansıyı dene.
        }
      }

      // Ek olarak Nominatim üzerinden yakın mahalledeki (2.5 km) camileri de çek ve birleştir.
      const double d = 0.024; // ~2.5 km mahalle yarıçapı
      for (final String qTerm in const <String>['camii', 'cami']) {
        if (collected.length >= 25) break;
        try {
          final Uri
          nomUri = Uri.https('nominatim.openstreetmap.org', '/search', <
            String,
            String
          >{
            'format': 'jsonv2',
            'q': qTerm,
            'viewbox':
                '${loc.longitude - d},${loc.latitude + d},${loc.longitude + d},${loc.latitude - d}',
            'bounded': '1',
            'limit': '40',
            'accept-language': 'tr',
            'addressdetails': '1',
          });
          final http.Response nomRes = await http
              .get(
                nomUri,
                headers: const <String, String>{
                  'User-Agent': 'EzanVaktimPro/1.0 (https://ezanai.app)',
                },
              )
              .timeout(const Duration(seconds: 6));
          if (nomRes.statusCode == 200) {
            final Object? decoded = jsonDecode(utf8.decode(nomRes.bodyBytes));
            if (decoded is List) {
              for (final Object? item in decoded) {
                if (item is! Map) continue;
                final double? lat = double.tryParse('${item['lat'] ?? ''}');
                final double? lon = double.tryParse('${item['lon'] ?? ''}');
                if (lat == null || lon == null) continue;
                final String displayName =
                    (item['display_name'] as String? ?? '').trim();
                final String rawName = (item['name'] as String? ?? '').trim();
                final String title = rawName.isNotEmpty
                    ? rawName
                    : displayName.split(',').first.trim();
                if (title.isEmpty) continue;
                final Map<String, Object?> addr =
                    (item['address'] as Map?)?.cast<String, Object?>() ??
                    <String, Object?>{};
                final String sub =
                    (addr['neighbourhood'] ??
                            addr['suburb'] ??
                            addr['town'] ??
                            addr['city_district'] ??
                            loc.label)
                        .toString();
                collected.add(
                  MosquePlace(
                    name: title,
                    district: sub,
                    latitude: lat,
                    longitude: lon,
                  ),
                );
              }
            }
          }
        } catch (_) {}
      }

      if (mounted && collected.isNotEmpty) {
        collected.sort(
          (MosquePlace a, MosquePlace b) => a
              .distanceKmFrom(loc.latitude, loc.longitude)
              .compareTo(b.distanceKmFrom(loc.latitude, loc.longitude)),
        );
        setState(() => _onlineMosques = collected);
      }
    } catch (_) {
      // Çevrimdışı / servis hatası: kullanıcıya açıkça söylenir ve
      // yalnızca yakındaki yerleşik kayıtlar gösterilir.
    } finally {
      if (mounted) {
        setState(() {
          _loadingOnline = false;
          _offlineFallback = collected.isEmpty;
        });
      }
    }
  }

  void _onSearchChanged(String value) {
    setState(() => _query = value);
    _searchDebounce?.cancel();
    final String trimmed = value.trim();
    if (trimmed.length < 2) {
      setState(() {
        _searchedMosques = const <MosquePlace>[];
        _searchingOnline = false;
      });
      return;
    }
    _searchDebounce = Timer(
      const Duration(milliseconds: 420),
      () => _searchOnlineByName(trimmed),
    );
  }

  /// Kullanıcının arama kutusuna yazdığı cami/semt adını OpenStreetMap Nominatim
  /// üzerinden arar ve gerçek koordinatlarıyla listeler.
  Future<void> _searchOnlineByName(String rawQuery) async {
    if (!mounted) return;
    setState(() => _searchingOnline = true);
    try {
      final String normalized = normalizeTurkish(rawQuery);
      final String effectiveQuery =
          normalized.contains('cami') || normalized.contains('mescid')
          ? rawQuery
          : '$rawQuery Camii';
      final Uri uri = Uri.https(
        'nominatim.openstreetmap.org',
        '/search',
        <String, String>{
          'format': 'jsonv2',
          'q': effectiveQuery,
          'limit': '18',
          'accept-language': 'tr',
          'addressdetails': '1',
        },
      );
      final http.Response response = await http
          .get(
            uri,
            headers: const <String, String>{
              'User-Agent': 'EzanVaktimPro/1.0 (https://ezanai.app)',
            },
          )
          .timeout(const Duration(seconds: 7));
      if (response.statusCode != 200) return;
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! List) return;
      final List<MosquePlace> found = <MosquePlace>[];
      for (final Object? item in decoded) {
        if (item is! Map) continue;
        final double? lat = double.tryParse('${item['lat'] ?? ''}');
        final double? lon = double.tryParse('${item['lon'] ?? ''}');
        if (lat == null || lon == null) continue;
        final String displayName = (item['display_name'] as String? ?? '')
            .trim();
        final String rawName = (item['name'] as String? ?? '').trim();
        final String title = rawName.isNotEmpty
            ? rawName
            : displayName.split(',').first.trim();
        if (title.isEmpty) continue;
        final Map<String, Object?> addr =
            (item['address'] as Map?)?.cast<String, Object?>() ??
            <String, Object?>{};
        final String district =
            (addr['town'] ??
                    addr['city_district'] ??
                    addr['suburb'] ??
                    addr['county'] ??
                    addr['province'] ??
                    addr['state'] ??
                    displayName)
                .toString();
        found.add(
          MosquePlace(
            name: title,
            district: district,
            latitude: lat,
            longitude: lon,
          ),
        );
      }
      if (mounted && _query.trim() == rawQuery) {
        setState(() => _searchedMosques = found);
      }
    } catch (_) {
      // Ağ hatasında yerel filtre sonuçları gösterilmeye devam eder.
    } finally {
      if (mounted) {
        setState(() => _searchingOnline = false);
      }
    }
  }

  /// Listeye girecek kayıtlar.
  ///
  /// **Düzeltilen hatalar**
  /// 1. Sabit "landmark" listesi (Bağcılar/İstanbul camileri) **her konumda**
  ///    listeye ekleniyordu; Ankara'daki kullanıcı İstanbul camilerini görüyordu.
  ///    Artık yalnızca çevrimiçi sonuç yoksa **ve** 60 km içindeyse kullanılır.
  /// 2. Aynı cami OSM + Nominatim'den 2–4 kez gelebiliyordu → [dedupeMosques].
  /// 3. Arama `toLowerCase().contains()` ile yapıldığı için "ŞİŞLİ" araması
  ///    "şişli" ile eşleşmiyordu → Türkçe normalizasyon.
  /// 4. Çevrimiçi arama sonuçları, yazılan metni birebir içermediğinde
  ///    (ör. "Ayasofya Camii" → "Ayasofya-i Kebîr Cami-i Şerifi") listeden
  ///    düşüyordu → kaynak bilgisi taşınır, çevrimiçi sonuçlar korunur.
  List<MosquePlace> _resolvedMosques(UserLocation loc) {
    final String q = normalizeTurkish(_query);
    final bool searching = q.isNotEmpty;
    final List<MosquePlace> pool = <MosquePlace>[
      if (searching) ..._searchedMosques,
      ..._onlineMosques,
      if (!searching && _onlineMosques.isEmpty)
        ..._landmarkMosques.where(
          (MosquePlace m) =>
              m.distanceKmFrom(loc.latitude, loc.longitude) <= 60,
        ),
    ];
    final List<MosquePlace> unique = dedupeMosques(pool);

    double distanceOf(MosquePlace m) =>
        m.distanceKmFrom(loc.latitude, loc.longitude);

    if (!searching) {
      unique.sort(
        (MosquePlace a, MosquePlace b) =>
            distanceOf(a).compareTo(distanceOf(b)),
      );
      return unique;
    }

    // Çevrimiçi aramadan gelenler her zaman görünür (metin eşleşmese de).
    final Set<MosquePlace> searched = _searchedMosques.toSet();
    final List<MosquePlace> filtered = unique.where((MosquePlace m) {
      if (searched.contains(m)) return true;
      return normalizeTurkish(m.name).contains(q) ||
          normalizeTurkish(m.district).contains(q);
    }).toList();
    filtered.sort((MosquePlace a, MosquePlace b) {
      final bool aSearched = searched.contains(a);
      final bool bSearched = searched.contains(b);
      if (aSearched != bSearched) return aSearched ? -1 : 1;
      return distanceOf(a).compareTo(distanceOf(b));
    });
    return filtered;
  }

  static const List<MosquePlace> _landmarkMosques = <MosquePlace>[
    // BAĞCILAR MAHALLE CAMİLERİ (Gerçek GPS Koordinatlı)
    MosquePlace(
      name: 'Bağcılar Merkez Camii',
      district: 'Merkez Mah., Bağcılar',
      latitude: 41.0342,
      longitude: 28.8564,
    ),
    MosquePlace(
      name: 'Bağcılar Hz. Ebubekir Camii',
      district: 'Merkez Mah., Bağcılar',
      latitude: 41.0365,
      longitude: 28.8525,
    ),
    MosquePlace(
      name: 'Güneşli Merkez Camii',
      district: 'Güneşli Mah., Bağcılar',
      latitude: 41.0319,
      longitude: 28.8267,
    ),
    MosquePlace(
      name: 'Kirazlı Merkez Camii',
      district: 'Kirazlı Mah., Bağcılar',
      latitude: 41.0321,
      longitude: 28.8436,
    ),
    MosquePlace(
      name: 'Yenigün Merkez Camii',
      district: 'Yenigün Mah., Bağcılar',
      latitude: 41.0289,
      longitude: 28.8615,
    ),
    MosquePlace(
      name: 'Yıldıztepe Merkez Camii',
      district: 'Yıldıztepe Mah., Bağcılar',
      latitude: 41.0246,
      longitude: 28.8548,
    ),
    MosquePlace(
      name: 'Çınar Mahallesi Merkez Camii',
      district: 'Çınar Mah., Bağcılar',
      latitude: 41.0384,
      longitude: 28.8622,
    ),
    MosquePlace(
      name: 'Sancaktepe Mahallesi Camii',
      district: 'Sancaktepe Mah., Bağcılar',
      latitude: 41.0358,
      longitude: 28.8594,
    ),
    MosquePlace(
      name: 'İnönü Mahallesi Merkez Camii',
      district: 'İnönü Mah., Bağcılar',
      latitude: 41.0312,
      longitude: 28.8511,
    ),
    MosquePlace(
      name: 'Yavuz Selim Merkez Camii',
      district: 'Yavuz Selim Mah., Bağcılar',
      latitude: 41.0395,
      longitude: 28.8551,
    ),
    MosquePlace(
      name: 'Kazım Karabekir Camii',
      district: 'Kazım Karabekir Mah., Bağcılar',
      latitude: 41.0428,
      longitude: 28.8504,
    ),
    MosquePlace(
      name: 'Hürriyet Mahallesi Merkez Camii',
      district: 'Hürriyet Mah., Bağcılar',
      latitude: 41.0274,
      longitude: 28.8328,
    ),
    MosquePlace(
      name: 'Göztepe Mahallesi Merkez Camii',
      district: 'Göztepe Mah., Bağcılar',
      latitude: 41.0491,
      longitude: 28.8442,
    ),
    MosquePlace(
      name: 'Fatih Mahallesi Merkez Camii',
      district: 'Fatih Mah., Bağcılar',
      latitude: 41.0462,
      longitude: 28.8519,
    ),
    MosquePlace(
      name: 'Fevzi Çakmak Merkez Camii',
      district: 'Fevzi Çakmak Mah., Bağcılar',
      latitude: 41.0445,
      longitude: 28.8602,
    ),
    MosquePlace(
      name: 'Kemalpaşa Merkez Camii',
      district: 'Kemalpaşa Mah., Bağcılar',
      latitude: 41.0518,
      longitude: 28.8568,
    ),
    MosquePlace(
      name: 'Barbaros Mahallesi Camii',
      district: 'Barbaros Mah., Bağcılar',
      latitude: 41.0298,
      longitude: 28.8421,
    ),
    MosquePlace(
      name: 'Bağlar Mahallesi Merkez Camii',
      district: 'Bağlar Mah., Bağcılar',
      latitude: 41.0351,
      longitude: 28.8214,
    ),
    MosquePlace(
      name: 'Demirkapı Mahallesi Camii',
      district: 'Demirkapı Mah., Bağcılar',
      latitude: 41.0419,
      longitude: 28.8394,
    ),
    MosquePlace(
      name: '15 Temmuz Mahallesi Camii',
      district: '15 Temmuz Mah., Bağcılar',
      latitude: 41.0412,
      longitude: 28.8178,
    ),
    MosquePlace(
      name: 'Mahmutbey Merkez Camii',
      district: 'Mahmutbey Mah., Bağcılar',
      latitude: 41.0539,
      longitude: 28.8314,
    ),
    MosquePlace(
      name: 'Yüzyıl Merkez Camii',
      district: 'Yüzyıl Mah., Bağcılar',
      latitude: 41.0598,
      longitude: 28.8521,
    ),
    MosquePlace(
      name: 'Şirinevler Ulu Camii',
      district: 'Bahçelievler, İstanbul',
      latitude: 40.9998,
      longitude: 28.8492,
    ),
    MosquePlace(
      name: 'Bahçelievler Merkez Camii',
      district: 'Bahçelievler, İstanbul',
      latitude: 41.0019,
      longitude: 28.8604,
    ),
    MosquePlace(
      name: 'Güngören Merkez Camii',
      district: 'Güngören, İstanbul',
      latitude: 41.0197,
      longitude: 28.8762,
    ),
    MosquePlace(
      name: 'Esenler Dörtyol Merkez Camii',
      district: 'Esenler, İstanbul',
      latitude: 41.0432,
      longitude: 28.8758,
    ),
    MosquePlace(
      name: 'Bakırköy Çarşı Camii',
      district: 'Bakırköy, İstanbul',
      latitude: 40.9792,
      longitude: 28.8739,
    ),
    MosquePlace(
      name: 'Küçükçekmece Merkez Fatih Camii',
      district: 'Küçükçekmece, İstanbul',
      latitude: 41.0014,
      longitude: 28.7742,
    ),
    MosquePlace(
      name: 'Başakşehir Merkez Camii',
      district: 'Başakşehir, İstanbul',
      latitude: 41.1062,
      longitude: 28.8024,
    ),
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
      name: 'Fatih Camii',
      district: 'Fatih, İstanbul',
      latitude: 41.0197,
      longitude: 28.9499,
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
      name: 'Taksim Camii',
      district: 'Beyoğlu, İstanbul',
      latitude: 41.0363,
      longitude: 28.9845,
    ),
    MosquePlace(
      name: 'Eminönü Yeni Camii',
      district: 'Fatih, İstanbul',
      latitude: 41.0169,
      longitude: 28.9719,
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
      name: 'Beştepe Millet Camii',
      district: 'Yenimahalle, Ankara',
      latitude: 39.9311,
      longitude: 32.7997,
    ),
    MosquePlace(
      name: 'Bursa Ulu Camii',
      district: 'Osmangazi, Bursa',
      latitude: 40.1839,
      longitude: 29.0619,
    ),
    MosquePlace(
      name: 'Emir Sultan Camii',
      district: 'Yıldırım, Bursa',
      latitude: 40.1814,
      longitude: 29.0809,
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

  /// Kullanıcının canlı GPS konumundan seçilen caminin tam koordinatına adım adım navigasyon açar.
  Future<void> _openDirections(
    MosquePlace mosque,
    UserLocation userLoc, {
    String travelMode = 'walking',
  }) async {
    final String navModeCode = travelMode == 'driving' ? 'd' : 'w';
    final String destParam = mosque.isExactCoordinate
        ? '${mosque.latitude},${mosque.longitude}'
        : Uri.encodeComponent('${mosque.name} ${mosque.district}');

    // 1. Öncelik: Google Haritalar Evrensel Rota Önizleme & Başlat Ekranı
    // (Bina içinde Wi-Fi/hücresel konumda bile "GPS aranıyor" ekranında takılmadan
    // tam yürüyüş/araç rotasını, süreyi ve "Başlat" butonunu anında açar).
    final Uri mapsDirUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destParam&travelmode=$travelMode',
    );

    // 2. Yedek: Doğrudan sesli navigasyon şeması
    final Uri googleNavUri = mosque.isExactCoordinate
        ? Uri.parse(
            'google.navigation:q=${mosque.latitude},${mosque.longitude}&mode=$navModeCode',
          )
        : Uri.parse(
            'google.navigation:q=${Uri.encodeComponent('${mosque.name} ${mosque.district}')}&mode=$navModeCode',
          );

    final Uri geoPinUri = mosque.isExactCoordinate
        ? Uri.parse(
            'geo:${mosque.latitude},${mosque.longitude}?q=${mosque.latitude},${mosque.longitude}(${Uri.encodeComponent(mosque.name)})',
          )
        : Uri.parse(
            'geo:${userLoc.latitude},${userLoc.longitude}?q=${Uri.encodeComponent('${mosque.name} ${mosque.district}')}',
          );

    bool launched = false;
    try {
      launched = await launchUrl(
        mapsDirUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!launched) {
      try {
        launched = await launchUrl(
          googleNavUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }
    if (!launched) {
      try {
        launched = await launchUrl(
          geoPinUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }
    if (!launched) {
      try {
        launched = await launchUrl(
          mapsDirUri,
          mode: LaunchMode.platformDefault,
        );
      } catch (_) {}
    }
    if (!launched && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${mosque.name} koordinatı: ${mosque.latitude.toStringAsFixed(5)}, ${mosque.longitude.toStringAsFixed(5)}',
          ),
        ),
      );
    }
  }

  /// Seçilen camiye uygulama içi canlı pusula yönünü ve navigasyon seçeneklerini açar.
  void _showMosqueCompassSheet(MosquePlace mosque, UserLocation userLoc) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (BuildContext sheetContext) {
        return _MosqueLiveCompassSheet(
          mosque: mosque,
          userLocation: userLoc,
          onStartWalking: () {
            Navigator.of(sheetContext).pop();
            _openDirections(mosque, userLoc, travelMode: 'walking');
          },
          onStartDriving: () {
            Navigator.of(sheetContext).pop();
            _openDirections(mosque, userLoc, travelMode: 'driving');
          },
          onOpenPin: () {
            Navigator.of(sheetContext).pop();
            _openExactMapPin(mosque);
          },
        );
      },
    );
  }

  /// Haritada caminin veya kullanıcının tam noktasını işaretler (pin).
  Future<void> _openExactMapPin(MosquePlace mosque) async {
    final Uri geoUri = Uri.parse(
      'geo:${mosque.latitude},${mosque.longitude}?q=${mosque.latitude},${mosque.longitude}(${Uri.encodeComponent(mosque.name)})',
    );
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}',
    );
    bool launched = false;
    try {
      launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!launched) {
      try {
        launched = await launchUrl(
          webUri,
          mode: LaunchMode.externalApplication,
        );
      } catch (_) {}
    }
  }

  /// Haritada doğrudan arama sorgusunu veya yakın camileri açar.
  Future<void> _openExternalMosqueSearch(
    UserLocation loc, {
    String? customQuery,
  }) async {
    final String q = (customQuery != null && customQuery.trim().isNotEmpty)
        ? '${customQuery.trim()} camii'
        : 'yakındaki camiler';
    final Uri geoUri = Uri.parse(
      'geo:${loc.latitude},${loc.longitude}?q=${Uri.encodeComponent(q)}',
    );
    final Uri webUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent('$q ${loc.label}')}',
    );
    bool launched = false;
    try {
      launched = await launchUrl(geoUri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!launched) {
      try {
        await launchUrl(webUri, mode: LaunchMode.externalApplication);
      } catch (_) {}
    }
  }

  Future<void> _refreshGpsAndFetch() async {
    if (!mounted) return;
    setState(() => _loadingOnline = true);
    await ref.read(locationControllerProvider.notifier).refreshFromGps();
    await _fetchNearbyOnline();
  }

  /// Liste / boş / yükleniyor / hata durumlarını üretir.
  Widget _buildMosqueList(
    List<MosquePlace> mosques,
    UserLocation loc,
    ThemeData theme,
  ) {
    if (mosques.isEmpty) {
      if (_loadingOnline || _searchingOnline) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: AppSpacing.xxl),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              CircularProgressIndicator(),
              SizedBox(height: AppSpacing.md),
              Text('Yakındaki camiler aranıyor…'),
            ],
          ),
        );
      }
      final bool searching = _query.trim().isNotEmpty;
      return ListView(
        // RefreshIndicator'ın çalışması için kaydırılabilir boş görünüm.
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpacing.xl),
        children: <Widget>[
          const SizedBox(height: AppSpacing.xl),
          Icon(
            searching ? Icons.search_off_rounded : Icons.mosque_outlined,
            size: 48,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            searching
                ? '"${_query.trim()}" için yakında cami bulunamadı.'
                : 'Bu konumda kayıtlı cami bulunamadı.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            searching
                ? 'Yazımı kontrol edin (ör. "Sultanahmet"), daha kısa bir ad '
                      'yazın veya haritada arayın.'
                : 'Konumunuzu GPS ile güncelleyin veya şehir seçin; internet '
                      'yoksa yalnızca kayıtlı camiler listelenir.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: AppSpacing.sm,
            runSpacing: AppSpacing.sm,
            children: <Widget>[
              FilledButton.tonalIcon(
                onPressed: _loadingOnline ? null : _refreshGpsAndFetch,
                icon: const Icon(Icons.my_location_rounded, size: 18),
                label: const Text('Konumumu güncelle'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  await context.push(AppRoutes.cities);
                  if (mounted) await _fetchNearbyOnline();
                },
                icon: const Icon(Icons.location_city_rounded, size: 18),
                label: const Text('Şehir seç'),
              ),
              if (searching)
                OutlinedButton.icon(
                  onPressed: () =>
                      _openExternalMosqueSearch(loc, customQuery: _query),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: const Text('Haritada ara'),
                ),
            ],
          ),
        ],
      );
    }

    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppSpacing.lg),
      itemCount: mosques.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: AppSpacing.sm),
      itemBuilder: (BuildContext context, int index) {
        final MosquePlace mosque = mosques[index];
        return _MosqueCard(
          mosque: mosque,
          distanceLabel: mosque.formattedDistanceFrom(
            loc.latitude,
            loc.longitude,
          ),
          directionLabel: mosque.compassLabelFrom(loc.latitude, loc.longitude),
          onCompass: () => _showMosqueCompassSheet(mosque, loc),
          onExactPin: mosque.isExactCoordinate
              ? () => _openExactMapPin(mosque)
              : null,
          onDirections: () => _openDirections(mosque, loc),
          theme: theme,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserLocation>(activeLocationProvider, (
      UserLocation? prev,
      UserLocation next,
    ) {
      if (prev == null ||
          (prev.latitude - next.latitude).abs() > 1e-3 ||
          (prev.longitude - next.longitude).abs() > 1e-3) {
        unawaited(_fetchNearbyOnline());
      }
    });

    final UserLocation loc = ref.watch(activeLocationProvider);
    final List<MosquePlace> mosques = _resolvedMosques(loc);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cami Bul & Navigasyon'),
        actions: <Widget>[
          IconButton(
            tooltip: 'Kıble Pusulası',
            onPressed: () => context.push(AppRoutes.qibla),
            icon: const Icon(Icons.explore_outlined, size: 20),
          ),
          IconButton(
            tooltip: 'GPS ile tam konumumu güncelle',
            onPressed: _loadingOnline ? null : _refreshGpsAndFetch,
            icon: const Icon(Icons.my_location_rounded, size: 20),
          ),
          IconButton(
            tooltip: 'Şehir seç',
            onPressed: () async {
              await context.push(AppRoutes.cities);
              if (mounted) {
                await _fetchNearbyOnline();
              }
            },
            icon: const Icon(Icons.location_city_rounded, size: 20),
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
                    Icons.my_location_rounded,
                    color: AppColors.emerald500,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Tam konum: ${loc.label} (${loc.latitude.toStringAsFixed(4)}, ${loc.longitude.toStringAsFixed(4)}) · Konum değiştikçe otomatik güncellenir',
                      style: theme.textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  TextButton.icon(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () =>
                        setState(() => _showInlineMap = !_showInlineMap),
                    icon: Icon(
                      _showInlineMap
                          ? Icons.visibility_off_outlined
                          : Icons.map_rounded,
                      size: 16,
                    ),
                    label: Text(_showInlineMap ? 'Haritayı Gizle' : 'Harita'),
                  ),
                ],
              ),
            ),
          ),
          if (_showInlineMap && MediaQuery.sizeOf(context).height >= 620)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 4,
              ),
              child: Container(
                height: 185,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F2F1),
                  borderRadius: AppRadius.allMd,
                  border: Border.all(
                    color: AppColors.emerald500.withValues(alpha: 0.45),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: _LiveMosquesInteractiveMap(
                  userLocation: loc,
                  mosques: mosques.take(30).toList(growable: false),
                  onSelectMosque: (MosquePlace m) => _openDirections(m, loc),
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
              onChanged: _onSearchChanged,
              textInputAction: TextInputAction.search,
              onSubmitted: (String v) {
                if (v.trim().isNotEmpty) {
                  _searchOnlineByName(v.trim());
                }
              },
              decoration: InputDecoration(
                hintText: 'İstediğiniz camiyi, mahalleyi veya ilçeyi arayın…',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
              ),
            ),
          ),
          if (_query.trim().isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: 2,
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () =>
                      _openExternalMosqueSearch(loc, customQuery: _query),
                  icon: const Icon(Icons.map_outlined, size: 18),
                  label: Text(
                    'Haritalar\'da "${_query.trim()}" Cami Ara ve Tam Yeri İşaretle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          if (_loadingOnline || _searchingOnline)
            const LinearProgressIndicator(minHeight: 2),
          if (_offlineFallback && _query.trim().isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: _InlineNotice(
                icon: Icons.cloud_off_rounded,
                text:
                    'Çevrimiçi cami verisi alınamadı (internet veya servis '
                    'sorunu). Yalnızca uygulamada kayıtlı ve 60 km içindeki '
                    'camiler gösteriliyor. Yenilemek için listeyi aşağı çekin.',
              ),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchNearbyOnline,
              child: _buildMosqueList(mosques, loc, theme),
            ),
          ),
        ],
      ),
    );
  }
}

/// Seçilen camiye uygulama içi canlı pusula yönü ve adım adım navigasyon başlatma paneli.
class _MosqueLiveCompassSheet extends ConsumerStatefulWidget {
  const _MosqueLiveCompassSheet({
    required this.mosque,
    required this.userLocation,
    required this.onStartWalking,
    required this.onStartDriving,
    required this.onOpenPin,
  });

  final MosquePlace mosque;
  final UserLocation userLocation;
  final VoidCallback onStartWalking;
  final VoidCallback onStartDriving;
  final VoidCallback onOpenPin;

  @override
  ConsumerState<_MosqueLiveCompassSheet> createState() =>
      _MosqueLiveCompassSheetState();
}

class _MosqueLiveCompassSheetState
    extends ConsumerState<_MosqueLiveCompassSheet> {
  StreamSubscription<CompassReading?>? _sub;
  CompassReading? _reading;

  @override
  void initState() {
    super.initState();
    final CompassService service = ref.read(compassServiceProvider);
    final double targetBearing = widget.mosque.bearingFrom(
      widget.userLocation.latitude,
      widget.userLocation.longitude,
    );
    final double decl = GeoUtils.magneticDeclination(
      widget.userLocation.latitude,
      widget.userLocation.longitude,
    );
    _sub = service.readings.listen((CompassReading? r) {
      if (!mounted) return;
      setState(() {
        _reading = r?.withQibla(targetBearing, declination: decl);
      });
    });
    service.start(qiblaDirection: targetBearing, declination: decl);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double bearing = widget.mosque.bearingFrom(
      widget.userLocation.latitude,
      widget.userLocation.longitude,
    );
    final String dist = widget.mosque.formattedDistanceFrom(
      widget.userLocation.latitude,
      widget.userLocation.longitude,
    );
    final String dirLabel = widget.mosque.compassLabelFrom(
      widget.userLocation.latitude,
      widget.userLocation.longitude,
    );
    final double heading = _reading?.heading ?? 0;
    final double diff = GeoUtils.normalizeSigned(bearing - heading);
    final bool aligned = diff.abs() <= 8;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.xl,
          AppSpacing.sm,
          AppSpacing.xl,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              widget.mosque.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.mosque.district} · Mesafe: $dist · Yön: ${bearing.toStringAsFixed(0)}° ($dirLabel)',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Center(
              child: Container(
                width: 132,
                height: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (aligned ? AppColors.success : AppColors.emerald500)
                      .withValues(alpha: 0.12),
                  border: Border.all(
                    color: aligned ? AppColors.success : AppColors.emerald500,
                    width: 2.2,
                  ),
                ),
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: diff * math.pi / 180.0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.navigation_rounded,
                        size: 48,
                        color: aligned
                            ? AppColors.success
                            : AppColors.emerald500,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        aligned ? 'TAM KARŞIDA' : '${diff.abs().round()}°',
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: widget.onStartWalking,
              icon: const Icon(Icons.directions_walk_rounded),
              label: const Text('Yürüyerek Canlı Navigasyon Başlat'),
            ),
            const SizedBox(height: AppSpacing.sm),
            FilledButton.tonalIcon(
              onPressed: widget.onStartDriving,
              icon: const Icon(Icons.directions_car_rounded),
              label: const Text('Araçla Canlı Navigasyon Başlat'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: widget.onOpenPin,
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Haritada Tam Konumunu İşaretle'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Yakındaki tüm camileri ve kullanıcının konumunu sokak/uydu haritası üzerinde
/// canlı işaretleyen etkileşimli harita bileşeni.
class _LiveMosquesInteractiveMap extends StatefulWidget {
  const _LiveMosquesInteractiveMap({
    required this.userLocation,
    required this.mosques,
    required this.onSelectMosque,
  });

  final UserLocation userLocation;
  final List<MosquePlace> mosques;
  final ValueChanged<MosquePlace> onSelectMosque;

  @override
  State<_LiveMosquesInteractiveMap> createState() =>
      _LiveMosquesInteractiveMapState();
}

class _LiveMosquesInteractiveMapState
    extends State<_LiveMosquesInteractiveMap> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() {
    try {
      if (WebViewPlatform.instance == null) return;
      final WebViewController ctrl = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFE0F2F1))
        ..addJavaScriptChannel(
          'MosqueBridge',
          onMessageReceived: (JavaScriptMessage msg) {
            final int? idx = int.tryParse(msg.message);
            if (idx != null && idx >= 0 && idx < widget.mosques.length) {
              widget.onSelectMosque(widget.mosques[idx]);
            }
          },
        )
        ..loadHtmlString(_buildHtml());
      _controller = ctrl;
    } catch (_) {
      _controller = null;
    }
  }

  @override
  void didUpdateWidget(covariant _LiveMosquesInteractiveMap oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((oldWidget.userLocation.latitude - widget.userLocation.latitude).abs() >
            1e-4 ||
        (oldWidget.userLocation.longitude - widget.userLocation.longitude)
                .abs() >
            1e-4 ||
        oldWidget.mosques.length != widget.mosques.length) {
      try {
        _controller?.loadHtmlString(_buildHtml());
      } catch (_) {}
    }
  }

  String _buildHtml() {
    final double uLat = widget.userLocation.latitude;
    final double uLon = widget.userLocation.longitude;
    final List<Map<String, Object>> items = <Map<String, Object>>[];
    for (int i = 0; i < widget.mosques.length; i++) {
      final MosquePlace m = widget.mosques[i];
      items.add(<String, Object>{
        'i': i,
        'n': m.name,
        'd': m.formattedDistanceFrom(uLat, uLon),
        'lat': m.latitude,
        'lon': m.longitude,
      });
    }
    final String mosquesJson = jsonEncode(items);
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
  .m-btn {
    margin-top:6px; background:#00796B; color:#fff; border:none;
    border-radius:8px; padding:5px 10px; font-size:11px; font-weight:700; cursor:pointer;
  }
</style>
</head>
<body>
<div id="map"></div>
<script>
  var uLat = $uLat;
  var uLon = $uLon;
  var mosques = $mosquesJson;
  var map = L.map('map', { zoomControl: true }).setView([uLat, uLon], 15);
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19, attribution: 'OSM'
  }).addTo(map);

  L.circleMarker([uLat, uLon], {
    radius: 9, fillColor: '#2962FF', color: '#ffffff', weight: 3, fillOpacity: 1
  }).addTo(map).bindPopup('<b>Konumunuz</b>');

  mosques.forEach(function(m) {
    var marker = L.circleMarker([m.lat, m.lon], {
      radius: 8, fillColor: '#00897B', color: '#ffffff', weight: 2.5, fillOpacity: 0.95
    }).addTo(map);
    marker.bindPopup(
      '<div style="text-align:center;"><b>' + m.n + '</b><br/><span style="font-size:11px;color:#555;">Mesafe: ' + m.d + '</span><br/>' +
      '<button class="m-btn" onclick="window.MosqueBridge.postMessage('' + m.i + '')">Yol Tarifi Başlat</button></div>'
    );
  });
</script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null) {
      return Center(
        child: Text(
          'Yakınızda ${widget.mosques.length} cami listelendi',
          style: Theme.of(context).textTheme.labelMedium,
        ),
      );
    }
    return WebViewWidget(controller: _controller!);
  }
}
