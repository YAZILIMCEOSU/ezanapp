import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' show ConflictAlgorithm;

import '../../core/constants/app_constants.dart';
import '../../core/db/app_database.dart';
import '../../core/utils/logger.dart';
import '../models/ilahi_models.dart';

/// İlahi/dini ses içerikleri deposu.
///
/// İçerik kaynakları:
/// 1. Yapılandırılmış uzak katalog (`ILAHI_CATALOG_URL`) — yalnızca lisans/izin
///    bilgisi bulunan kayıtlar kabul edilir.
/// 2. Kullanıcının cihazdan içe aktardığı kendi ses dosyaları.
///
/// İndirilen içerikler çevrimdışı dinlenebilir; favoriler, son dinlenenler ve
/// çalma listeleri SQLite'ta saklanır.
class IlahiRepository {
  IlahiRepository(this._database, {http.Client? client, this.catalogUrl})
    : _client = client ?? http.Client();

  final AppDatabase _database;
  final http.Client _client;

  /// Yapılandırma yoksa null: katalog yalnızca yerel içeriklerden oluşur.
  final String? catalogUrl;

  List<IlahiTrack>? _cachedCatalog;

  /// Kataloğu getirir: SQLite önbelleği → uzak katalog → yerel dosyalar.
  Future<List<IlahiTrack>> catalog({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedCatalog != null) return _cachedCatalog!;

    final List<IlahiTrack> local = await localTracks();
    List<IlahiTrack> remote = <IlahiTrack>[];

    final bool cacheFresh = await _isCacheFresh();
    if (!forceRefresh && cacheFresh) {
      remote = await _readCache();
    } else if (catalogUrl != null && catalogUrl!.isNotEmpty) {
      remote = await _fetchRemote();
      if (remote.isNotEmpty) {
        await _writeCache(remote);
      } else {
        remote = await _readCache();
      }
    } else {
      remote = await _readCache();
    }

    _cachedCatalog = <IlahiTrack>[...remote, ...local];
    return _cachedCatalog!;
  }

