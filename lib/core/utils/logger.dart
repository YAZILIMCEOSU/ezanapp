import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Basit, üretim dostu günlükleyici.
///
/// Yayın derlemesinde yalnızca hata seviyesi kaydedilir; gizli veri
/// (konum, kullanıcı metni) asla günlüğe yazılmaz.
abstract final class AppLog {
  static const bool _verbose = kDebugMode;

  static void debug(String message, {String name = 'ezanai'}) {
    if (_verbose) developer.log(message, name: 'debug/$name');
  }

  static void info(String message, {String name = 'ezanai'}) {
    developer.log(message, name: 'info/$name');
  }

  static void warning(String message, {Object? error, String name = 'ezanai'}) {
    developer.log(message, name: 'warn/$name', error: error);
  }

  static void error(String message,
      {Object? error, StackTrace? stackTrace, String name = 'ezanai'}) {
    developer.log(message,
        name: 'error/$name', error: error, stackTrace: stackTrace);
  }
}
