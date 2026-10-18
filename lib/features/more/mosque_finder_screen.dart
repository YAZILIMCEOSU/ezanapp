import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

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
    this.facilities = const <String>[
      'Cuma Namazı',
      'Şadırvan',
      'Hanımlar Bölümü',
      'Tahiyyetü\'l-Mescid (2 Rekât)',
    ],
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
    final UserLocation current = ref.read(activeLocationProvider);
    if (current.mode == LocationMode.gps) {
      await ref
          .read(locationControllerProvider.notifier)
          .refreshFromGps(requestPermission: true);
    }
    if (mounted) {
      await _fetchNearbyOnline();
    }
  }

  Future<void> _fetchNearbyOnline() async {
    final UserLocation loc = ref.read(activeLocationProvider);
    setState(() => _loadingOnline = true);
    final String overpassQuery =
        '[out:json][timeout:10];('
        'node["amenity"="place_of_worship"]["religion"="muslim"](around:6000,${loc.latitude},${loc.longitude});'
        'way["amenity"="place_of_worship"]["religion"="muslim"](around:6000,${loc.latitude},${loc.longitude});'
        'relation["amenity"="place_of_worship"]["religion"="muslim"](around:6000,${loc.latitude},${loc.longitude});'
        ');out center 60;';
    const List<String> endpoints = <String>[
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];
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
              .timeout(const Duration(seconds: 9));
          if (response.statusCode != 200) continue;
          final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
          if (decoded is! Map<String, Object?>) continue;
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
                    (tags['addr:district'] ??
                            tags['addr:suburb'] ??
                            tags['addr:city'] ??
                            loc.label)
                        as String,
                latitude: lat,
                longitude: lon,
              ),
            );
          }
          if (mounted && parsed.isNotEmpty) {
            setState(() => _onlineMosques = parsed);
            return;
          }
        } catch (_) {
          // Sonraki yansıyı dene.
        }
      }

      // Overpass erişilemezse Nominatim viewbox ile yakın camileri çek.
      const double d = 0.045; // ~5 km yarıçap
      final Uri
      fallbackUri = Uri.https('nominatim.openstreetmap.org', '/search', <
        String,
        String
      >{
        'format': 'jsonv2',
        'q': 'camii',
        'viewbox':
            '${loc.longitude - d},${loc.latitude + d},${loc.longitude + d},${loc.latitude - d}',
        'bounded': '1',
        'limit': '25',
        'accept-language': 'tr',
        'addressdetails': '1',
      });
      final http.Response nomRes = await http
          .get(
            fallbackUri,
            headers: const <String, String>{
              'User-Agent': 'EzanVaktimPro/1.0 (https://ezanai.app)',
            },
          )
          .timeout(const Duration(seconds: 7));
      if (nomRes.statusCode == 200) {
        final Object? decoded = jsonDecode(utf8.decode(nomRes.bodyBytes));
        if (decoded is List) {
          final List<MosquePlace> parsed = <MosquePlace>[];
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
            parsed.add(
              MosquePlace(
                name: title,
                district: loc.label,
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
      // Çevrimdışı durumda yerleşik cami veritabanı kullanılır.
    } finally {
      if (mounted) {
        setState(() => _loadingOnline = false);
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
      final String normalized = rawQuery.toLowerCase();
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

  List<MosquePlace> _resolvedMosques(UserLocation loc) {
    final String q = _query.trim().toLowerCase();
    final List<MosquePlace> basePool = <MosquePlace>[
      if (q.isNotEmpty) ..._searchedMosques,
      ..._onlineMosques,
      ..._landmarkMosques,
      if (_onlineMosques.isEmpty) ..._fallbackCityMosques(loc),
    ];
    final Set<String> seen = <String>{};
    final List<MosquePlace> unique = <MosquePlace>[];
    for (final MosquePlace m in basePool) {
      final String key =
          '${m.name.toLowerCase()}_${m.latitude.toStringAsFixed(3)}_${m.longitude.toStringAsFixed(3)}';
      if (seen.add(key)) {
        unique.add(m);
      }
    }
    if (q.isEmpty) {
      unique.sort(
        (MosquePlace a, MosquePlace b) => a
            .distanceKmFrom(loc.latitude, loc.longitude)
            .compareTo(b.distanceKmFrom(loc.latitude, loc.longitude)),
      );
      return unique;
    }

    final List<MosquePlace> filtered = unique.where((MosquePlace m) {
      return m.name.toLowerCase().contains(q) ||
          m.district.toLowerCase().contains(q);
    }).toList();

    // Eğer çevrimiçi aramadan gelen sonuçlar varsa onları en üstte, geri
    // kalanları mesafeye göre sırala.
    filtered.sort((MosquePlace a, MosquePlace b) {
      final bool aSearched = _searchedMosques.contains(a);
      final bool bSearched = _searchedMosques.contains(b);
      if (aSearched != bSearched) return aSearched ? -1 : 1;
      return a
          .distanceKmFrom(loc.latitude, loc.longitude)
          .compareTo(b.distanceKmFrom(loc.latitude, loc.longitude));
    });
    return filtered;
  }

  static List<MosquePlace> _fallbackCityMosques(UserLocation loc) {
    final String cityLabel = loc.city?.name ?? loc.label;
    return <MosquePlace>[
      MosquePlace(
        name: '$cityLabel Merkez Camii',
        district: cityLabel,
        latitude: loc.latitude + 0.0022,
        longitude: loc.longitude + 0.0018,
        isExactCoordinate: false,
      ),
      MosquePlace(
        name: '$cityLabel Ulu Camii',
        district: cityLabel,
        latitude: loc.latitude - 0.0028,
        longitude: loc.longitude + 0.0024,
        isExactCoordinate: false,
      ),
    ];
  }

  static const List<MosquePlace> _landmarkMosques = <MosquePlace>[
    // BAĞCILAR VE ÇEVRE İLÇELER (Tam koordinatlı merkez camiler)
    MosquePlace(
      name: 'Bağcılar Merkez Camii',
      district: 'Bağcılar, İstanbul',
      latitude: 41.0342,
      longitude: 28.8564,
    ),
    MosquePlace(
      name: 'Bağcılar Hz. Ebubekir Camii',
      district: 'Bağcılar, İstanbul',
      latitude: 41.0365,
      longitude: 28.8525,
    ),
    MosquePlace(
      name: 'Güneşli Merkez Camii',
      district: 'Bağcılar, İstanbul',
      latitude: 41.0319,
      longitude: 28.8267,
    ),
    MosquePlace(
      name: 'Kirazlı Merkez Camii',
      district: 'Bağcılar, İstanbul',
      latitude: 41.0321,
      longitude: 28.8436,
    ),
    MosquePlace(
      name: 'Mahmutbey Merkez Camii',
      district: 'Bağcılar, İstanbul',
      latitude: 41.0539,
      longitude: 28.8314,
    ),
    MosquePlace(
      name: 'Yüzyıl Merkez Camii',
      district: 'Bağcılar, İstanbul',
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

    // 1. Öncelik: Google Haritalar Adım Adım Canlı Navigasyon (başlangıç her zaman telefonun canlı GPS konumu)
    final Uri googleNavUri = mosque.isExactCoordinate
        ? Uri.parse(
            'google.navigation:q=${mosque.latitude},${mosque.longitude}&mode=$navModeCode',
          )
        : Uri.parse(
            'google.navigation:q=${Uri.encodeComponent('${mosque.name} ${mosque.district}')}&mode=$navModeCode',
          );

    // 2. Yedek: Google Maps evrensel yönlendirme (origin parametresi gönderilmez; böylece Haritalar
    // sabit bir koordinat yerine kullanıcının Bağcılar'daki canlı GPS konumunu başlangıç alır).
    final Uri mapsDirUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destParam&travelmode=$travelMode',
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
        googleNavUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (_) {}
    if (!launched) {
      try {
        launched = await launchUrl(
          mapsDirUri,
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
    setState(() => _loadingOnline = true);
    await ref.read(locationControllerProvider.notifier).refreshFromGps();
    await _fetchNearbyOnline();
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
                  TextButton(
                    style: TextButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: () => _openExternalMosqueSearch(loc),
                    child: const Text('Harita'),
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
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              tooltip: 'Camiye Canlı Pusula ve Yön',
                              onPressed: () =>
                                  _showMosqueCompassSheet(mosque, loc),
                              icon: const Icon(
                                Icons.explore_rounded,
                                color: AppColors.emerald500,
                                size: 20,
                              ),
                            ),
                            if (mosque.isExactCoordinate)
                              IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Haritada Tam Yeri İşaretle',
                                onPressed: () => _openExactMapPin(mosque),
                                icon: const Icon(
                                  Icons.location_on_outlined,
                                  color: AppColors.emerald500,
                                  size: 20,
                                ),
                              ),
                            FilledButton.tonalIcon(
                              onPressed: () => _openDirections(mosque, loc),
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
