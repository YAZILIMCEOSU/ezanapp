import 'dart:async';

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import '../utils/logger.dart';

/// Uygulamanın yerel SQLite veritabanı.
///
/// Tüm kullanıcı verileri (favoriler, ilerleme, zikir kayıtları, indirilen
/// içerikler, AI geçmişi) burada tutulur; çevrimdışı çalışmanın temelidir.
class AppDatabase {
  AppDatabase._(this._db);

  final Database _db;

  static const int schemaVersion = 1;
  static const String fileName = 'ezanai.db';

  static AppDatabase? _instance;

  static Future<AppDatabase> open({String? path, DatabaseFactory? factory}) async {
    if (_instance != null && path == null) return _instance!;
    final DatabaseFactory dbFactory = factory ?? databaseFactory;
    final String dbPath = path ?? p.join(await dbFactory.getDatabasesPath(), fileName);
    final Database database = await dbFactory.openDatabase(
      dbPath,
      options: OpenDatabaseOptions(
        version: schemaVersion,
        onConfigure: (Database db) async {
          await db.execute('PRAGMA foreign_keys = ON');
        },
        onCreate: (Database db, int version) async {
          await _createSchema(db);
        },
        onUpgrade: (Database db, int oldVersion, int newVersion) async {
          // İleride şema değişiklikleri buraya eklenecek.
          AppLog.info('Veritabanı yükseltildi: $oldVersion → $newVersion');
        },
        onOpen: (Database db) async {
          await db.execute('PRAGMA journal_mode = WAL');
        },
      ),
    );
    final AppDatabase instance = AppDatabase._(database);
    if (path == null) _instance = instance;
    return instance;
  }

