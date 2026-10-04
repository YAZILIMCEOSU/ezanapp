import 'dart:convert';

import '../../core/db/app_database.dart';
import '../../core/utils/logger.dart';
import '../ai/ai_service.dart';
import '../models/ai_models.dart';

/// Günlük ücretsiz soru limiti (premium kullanıcılar sınırsız).
const int kFreeDailyAiLimit = 10;

/// Sohbet geçmişinin saklandığı satır.
class AiStoredMessage {
  const AiStoredMessage({required this.role, required this.content, required this.createdAt});

  final String role;
  final String content;
  final DateTime createdAt;

  bool get fromUser => role == 'user';
}

/// AI asistan deposu: sohbet geçmişi, günlük kota ve cevap üretimi.
class AiRepository {
  AiRepository(this._database, {AiService? service}) : _service = service ?? AiService();

  final AppDatabase _database;
  final AiService _service;

  // ------------------------------------------------------------ Sohbetler

  Future<String> createConversation([String? title]) async {
    final String id = 'c${DateTime.now().microsecondsSinceEpoch}';
    final int now = DateTime.now().millisecondsSinceEpoch;
    await _database.raw.insert('ai_conversations', <String, Object?>{
      'id': id,
      'title': title?.trim().isNotEmpty == true ? title!.trim() : 'Yeni sohbet',
      'created_at': now,
      'updated_at': now,
    });
    return id;
  }

  Future<List<AiConversation>> conversations({int limit = 40}) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ai_conversations',
      orderBy: 'updated_at DESC',
      limit: limit,
    );
    return rows
        .map(
          (Map<String, Object?> row) => AiConversation(
            id: row['id']! as String,
            title: (row['title'] as String?) ?? 'Sohbet',
            messages: const <AiMessage>[],
            updatedAt: DateTime.fromMillisecondsSinceEpoch(row['updated_at']! as int),
          ),
        )
        .toList();
  }

  Future<void> renameConversation(String conversationId, String title) async {
    await _database.raw.update(
      'ai_conversations',
      <String, Object?>{'title': title.trim(), 'updated_at': DateTime.now().millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: <Object?>[conversationId],
    );
  }

  Future<void> deleteConversation(String conversationId) async {
    await _database.raw.delete('ai_messages', where: 'conversation_id = ?', whereArgs: <Object?>[conversationId]);
    await _database.raw.delete('ai_conversations', where: 'id = ?', whereArgs: <Object?>[conversationId]);
  }

  Future<void> clearAllConversations() async {
    await _database.raw.delete('ai_messages');
    await _database.raw.delete('ai_conversations');
  }

  Future<List<AiMessage>> messages(String conversationId) async {
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ai_messages',
      where: 'conversation_id = ?',
      whereArgs: <Object?>[conversationId],
      orderBy: 'created_at ASC, id ASC',
    );
    return rows.map(_messageFromRow).toList();
  }

  AiMessage _messageFromRow(Map<String, Object?> row) {
    final List<AiSource> sources = <AiSource>[];
    final Object? citations = row['citations'];
    if (citations is String && citations.trim().isNotEmpty) {
      try {
        final Object? decoded = jsonDecode(citations);
        if (decoded is List) {
          for (final Object? item in decoded) {
            if (item is Map) {
              sources.add(AiSource.fromJson(item.map((Object? k, Object? v) => MapEntry<String, Object?>(k.toString(), v))));
            }
          }
        }
      } catch (error) {
        AppLogger.warn('Kaynak künyesi okunamadı: $error');
      }
    }

    final String role = (row['role'] as String?) ?? 'assistant';
    return AiMessage(
      id: '${row['id']}',
      text: (row['content'] as String?) ?? '',
      fromUser: role == 'user',
      createdAt: DateTime.fromMillisecondsSinceEpoch(row['created_at']! as int),
      sources: sources,
    );
  }

  Future<void> appendMessage(String conversationId, AiMessage message) async {
    await _database.raw.insert('ai_messages', <String, Object?>{
      'conversation_id': conversationId,
      'role': message.fromUser ? 'user' : 'assistant',
      'content': message.text,
      'citations': message.sources.isEmpty ? null : jsonEncode(message.sources.map((AiSource s) => s.toJson()).toList()),
      'created_at': message.createdAt.millisecondsSinceEpoch,
    });
    await _database.raw.update(
      'ai_conversations',
      <String, Object?>{'updated_at': message.createdAt.millisecondsSinceEpoch},
      where: 'id = ?',
      whereArgs: <Object?>[conversationId],
    );
  }

  // ---------------------------------------------------------------- Kota

  /// Bugünkü kullanım sayısı.
  Future<int> todayUsage() async {
    final String key = _todayKey();
    final List<Map<String, Object?>> rows = await _database.raw.query(
      'ai_usage',
      where: 'date = ?',
      whereArgs: <Object?>[key],
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return (rows.first['message_count'] as int?) ?? 0;
  }

  Future<int> incrementUsage() async {
    final String key = _todayKey();
    await _database.raw.rawInsert(
      'INSERT INTO ai_usage (date, message_count) VALUES (?, 1) '
      'ON CONFLICT(date) DO UPDATE SET message_count = message_count + 1',
      <Object?>[key],
    );
    return todayUsage();
  }

  String _todayKey() {
    final DateTime now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  /// Soru sorma hakkı var mı?
  Future<bool> canAsk({required bool premium}) async {
    if (premium) return true;
    return await todayUsage() < kFreeDailyAiLimit;
  }

  // ------------------------------------------------------------- Soru-cevap

  /// Soru sorar; cevabı üretir. Kayıt işlemi çağıran katmana aittir.
  Future<AiAnswer> ask(String question, {List<AiMessage> history = const <AiMessage>[]}) =>
      _service.ask(question, history: history);

  void dispose() => _service.dispose();
}
