import 'dart:convert';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/app_config.dart';
import '../db/app_database.dart';
import '../utils/logger.dart';
import 'preferences_service.dart';

/// Premium bulut yedekleme servisi (Supabase).
///
/// Supabase yapılandırılmadıysa (`SUPABASE_URL` / `SUPABASE_ANON_KEY` yok)
/// servis devre dışı kalır ve uygulama tamamen yerel çalışmaya devam eder.
/// Kimlik doğrulama anonim oturumla yapılır: kullanıcıdan e-posta veya
/// kişisel veri istenmez.
class SyncService {
  SyncService(this._database, this._preferences);

  final AppDatabase _database;
  final PreferencesService _preferences;

  static bool _supabaseReady = false;

  bool _initialized = false;
  bool _available = false;
  String? _lastError;
  String? _userId;

  bool get isConfigured => AppConfig.hasSupabase;
  bool get isAvailable => _available;
  String? get lastError => _lastError;
  String? get userId => _userId;

  /// Yedeklenen tablolar (sıra: bağımlılıklar önce).
  static const List<String> backedUpTables = <String>[
    'quran_bookmarks',
    'reading_progress',
    'hadith_favorites',
    'zikir_daily',
    'zikir_sessions',
    'zikir_custom',
    'ilahi_favorites',
    'ilahi_recents',
    'playlists',
    'playlist_items',
    'hatim_progress',
    'kaza_fasts',
    'ramadan_log',
    'ai_conversations',
    'ai_messages',
  ];

  Future<bool> initialize() async {
    if (_initialized) return _available;
    _initialized = true;

    if (!isConfigured) {
      _lastError = 'Bulut yedekleme yapılandırılmadı.';
      return false;
    }

    try {
      if (!_supabaseReady) {
        await Supabase.initialize(
          url: AppConfig.supabaseUrl,
          anonKey: AppConfig.supabaseAnonKey,
        );
        _supabaseReady = true;
      }
      final Session? session = Supabase.instance.client.auth.currentSession;
      _userId = session?.user.id;
      _available = true;
      return true;
    } catch (error) {
      _lastError = 'Bulut bağlantısı kurulamadı: $error';
      AppLog.warning(_lastError!);
      _available = false;
      return false;
    }
  }

  /// Anonim oturum açar (yoksa) ve kullanıcı kimliğini döner.
  Future<String?> ensureSession() async {
    if (!await initialize()) return null;
    try {
      final SupabaseClient client = Supabase.instance.client;
      final User? current = client.auth.currentUser;
      if (current != null) {
        _userId = current.id;
        return _userId;
      }
      final AuthResponse response = await client.auth.signInAnonymously();
      _userId = response.user?.id;
      return _userId;
    } catch (error) {
      _lastError = 'Oturum açılamadı: $error';
      AppLog.warning(_lastError!);
      return null;
    }
  }

  DateTime? get lastBackupAt {
    final String? raw = _preferences.getString('last_backup_at');
    if (raw == null) return null;
    return DateTime.tryParse(raw);
  }

  /// Yerel verileri JSON paketine dönüştürür.
  Future<Map<String, Object?>> exportPayload() async {
    final Map<String, Object?> payload = <String, Object?>{};
    for (final String table in backedUpTables) {
      try {
        final List<Map<String, Object?>> rows = await _database.raw.query(
          table,
        );
        payload[table] = rows;
      } catch (error) {
        AppLog.warning('Tablo okunamadı ($table): $error');
        payload[table] = const <Map<String, Object?>>[];
      }
    }
    payload['schema'] = AppDatabase.schemaVersion;
    payload['exported_at'] = DateTime.now().toIso8601String();
    return payload;
  }

  /// Yedeği sunucuya yükler.
  Future<bool> uploadBackup() async {
    final String? userId = await ensureSession();
    if (userId == null) return false;
    try {
      final Map<String, Object?> payload = await exportPayload();
      await Supabase.instance.client.from('user_data').upsert(<String, Object?>{
        'user_id': userId,
        'payload': payload,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      });
      await _preferences.setString(
        'last_backup_at',
        DateTime.now().toIso8601String(),
      );
      return true;
    } catch (error) {
      _lastError = 'Yedek yüklenemedi: $error';
      AppLog.warning(_lastError!);
      return false;
    }
  }

  /// Sunucudaki yedeği indirir (uygulamaz).
  Future<Map<String, Object?>?> downloadBackup() async {
    final String? userId = await ensureSession();
    if (userId == null) return null;
    try {
      final List<Map<String, dynamic>> rows = await Supabase.instance.client
          .from('user_data')
          .select('payload, updated_at')
          .eq('user_id', userId)
          .limit(1);
      if (rows.isEmpty) {
        _lastError = 'Sunucuda kayıtlı yedek bulunamadı.';
        return null;
      }
      final Object? payload = rows.first['payload'];
      if (payload is Map) {
        return payload.cast<String, Object?>();
      }
      if (payload is String) {
        final Object? decoded = jsonDecode(payload);
        if (decoded is Map) return decoded.cast<String, Object?>();
      }
      _lastError = 'Yedek biçimi okunamadı.';
      return null;
    } catch (error) {
      _lastError = 'Yedek indirilemedi: $error';
      AppLog.warning(_lastError!);
      return null;
    }
  }

  /// İndirilen yedeği yerel veritabanına uygular.
  ///
  /// Mevcut kullanıcı verileri yedekteki hâliyle değiştirilir.
  Future<int> restoreBackup(Map<String, Object?> payload) async {
    int restored = 0;
    for (final String table in backedUpTables) {
      final Object? raw = payload[table];
      if (raw is! List) continue;
      try {
        await _database.raw.delete(table);
        for (final Object? item in raw) {
          if (item is Map) {
            await _database.raw.insert(
              table,
              item.map(
                (Object? key, Object? value) =>
                    MapEntry<String, Object?>('$key', value),
              ),
            );
            restored++;
          }
        }
      } catch (error) {
        AppLog.warning('Tablo geri yüklenemedi ($table): $error');
      }
    }
    return restored;
  }

  Future<void> signOut() async {
    if (!_available) return;
    try {
      await Supabase.instance.client.auth.signOut();
      _userId = null;
    } catch (error) {
      AppLog.warning('Oturum kapatılamadı: $error');
    }
  }
}
