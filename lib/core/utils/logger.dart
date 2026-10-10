import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// Üretim dostu, gizlilik korumalı günlükleyici.
///
/// Yayın derlemesinde yalnızca hata/uyarı seviyesi kaydedilir; kişisel veriler
/// (e-posta, belirteç/anahtar) ve hassas GPS koordinatları günlüğe yazılmadan
/// önce otomatik olarak maskelenir.
abstract final class AppLog {
  static const bool _verbose = kDebugMode;

  static final RegExp _emailPattern = RegExp(
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
  );
  static final RegExp _coordPairPattern = RegExp(
    r'(-?\d{1,2}\.\d{3,})\s*[,;/]\s*(-?\d{1,3}\.\d{3,})',
  );
  static final RegExp _latLonQueryPattern = RegExp(
    r'(latitude|longitude|lat|lon|lng)=([+-]?\d+\.\d{3,})',
    caseSensitive: false,
  );
  static final RegExp _tokenPattern = RegExp(
    r'(Bearer\s+[A-Za-z0-9\-._~+/]+=*|eyJ[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+\.[A-Za-z0-9\-_]+)',
  );

  /// Mesaj içindeki kişisel verileri ve hassas koordinatları maskeler.
  static String sanitize(String message) {
    String out = message;
    out = out.replaceAll(_emailPattern, '[e-posta-gizlendi]');
    out = out.replaceAll(_tokenPattern, '[anahtar-gizlendi]');
    out = out.replaceAllMapped(
      _latLonQueryPattern,
      (Match m) => '${m.group(1)}=[konum-gizlendi]',
    );
    out = out.replaceAll(_coordPairPattern, '[konum-gizlendi]');
    return out;
  }

  static void debug(String message, {String name = 'ezanai'}) {
    if (_verbose) developer.log(sanitize(message), name: 'debug/$name');
  }

  static void info(String message, {String name = 'ezanai'}) {
    if (_verbose) developer.log(sanitize(message), name: 'info/$name');
  }

  static void warning(String message, {Object? error, String name = 'ezanai'}) {
    developer.log(
      sanitize(message),
      name: 'warn/$name',
      error: error == null ? null : sanitize(error.toString()),
    );
  }

  static void error(
    String message, {
    Object? error,
    StackTrace? stackTrace,
    String name = 'ezanai',
  }) {
    developer.log(
      sanitize(message),
      name: 'error/$name',
      error: error == null ? null : sanitize(error.toString()),
      stackTrace: stackTrace,
    );
  }
}
