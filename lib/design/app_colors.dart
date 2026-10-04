import 'package:flutter/material.dart';

/// EzanAI renk paleti.
///
/// Kimlik: derin zümrüt yeşili + sıcak altın + kırık beyaz (parşömen).
/// Klişe olmayan, premium bir İslami estetik hedefler.
abstract final class AppColors {
  // Marka renkleri
  static const Color emerald900 = Color(0xFF06231F);
  static const Color emerald800 = Color(0xFF0A322B);
  static const Color emerald700 = Color(0xFF0E4A3F);
  static const Color emerald600 = Color(0xFF146A57);
  static const Color emerald500 = Color(0xFF1B8A6B);
  static const Color emerald300 = Color(0xFF6EC1A2);
  static const Color emerald100 = Color(0xFFD7EDE3);

  static const Color gold600 = Color(0xFFB98A34);
  static const Color gold500 = Color(0xFFD4A64A);
  static const Color gold400 = Color(0xFFE2BA6A);
  static const Color gold200 = Color(0xFFF3E0B5);

  static const Color cream = Color(0xFFF7F3E9);
  static const Color parchment = Color(0xFFFBF8F1);
  static const Color ink = Color(0xFF10201C);
  static const Color inkSoft = Color(0xFF3C4A46);

  // Durum renkleri
  static const Color success = Color(0xFF2E9E6B);
  static const Color warning = Color(0xFFE0A029);
  static const Color danger = Color(0xFFD65A4A);
  static const Color info = Color(0xFF3B82A8);

  // Vakit renkleri (her vakit için ayrı kimlik)
  static const Color imsak = Color(0xFF4A5F86);
  static const Color gunes = Color(0xFFD98F3C);
  static const Color ogle = Color(0xFFE0B33C);
  static const Color ikindi = Color(0xFFC97B4A);
  static const Color aksam = Color(0xFF9A5B7A);
  static const Color yatsi = Color(0xFF41507E);

  // Açık tema
  static const Color lightBackground = Color(0xFFF6F7F4);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEDF2EE);
  static const Color lightOutline = Color(0xFFD5DED8);

  // Koyu tema
  static const Color darkBackground = Color(0xFF08130F);
  static const Color darkSurface = Color(0xFF0E1E19);
  static const Color darkSurfaceVariant = Color(0xFF16302A);
  static const Color darkOutline = Color(0xFF24413A);

  // AMOLED tema (saf siyah)
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A0F0D);
  static const Color amoledSurfaceVariant = Color(0xFF131A17);
  static const Color amoledOutline = Color(0xFF1F2A25);

  static const List<Color> emeraldGradient = <Color>[emerald700, emerald900];
  static const List<Color> goldGradient = <Color>[gold400, gold600];
  static const List<Color> nightGradient = <Color>[Color(0xFF0B1F2A), Color(0xFF08130F)];
  static const List<Color> dawnGradient = <Color>[Color(0xFF37476F), Color(0xFF8A5E7D)];
  static const List<Color> duskGradient = <Color>[Color(0xFF9A5B7A), Color(0xFF2E2A46)];
}
