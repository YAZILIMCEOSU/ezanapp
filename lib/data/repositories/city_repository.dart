import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/services.dart';

import '../../core/utils/logger.dart';
import '../../core/utils/text_normalizer.dart';
import '../models/city.dart';

/// Şehir/ilçe verisi.
///
/// * Türkiye: 81 il + ~860 ilçe (Diyanet ilçe kimlikleriyle) — resmî vakit
///   verisi için `id` doğrudan kullanılır.
/// * Dünya: 118 ülkeden ~4900 şehir.
///
/// Aramada Türkçe diakritik duyarsız eşleşme ve "başlıyor" önceliği vardır.
class CityRepository {
  CityRepository({AssetBundle? bundle}) : _bundle = bundle ?? rootBundle;

  final AssetBundle _bundle;

  List<City>? _turkish;
  List<City>? _world;
  Map<String, City>? _byId;

  Future<List<City>> turkishCities() async {
    if (_turkish != null) return _turkish!;
    try {
      final Object? decoded = jsonDecode(
          await _bundle.loadString('assets/data/cities_turkey.json'));
      final List<City> cities = <City>[];
      if (decoded is Map<String, Object?>) {
        final List<Object?> provinces =
            (decoded['provinces'] as List<Object?>?) ?? const <Object?>[];
        for (final Object? item in provinces) {
          if (item is! Map) continue;
          final Map<String, Object?> json = item.cast<String, Object?>();
          cities.add(
            City(
              id: '${json['id']}',
              name: (json['name'] as String?) ?? '',
              latitude: (json['lat'] as num?)?.toDouble() ?? 0,
              longitude: (json['lon'] as num?)?.toDouble() ?? 0,
              province: (json['name'] as String?) ?? '',
              country: 'Türkiye',
            ),
          );
        }

        final List<Object?> districts =
            (decoded['districts'] as List<Object?>?) ?? const <Object?>[];
        for (final Object? item in districts) {
          if (item is! Map) continue;
          final Map<String, Object?> json = item.cast<String, Object?>();
          final String name = (json['name'] as String?) ?? '';
          final String province = (json['province'] as String?) ?? '';
          cities.add(
            City(
              id: '${json['id']}',
              name: _titleCase(name),
              latitude: (json['lat'] as num?)?.toDouble() ?? 0,
              longitude: (json['lon'] as num?)?.toDouble() ?? 0,
              province: province,
              country: 'Türkiye',
            ),
          );
        }
      }
      cities.sort((City a, City b) => a.name.compareTo(b.name));
      _turkish = cities;
      return cities;
    } catch (error) {
      AppLog.error('Türkiye şehir verisi okunamadı', error: error);
      _turkish = const <City>[];
      return _turkish!;
    }
  }

  Future<List<City>> worldCities() async {
    if (_world != null) return _world!;
    final List<City> cities = <City>[];
    try {
      final Object? decoded =
          jsonDecode(await _bundle.loadString('assets/data/cities_world.json'));
      if (decoded is Map<String, Object?>) {
        final List<Object?> countries =
            (decoded['countries'] as List<Object?>?) ?? const <Object?>[];
        for (final Object? countryItem in countries) {
          if (countryItem is! Map) continue;
          final Map<String, Object?> country =
              countryItem.cast<String, Object?>();
          final String countryName =
              _titleCase((country['name'] as String?) ?? '');
          final List<Object?> list =
              (country['cities'] as List<Object?>?) ?? const <Object?>[];
          for (final Object? item in list) {
            if (item is! Map) continue;
            final Map<String, Object?> json = item.cast<String, Object?>();
            cities.add(
              City(
                id: '${json['id']}',
                name: (json['n'] as String?) ?? '',
                latitude: (json['lat'] as num?)?.toDouble() ?? 0,
                longitude: (json['lon'] as num?)?.toDouble() ?? 0,
                province: countryName,
                country: countryName,
                isTurkish: false,
              ),
            );
          }
        }
      }
    } catch (error) {
      AppLog.error('Dünya şehir verisi okunamadı', error: error);
    }
    _world = cities;
    return cities;
  }

  Future<Map<String, City>> _index() async {
    if (_byId != null) return _byId!;
    final Map<String, City> index = <String, City>{};
    for (final City city in await turkishCities()) {
      index[city.id] = city;
    }
    for (final City city in await worldCities()) {
      index.putIfAbsent(city.id, () => city);
    }
    _byId = index;
    return index;
  }

  Future<City?> byId(String id) async => (await _index())[id];