  static Future<void> _createSchema(Database db) async {
    const List<String> statements = <String>[
      '''
      CREATE TABLE prayer_times_cache (
        district_id TEXT NOT NULL,
        date TEXT NOT NULL,
        imsak TEXT NOT NULL,
        gunes TEXT NOT NULL,
        ogle TEXT NOT NULL,
        ikindi TEXT NOT NULL,
        aksam TEXT NOT NULL,
        yatsi TEXT NOT NULL,
        source TEXT NOT NULL,
        hijri TEXT,
        fetched_at INTEGER NOT NULL,
        PRIMARY KEY (district_id, date)
      )
      ''',
      'CREATE INDEX idx_prayer_cache_date ON prayer_times_cache(date)',
      '''
      CREATE TABLE quran_bookmarks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        surah INTEGER NOT NULL,
        ayah INTEGER NOT NULL,
        note TEXT,
        color TEXT,
        created_at INTEGER NOT NULL,
        UNIQUE(surah, ayah)
      )
      ''',
      '''
      CREATE TABLE reading_progress (
        surah INTEGER PRIMARY KEY,
        last_ayah INTEGER NOT NULL,
        read_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE quran_daily (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        surah INTEGER NOT NULL,
        ayah INTEGER NOT NULL,
        completed INTEGER NOT NULL DEFAULT 0,
        UNIQUE(date)
      )
      ''',
      '''
      CREATE TABLE hadith_favorites (
        hadith_id INTEGER PRIMARY KEY,
        collection TEXT NOT NULL DEFAULT 'riyazus_salihin',
        created_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE zikir_sessions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        zikir_key TEXT NOT NULL,
        target INTEGER NOT NULL,
        count INTEGER NOT NULL,
        started_at INTEGER NOT NULL,
        finished_at INTEGER
      )
      ''',
      '''
      CREATE TABLE zikir_custom (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT NOT NULL UNIQUE,
        name TEXT NOT NULL,
        arabic TEXT,
        transliteration TEXT,
        meaning TEXT,
        default_target INTEGER NOT NULL DEFAULT 33,
        created_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE zikir_daily (
        date TEXT NOT NULL,
        zikir_key TEXT NOT NULL,
        count INTEGER NOT NULL DEFAULT 0,
        PRIMARY KEY (date, zikir_key)
      )
      ''',
      '''
      CREATE TABLE ilahi_favorites (
        track_id TEXT PRIMARY KEY,
        created_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE ilahi_recents (
        track_id TEXT PRIMARY KEY,
        played_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE ilahi_downloads (
        track_id TEXT PRIMARY KEY,
        file_path TEXT NOT NULL,
        size_bytes INTEGER NOT NULL DEFAULT 0,
        downloaded_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE quran_audio_downloads (
        surah INTEGER NOT NULL,
        reciter TEXT NOT NULL,
        file_path TEXT NOT NULL,
        size_bytes INTEGER NOT NULL DEFAULT 0,
        downloaded_at INTEGER NOT NULL,
        PRIMARY KEY (surah, reciter)
      )
      ''',
      '''
      CREATE TABLE playlists (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        created_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE playlist_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        playlist_id INTEGER NOT NULL REFERENCES playlists(id) ON DELETE CASCADE,
        track_id TEXT NOT NULL,
        position INTEGER NOT NULL DEFAULT 0
      )
      ''',
      '''
      CREATE TABLE ai_conversations (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE ai_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        conversation_id TEXT NOT NULL REFERENCES ai_conversations(id) ON DELETE CASCADE,
        role TEXT NOT NULL,
        content TEXT NOT NULL,
        citations TEXT,
        created_at INTEGER NOT NULL
      )
      ''',
      'CREATE INDEX idx_ai_messages_conversation ON ai_messages(conversation_id, created_at)',
      '''
      CREATE TABLE ai_usage (
        date TEXT PRIMARY KEY,
        message_count INTEGER NOT NULL DEFAULT 0
      )
      ''',
      '''
      CREATE TABLE hatim_progress (
        juz INTEGER PRIMARY KEY,
        status TEXT NOT NULL DEFAULT 'pending',
        surah INTEGER,
        ayah INTEGER,
        updated_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE kaza_fasts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        due_date TEXT,
        note TEXT,
        completed INTEGER NOT NULL DEFAULT 0,
        completed_at INTEGER
      )
      ''',
      '''
      CREATE TABLE ramadan_log (
        date TEXT PRIMARY KEY,
        fasted INTEGER NOT NULL DEFAULT 0,
        tarawih INTEGER NOT NULL DEFAULT 0,
        quran_pages INTEGER NOT NULL DEFAULT 0,
        note TEXT
      )
      ''',
      '''
      CREATE TABLE daily_content_cache (
        date TEXT PRIMARY KEY,
        verse TEXT,
        hadith TEXT,
        dua TEXT,
        fetched_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE ilahi_catalog_cache (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        payload TEXT NOT NULL,
        fetched_at INTEGER NOT NULL
      )
      ''',
      '''
      CREATE TABLE app_events (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        payload TEXT,
        created_at INTEGER NOT NULL
      )
      ''',
    ];
    for (final String statement in statements) {
      await db.execute(statement);
    }
    AppLog.info('Veritabanı şeması oluşturuldu (v$schemaVersion)');
  }

  Database get raw => _db;

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) =>
      _db.transaction<T>(action);

  Future<int> count(String table) async {
    final List<Map<String, Object?>> rows = await _db.rawQuery('SELECT COUNT(*) AS c FROM $table');
    return (rows.first['c'] as int?) ?? 0;
  }

  /// Kullanıcı hesabını sıfırlarken yerel verileri temizler.
  Future<void> clearUserData() async {
    const List<String> tables = <String>[
      'quran_bookmarks',
      'reading_progress',
      'hadith_favorites',
      'zikir_sessions',
      'zikir_daily',
      'ilahi_favorites',
      'ilahi_recents',
      'playlists',
      'playlist_items',
      'ai_conversations',
      'ai_messages',
      'hatim_progress',
      'kaza_fasts',
      'ramadan_log',
    ];
    for (final String table in tables) {
      await _db.delete(table);
    }
  }

  Future<void> close() async {
    await _db.close();
    _instance = null;
  }
}