  Future<bool> _isCacheFresh() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ilahi_catalog_cache',
      where: 'id = 1',
    );
    if (rows.isEmpty) return false;
    final int fetchedAt = (rows.first['fetched_at'] as num?)?.toInt() ?? 0;
    return DateTime.now().difference(
          DateTime.fromMillisecondsSinceEpoch(fetchedAt),
        ) <
        AppConstants.remoteCatalogTtl;
  }

  Future<List<IlahiTrack>> _readCache() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ilahi_catalog_cache',
      where: 'id = 1',
    );
    if (rows.isEmpty) return <IlahiTrack>[];
    try {
      final Object? decoded = jsonDecode(rows.first['payload']! as String);
      if (decoded is! List) return <IlahiTrack>[];
      return decoded
          .whereType<Map<Object?, Object?>>()
          .map(
            (Map<Object?, Object?> m) =>
                IlahiTrack.fromJson(m.cast<String, Object?>()),
          )
          .toList();
    } catch (error) {
      AppLog.warning('İlahi önbelleği okunamadı', error: error);
      return <IlahiTrack>[];
    }
  }

  Future<void> _writeCache(List<IlahiTrack> tracks) async {
    await _database.raw.insert('ilahi_catalog_cache', <String, Object?>{
      'id': 1,
      'payload': jsonEncode(tracks.map((IlahiTrack t) => t.toJson()).toList()),
      'fetched_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<IlahiTrack>> _fetchRemote() async {
    try {
      final http.Response response = await _client
          .get(Uri.parse(catalogUrl!))
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) {
        AppLog.warning('İlahi kataloğu ${response.statusCode} döndü');
        return <IlahiTrack>[];
      }
      final Object? decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List<Object?> items = decoded is List
          ? decoded
          : ((decoded is Map ? decoded['tracks'] : null) as List?) ??
                <Object?>[];
      final List<IlahiTrack> tracks = items
          .whereType<Map<Object?, Object?>>()
          .map(
            (Map<Object?, Object?> m) =>
                IlahiTrack.fromJson(m.cast<String, Object?>()),
          )
          .where((IlahiTrack t) => t.audioUrl.isNotEmpty && t.id.isNotEmpty)
          .toList();
      AppLog.debug('İlahi kataloğu alındı: ${tracks.length} kayıt');
      return tracks;
    } catch (error) {
      AppLog.warning('İlahi kataloğu alınamadı', error: error);
      return <IlahiTrack>[];
    }
  }

  /// Cihaza indirilen ses dosyaları.
  Future<List<IlahiTrack>> downloaded({List<IlahiTrack>? fromCatalog}) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ilahi_downloads',
    );
    if (rows.isEmpty) return <IlahiTrack>[];
    final List<IlahiTrack> catalogTracks = fromCatalog ?? await catalog();
    final Map<String, IlahiTrack> byId = <String, IlahiTrack>{
      for (final IlahiTrack track in catalogTracks) track.id: track,
    };
    final List<IlahiTrack> result = <IlahiTrack>[];
    for (final Map<String, Object?> row in rows) {
      final String id = row['track_id']! as String;
      final IlahiTrack? track = byId[id];
      if (track == null) continue;
      if (!File(row['file_path']! as String).existsSync()) continue;
      result.add(
        track.copyWith(localPath: row['file_path'] as String?, isLocal: true),
      );
    }
    return result;
  }

  Future<Directory> _audioDirectory() async {
    final Directory base = await getApplicationSupportDirectory();
    final Directory dir = Directory(p.join(base.path, 'ilahi'));
    if (!dir.existsSync()) await dir.create(recursive: true);
    return dir;
  }

  /// İçeriği indirir ve yolunu döndürür.
  Future<String?> download(
    IlahiTrack track, {
    void Function(double progress)? onProgress,
  }) async {
    if (track.localPath != null && File(track.localPath!).existsSync()) {
      return track.localPath;
    }
    try {
      final Directory dir = await _audioDirectory();
      final String target = p.join(
        dir.path,
        '${track.id}.${track.fileExtension}',
      );
      final HttpClientRequest request = await HttpClient().getUrl(
        Uri.parse(track.audioUrl),
      );
      final HttpClientResponse response = await request.close();
      if (response.statusCode != 200) {
        AppLog.warning(
          'İndirme başarısız (${response.statusCode}): ${track.id}',
        );
        return null;
      }
      final int total = response.contentLength;
      final File file = File(target);
      final IOSink sink = file.openWrite();
      int received = 0;
      await for (final List<int> chunk in response) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0 && onProgress != null) onProgress(received / total);
      }
      await sink.flush();
      await sink.close();
      await _database.raw.insert('ilahi_downloads', <String, Object?>{
        'track_id': track.id,
        'file_path': target,
        'size_bytes': received,
        'downloaded_at': DateTime.now().millisecondsSinceEpoch,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      return target;
    } catch (error, stackTrace) {
      AppLog.error(
        'İndirme hatası: ${track.id}',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> deleteDownload(String trackId) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ilahi_downloads',
      where: 'track_id = ?',
      whereArgs: <Object?>[trackId],
    );
    for (final Map<String, Object?> row in rows) {
      final File file = File(row['file_path']! as String);
      if (file.existsSync()) {
        try {
          await file.delete();
        } catch (_) {}
      }
    }
    await _database.raw.delete(
      'ilahi_downloads',
      where: 'track_id = ?',
      whereArgs: <Object?>[trackId],
    );
  }

  // --------------------------------------------------- Yerel (içe aktarılan)

  Future<List<IlahiTrack>> localTracks() async {
    final Directory dir = await _audioDirectory();
    final Directory localDir = Directory(p.join(dir.path, 'local'));
    if (!localDir.existsSync()) return <IlahiTrack>[];
    final List<IlahiTrack> tracks = <IlahiTrack>[];
    for (final FileSystemEntity entity in localDir.listSync()) {
      if (entity is! File) continue;
      final String name = p.basenameWithoutExtension(entity.path);
      tracks.add(
        IlahiTrack(
          id: 'local_${p.basename(entity.path)}',
          title: name,
          artist: 'Cihazdan eklendi',
          kind: IlahiKind.diger,
          categories: const <String>['Yerel'],
          audioUrl: entity.path,
          license: 'Kullanıcı tarafından cihazdan eklendi',
          isLocal: true,
          localPath: entity.path,
        ),
      );
    }
    return tracks;
  }

  /// Cihazdan seçilen bir dosyayı uygulama kitaplığına kopyalar.
  Future<IlahiTrack?> importLocalFile(String sourcePath) async {
    try {
      final File source = File(sourcePath);
      if (!source.existsSync()) return null;
      final Directory dir = await _audioDirectory();
      final Directory localDir = Directory(p.join(dir.path, 'local'));
      if (!localDir.existsSync()) await localDir.create(recursive: true);
      final String target = p.join(localDir.path, p.basename(source.path));
      await source.copy(target);
      _cachedCatalog = null;
      return IlahiTrack(
        id: 'local_${p.basename(target)}',
        title: p.basenameWithoutExtension(target),
        artist: 'Cihazdan eklendi',
        kind: IlahiKind.diger,
        categories: const <String>['Yerel'],
        audioUrl: target,
        license: 'Kullanıcı tarafından cihazdan eklendi',
        isLocal: true,
        localPath: target,
      );
    } catch (error, stackTrace) {
      AppLog.error(
        'Yerel dosya eklenemedi',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  Future<void> deleteLocalTrack(String trackId) async {
    final List<IlahiTrack> locals = await localTracks();
    for (final IlahiTrack track in locals) {
      if (track.id == trackId && track.localPath != null) {
        final File file = File(track.localPath!);
        if (file.existsSync()) await file.delete();
      }
    }
    _cachedCatalog = null;
  }

  // ------------------------------------------------------------- Favoriler

  Future<Set<String>> favoriteIds() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ilahi_favorites',
    );
    return rows
        .map((Map<String, Object?> row) => row['track_id']! as String)
        .toSet();
  }

  Future<bool> toggleFavorite(String trackId) async {
    final bool exists = (await _database.raw.query(
      'ilahi_favorites',
      where: 'track_id = ?',
      whereArgs: <Object?>[trackId],
      limit: 1,
    )).isNotEmpty;
    if (exists) {
      await _database.raw.delete(
        'ilahi_favorites',
        where: 'track_id = ?',
        whereArgs: <Object?>[trackId],
      );
      return false;
    }
    await _database.raw.insert('ilahi_favorites', <String, Object?>{
      'track_id': trackId,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
    return true;
  }

  // --------------------------------------------------------- Son dinlenenler

  Future<void> markPlayed(String trackId) async {
    await _database.raw.insert('ilahi_recents', <String, Object?>{
      'track_id': trackId,
      'played_at': DateTime.now().millisecondsSinceEpoch,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<IlahiTrack>> recents({int limit = 20}) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ilahi_recents',
      orderBy: 'played_at DESC',
      limit: limit,
    );
    final List<IlahiTrack> all = await catalog();
    final Map<String, IlahiTrack> byId = <String, IlahiTrack>{
      for (final IlahiTrack track in all) track.id: track,
    };
    return rows
        .map((Map<String, Object?> row) => byId[row['track_id'] as String])
        .whereType<IlahiTrack>()
        .toList();
  }

  // ---------------------------------------------------------- Çalma listeleri

  Future<List<Playlist>> playlists() async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'playlists',
      orderBy: 'created_at DESC',
    );
    final List<Playlist> result = <Playlist>[];
    for (final Map<String, Object?> row in rows) {
      final int id = row['id']! as int;
      final List<Map<String, Object?>> items = await _database.raw.query(
        'playlist_items',
        where: 'playlist_id = ?',
        whereArgs: <Object?>[id],
        orderBy: 'position ASC',
      );
      result.add(
        Playlist(
          id: id,
          name: row['name']! as String,
          createdAt: DateTime.fromMillisecondsSinceEpoch(
            row['created_at']! as int,
          ),
          trackIds: items
              .map((Map<String, Object?> item) => item['track_id']! as String)
              .toList(),
        ),
      );
    }
    return result;
  }

  Future<int> createPlaylist(String name) =>
      _database.raw.insert('playlists', <String, Object?>{
        'name': name,
        'created_at': DateTime.now().millisecondsSinceEpoch,
      });

  Future<void> addToPlaylist(int playlistId, String trackId) async {
    final int position = (await _database.raw.query(
      'playlist_items',
      where: 'playlist_id = ?',
      whereArgs: <Object?>[playlistId],
    )).length;
    await _database.raw.insert('playlist_items', <String, Object?>{
      'playlist_id': playlistId,
      'track_id': trackId,
      'position': position,
    });
  }

  Future<void> removeFromPlaylist(int playlistId, String trackId) =>
      _database.raw.delete(
        'playlist_items',
        where: 'playlist_id = ? AND track_id = ?',
        whereArgs: <Object?>[playlistId, trackId],
      );

  Future<void> deletePlaylist(int playlistId) async {
    await _database.raw.delete(
      'playlist_items',
      where: 'playlist_id = ?',
      whereArgs: <Object?>[playlistId],
    );
    await _database.raw.delete(
      'playlists',
      where: 'id = ?',
      whereArgs: <Object?>[playlistId],
    );
  }

  /// Kategoriler ve sanatçılar (filtreleme için).
  Future<({List<String> categories, List<String> artists})> facets() async {
    final List<IlahiTrack> all = await catalog();
    final Set<String> categories = <String>{};
    final Set<String> artists = <String>{};
    for (final IlahiTrack track in all) {
      categories.addAll(track.categories);
      if (track.artist.isNotEmpty) artists.add(track.artist);
    }
    return (
      categories: categories.toList()..sort(),
      artists: artists.toList()..sort(),
    );
  }
}
