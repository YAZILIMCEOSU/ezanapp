import 'package:flutter/material.dart';

/// Ezan Vaktim Pro renk paleti.
///
/// Kimlik: e-Diyanet & Ezan Vakti Pro çizgisinde ferah Turkuvaz + Beyaz kartlar + Mercan/Altın vurgu.
abstract final class AppColors {
  // Marka renkleri (Turkuvaz / Diyanet Turkuvaz-Yeşil ailesi)
  static const Color emerald900 = Color(0xFF004D56);
  static const Color emerald800 = Color(0xFF006064);
  static const Color emerald700 = Color(0xFF00796B);
  static const Color emerald600 = Color(0xFF00838F);
  static const Color emerald500 = Color(0xFF0097A7);
  static const Color emerald300 = Color(0xFF4DD0E1);
  static const Color emerald100 = Color(0xFFE0F7FA);

  static const Color gold600 = Color(0xFFB98A34);
  static const Color gold500 = Color(0xFFD4A64A);
  static const Color gold400 = Color(0xFFE2BA6A);
  static const Color gold200 = Color(0xFFF3E0B5);
  static const Color coral500 = Color(0xFFFF7043);
  static const Color coral100 = Color(0xFFFBE9E7);

  static const Color cream = Color(0xFFF4F8FB);
  static const Color parchment = Color(0xFFFFFFFF);
  static const Color ink = Color(0xFF152930);
  static const Color inkSoft = Color(0xFF455A64);

  // Durum renkleri
  static const Color success = Color(0xFF26A69A);
  static const Color warning = Color(0xFFE0A029);
  static const Color danger = Color(0xFFD65A4A);
  static const Color info = Color(0xFF00ACC1);

  // Vakit renkleri (her vakit için ayrı kimlik)
  static const Color imsak = Color(0xFF4A5F86);
  static const Color gunes = Color(0xFFD98F3C);
  static const Color ogle = Color(0xFFE0B33C);
  static const Color ikindi = Color(0xFFC97B4A);
  static const Color aksam = Color(0xFF9A5B7A);
  static const Color yatsi = Color(0xFF41507E);

  // Açık tema (Ferah Beyaz & Buz Mavisi/Turkuvaz)
  static const Color lightBackground = Color(0xFFF3F7FA);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFEBF4F8);
  static const Color lightOutline = Color(0xFFDCE7EE);

  // Koyu tema
  static const Color darkBackground = Color(0xFF071418);
  static const Color darkSurface = Color(0xFF0D2126);
  static const Color darkSurfaceVariant = Color(0xFF132D33);
  static const Color darkOutline = Color(0xFF1E424A);

  // AMOLED tema (saf siyah)
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF0A1214);
  static const Color amoledSurfaceVariant = Color(0xFF122024);
  static const Color amoledOutline = Color(0xFF1E3238);

  static const List<Color> emeraldGradient = <Color>[
    Color(0xFF00838F),
    Color(0xFF0097A7),
  ];
  static const List<Color> goldGradient = <Color>[gold400, gold600];
  static const List<Color> nightGradient = <Color>[
    Color(0xFF0B1F2A),
    Color(0xFF08130F),
  ];
  static const List<Color> dawnGradient = <Color>[
    Color(0xFF37476F),
    Color(0xFF8A5E7D),
  ];
  static const List<Color> duskGradient = <Color>[
    Color(0xFF9A5B7A),
    Color(0xFF2E2A46),
  ];
}
