import 'package:flutter/foundation.dart';

/// İlahi/dini ses içeriği türü.
enum IlahiKind {
  ilahi('İlahi'),
  kaside('Kaside'),
  salavat('Salavât'),
  sure('Kur\'an Tilaveti'),
  hutbe('Hutbe'),
  ezan('Ezan'),
  diger('Diğer');

  const IlahiKind(this.label);

  final String label;

  static IlahiKind fromName(String? name) =>
      IlahiKind.values.firstWhere((IlahiKind k) => k.name == name,
          orElse: () => IlahiKind.diger);
}

/// Katalogdaki tek bir ses kaydı.
@immutable
class IlahiTrack {
  const IlahiTrack({
    required this.id,
    required this.title,
    required this.artist,
    required this.kind,
    required this.categories,
    required this.audioUrl,
    this.album,
    this.durationSeconds = 0,
    this.artUri,
    this.license = '',
    this.sourceUrl = '',
    this.description = '',
    this.isLocal = false,
    this.localPath,
  });

  final String id;
  final String title;
  final String artist;
  final IlahiKind kind;
  final List<String> categories;
  final String audioUrl;
  final String? album;
  final int durationSeconds;
  final String? artUri;

  /// Lisans/izin bilgisi — telifli içerik yalnızca izinliyse listelenir.
  final String license;
  final String sourceUrl;
  final String description;

  /// Cihaza içe aktarılmış yerel dosya mı?
  final bool isLocal;
  final String? localPath;

  Duration get duration => Duration(seconds: durationSeconds);

  bool get hasLicenseInfo => license.isNotEmpty;

  /// Dosya adı tabanlı kimlik (indirme/önbellek için).
  String get fileExtension {
    final int dot = audioUrl.lastIndexOf('.');
    if (dot == -1 || dot == audioUrl.length - 1) return 'mp3';
    return audioUrl.substring(dot + 1).split('?').first;
  }

  factory IlahiTrack.fromJson(Map<String, Object?> json) => IlahiTrack(
        id: json['id']?.toString() ?? '',
        title: json['title'] as String? ?? '',
        artist: json['artist'] as String? ?? '',
        kind: IlahiKind.fromName(json['kind'] as String?),
        categories: (json['categories'] as List<Object?>?)?.cast<String>() ??
            const <String>[],
        audioUrl: json['audioUrl'] as String? ?? json['url'] as String? ?? '',
        album: json['album'] as String?,
        durationSeconds: (json['duration'] as num?)?.toInt() ?? 0,
        artUri: json['artUri'] as String?,
        license: json['license'] as String? ?? '',
        sourceUrl: json['sourceUrl'] as String? ?? '',
        description: json['description'] as String? ?? '',
        isLocal: json['isLocal'] as bool? ?? false,
        localPath: json['localPath'] as String?,
      );

  Map<String, Object?> toJson() => <String, Object?>{
        'id': id,
        'title': title,
        'artist': artist,
        'kind': kind.name,
        'categories': categories,
        'audioUrl': audioUrl,
        'album': album,
        'duration': durationSeconds,
        'artUri': artUri,
        'license': license,
        'sourceUrl': sourceUrl,
        'description': description,
        'isLocal': isLocal,
        'localPath': localPath,
      };

  IlahiTrack copyWith({String? localPath, bool? isLocal}) => IlahiTrack(
        id: id,
        title: title,
        artist: artist,
        kind: kind,
        categories: categories,
        audioUrl: audioUrl,
        album: album,
        durationSeconds: durationSeconds,
        artUri: artUri,
        license: license,
        sourceUrl: sourceUrl,
        description: description,
        isLocal: isLocal ?? this.isLocal,
        localPath: localPath ?? this.localPath,
      );
}

/// Çalma listesi.
@immutable
class Playlist {
  const Playlist(
      {required this.id,
      required this.name,
      required this.trackIds,
      required this.createdAt});

  final int id;
  final String name;
  final List<String> trackIds;
  final DateTime createdAt;

  int get count => trackIds.length;
}

/// İndirilen içerik kaydı.
@immutable
class DownloadedTrack {
  const DownloadedTrack({
    required this.trackId,
    required this.filePath,
    required this.sizeBytes,
    required this.downloadedAt,
  });

  final String trackId;
  final String filePath;
  final int sizeBytes;
  final DateTime downloadedAt;

  factory DownloadedTrack.fromRow(Map<String, Object?> row) => DownloadedTrack(
        trackId: row['track_id']! as String,
        filePath: row['file_path']! as String,
        sizeBytes: (row['size_bytes'] as num?)?.toInt() ?? 0,
        downloadedAt:
            DateTime.fromMillisecondsSinceEpoch(row['downloaded_at']! as int),
      );
}
