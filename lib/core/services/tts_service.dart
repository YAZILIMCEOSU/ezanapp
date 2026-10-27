import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../utils/logger.dart';

/// Sesli okuma başlatma sonucu.
enum TtsStart {
  /// Okuma başladı (veya cihaz motoru hazırlanıyor).
  started,

  /// Okunacak metin boş.
  empty,

  /// Platform sesli okumayı desteklemiyor.
  unsupported,

  /// Cihazın konuşma motoru kullanılamadı.
  failed,
}

/// **Hutbe ve duaların sesli okunması (TTS).**
///
/// Cihazın kendi konuşma motoru kullanılır (ek indirme yok, internet gerekmez).
/// Android tarafında `ezanai/tts` kanalı üzerinden Türkçe seslendirme yapılır.
///
/// Metin, konuşma motorlarının 4.000 karakter sınırına takılmaması için
/// [TtsText.chunk] ile parçalara bölünür; Arapça hat (Türkçe sesle bozuk
/// okunacağı için) varsayılan olarak metinden çıkarılır.
class TtsService {
  const TtsService();

  static const MethodChannel _channel = MethodChannel('ezanai/tts');

  /// Bu platformda sesli okuma destekleniyor mu?
  bool get isSupported => !kIsWeb && Platform.isAndroid;

  /// Metni sesli okur. Okuma sürüyorsa önce durdurup yenisini başlatır.
  Future<TtsStart> speak(String text, {double rate = 0.95}) async {
    if (!isSupported) return TtsStart.unsupported;
    final List<String> chunks = TtsText.chunk(text);
    if (chunks.isEmpty) return TtsStart.empty;
    try {
      final bool? ok = await _channel.invokeMethod<bool>('speak', <String, Object?>{
        'chunks': chunks,
        'rate': rate,
      });
      return ok == true ? TtsStart.started : TtsStart.failed;
    } on PlatformException catch (error) {
      AppLog.warning('Sesli okuma başlatılamadı: ${error.message}');
      return TtsStart.failed;
    } on MissingPluginException {
      return TtsStart.unsupported;
    }
  }

  Future<void> stop() async {
    if (!isSupported) return;
    try {
      await _channel.invokeMethod<bool>('stop');
    } on PlatformException catch (error) {
      AppLog.debug('Sesli okuma durdurulamadı: ${error.message}');
    } on MissingPluginException {
      // Test/masaüstü ortamı.
    }
  }

  Future<bool> isSpeaking() async {
    if (!isSupported) return false;
    try {
      final bool? speaking = await _channel.invokeMethod<bool>('isSpeaking');
      return speaking ?? false;
    } catch (_) {
      return false;
    }
  }
}

/// Sesli okuma metnini hazırlayan **saf** yardımcılar (birim testlerle doğrulanır).
abstract final class TtsText {
  /// Tek bir konuşma parçasının üst sınırı (Android TTS: 4000 karakter).
  static const int maxChunkChars = 2800;

  static final RegExp _arabic = RegExp(r'[\u0600-\u06FF\u0750-\u077F\uFB50-\uFDFF\uFE70-\uFEFF]');
  static final RegExp _spaces = RegExp(r'[ \t]+');
  static final RegExp _blankLines = RegExp(r'\n{3,}');
  static final RegExp _sentenceSplit = RegExp(r'(?<=[.!?:;])\s+|\n+');

  /// Metni konuşmaya hazırlar: Arapça hat çıkarılır, fazla boşluk toplanır.
  static String sanitize(String text, {bool stripArabic = true}) {
    String result = text;
    if (stripArabic) result = result.replaceAll(_arabic, ' ');
    result = result.replaceAll(_spaces, ' ').replaceAll(_blankLines, '\n\n');
    return result.trim();
  }

  /// Metni [maxChunkChars] sınırını aşmayan parçalara böler.
  ///
  /// Cümle sonlarından bölünür; tek bir cümle sınırı aşıyorsa kelime
  /// sınırından zorunlu bölme yapılır.
  static List<String> chunk(String text, {int maxChars = maxChunkChars}) {
    final String clean = sanitize(text);
    if (clean.isEmpty) return const <String>[];
    if (clean.length <= maxChars) return <String>[clean];

    final List<String> chunks = <String>[];
    final StringBuffer buffer = StringBuffer();

    void flush() {
      final String value = buffer.toString().trim();
      if (value.isNotEmpty) chunks.add(value);
      buffer.clear();
    }

    for (final String sentence in clean.split(_sentenceSplit)) {
      final String part = sentence.trim();
      if (part.isEmpty) continue;
      if (part.length > maxChars) {
        flush();
        chunks.addAll(_hardSplit(part, maxChars));
        continue;
      }
      if (buffer.length + part.length + 1 > maxChars) flush();
      if (buffer.isNotEmpty) buffer.write(' ');
      buffer.write(part);
    }
    flush();
    return List<String>.unmodifiable(chunks);
  }

  static List<String> _hardSplit(String text, int maxChars) {
    final List<String> result = <String>[];
    final List<String> words = text.split(' ');
    final StringBuffer current = StringBuffer();
    for (final String word in words) {
      if (word.isEmpty) continue;
      if (current.length + word.length + 1 > maxChars && current.isNotEmpty) {
        result.add(current.toString().trim());
        current.clear();
      }
      if (current.isNotEmpty) current.write(' ');
      current.write(word);
    }
    final String tail = current.toString().trim();
    if (tail.isNotEmpty) result.add(tail);
    return result;
  }
}