  /// Türkiye öncelikli arama. [includeWorld] false ise yalnızca Türkiye.
  Future<List<City>> search(String query,
      {int limit = 30, bool includeWorld = true}) async {
    final String needle = TextNormalizer.normalize(query.trim());
    if (needle.isEmpty) return const <City>[];

    final List<City> results = <City>[];
    final List<City> turkey = await turkishCities();

    for (final City city in turkey) {
      if (_score(city, needle) > 0) results.add(city);
    }
    if (includeWorld && results.length < limit) {
      for (final City city in await worldCities()) {
        if (_score(city, needle) > 0) results.add(city);
      }
    }

    results.sort((City a, City b) {
      final int sa = _score(a, needle);
      final int sb = _score(b, needle);
      if (sa != sb) return sb.compareTo(sa);
      if (a.isTurkish != b.isTurkish) return a.isTurkish ? -1 : 1;
      return a.name.compareTo(b.name);
    });
    return results.take(limit).toList(growable: false);
  }

  /// 0 = eşleşme yok. Yüksek puan = daha iyi eşleşme.
  int _score(City city, String needle) {
    final String name = TextNormalizer.normalize(city.name);
    final String province = TextNormalizer.normalize(city.province ?? '');
    final String country = TextNormalizer.normalize(city.country);
    final String combined = '$name $province $country';

    int score = 0;
    if (name == needle) score += 100;
    if (name.startsWith(needle)) score += 60;
    if (name.contains(needle)) score += 40;
    if (province == needle) score += 35;
    if (province.startsWith(needle)) score += 25;
    if (country.startsWith(needle)) score += 12;
    if (score == 0 && combined.contains(needle)) score += 8;
    if (city.isTurkish) score += 4;
    return score;
  }

  /// GPS koordinatına en yakın ilçe/şehir — resmî Diyanet verisi için
  /// ilçe kimliği elde etmeye yarar. Çok uzaksa (ör. yurt dışı) null döner.
  Future<City?> nearest(double latitude, double longitude,
      {double maxDistanceKm = 25}) async {
    City? best;
    double bestDistance = double.infinity;
    for (final City city in await turkishCities()) {
      final double distance =
          _haversine(latitude, longitude, city.latitude, city.longitude);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = city;
      }
    }
    if (best != null && bestDistance <= maxDistanceKm) return best;

    for (final City city in await worldCities()) {
      final double distance =
          _haversine(latitude, longitude, city.latitude, city.longitude);
      if (distance < bestDistance) {
        bestDistance = distance;
        best = city;
      }
    }
    return bestDistance <= maxDistanceKm ? best : null;
  }

  /// Kullanıcının gösterilecek konum adı: şehir yoksa "En yakın şehir (x km)".
  Future<String> describePoint(double latitude, double longitude) async {
    final City? near = await nearest(latitude, longitude, maxDistanceKm: 60);
    if (near == null) return 'Mevcut konum';
    final double distance =
        _haversine(latitude, longitude, near.latitude, near.longitude);
    if (distance < 2) return near.displayName;
    return '${near.displayName} yakını';
  }

  /// Öne çıkan Türkiye illeri (konum seçimi başlangıç listesi).
  Future<List<City>> featuredProvinces({int limit = 12}) async {
    const List<String> featured = <String>[
      'İstanbul',
      'Ankara',
      'İzmir',
      'Bursa',
      'Antalya',
      'Adana',
      'Konya',
      'Gaziantep',
      'Şanlıurfa',
      'Diyarbakır',
      'Kayseri',
      'Trabzon',
    ];
    final List<City> turkey = await turkishCities();
    final List<City> result = <City>[];
    for (final String name in featured) {
      final String needle = TextNormalizer.normalize(name);
      for (final City city in turkey) {
        if (city.name == name && city.province == city.name) {
          result.add(city);
          break;
        }
        if (TextNormalizer.normalize(city.name) == needle &&
            city.isTurkish &&
            result.length < limit) {
          result.add(city);
          break;
        }
      }
      if (result.length >= limit) break;
    }
    return result;
  }

  static double _haversine(double lat1, double lon1, double lat2, double lon2) {
    const double radius = 6371.0;
    const double deg2rad = math.pi / 180;
    final double dLat = (lat2 - lat1) * deg2rad;
    final double dLon = (lon2 - lon1) * deg2rad;
    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(lat1 * deg2rad) *
            math.cos(lat2 * deg2rad) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return radius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  static String _titleCase(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map((String word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }
}
