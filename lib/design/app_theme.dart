import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Uygulama tema modu.
enum AppThemeMode {
  system('Sistem', Icons.brightness_auto_rounded),
  light('Açık', Icons.light_mode_rounded),
  dark('Koyu', Icons.dark_mode_rounded),
  amoled('AMOLED', Icons.contrast_rounded);

  const AppThemeMode(this.label, this.icon);

  final String label;
  final IconData icon;
}

/// Tema üreticisi: açık, koyu ve AMOLED varyantları.
abstract final class AppTheme {
  static const String _fontFamily = 'PlusJakartaSans';
  static const String arabicFontFamily = 'Amiri';

  static ThemeData light() => _build(
        brightness: Brightness.light,
        background: AppColors.lightBackground,
        surface: AppColors.lightSurface,
        surfaceVariant: AppColors.lightSurfaceVariant,
        outline: AppColors.lightOutline,
        onSurface: AppColors.ink,
        onSurfaceVariant: AppColors.inkSoft,
        primary: AppColors.emerald600,
        onPrimary: Colors.white,
        secondary: AppColors.gold500,
      );

  static ThemeData dark() => _build(
        brightness: Brightness.dark,
        background: AppColors.darkBackground,
        surface: AppColors.darkSurface,
        surfaceVariant: AppColors.darkSurfaceVariant,
        outline: AppColors.darkOutline,
        onSurface: AppColors.cream,
        onSurfaceVariant: const Color(0xFFA9BDB6),
        primary: AppColors.emerald300,
        onPrimary: AppColors.emerald900,
        secondary: AppColors.gold400,
      );

  static ThemeData amoled() {
    final ThemeData base = dark();
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.amoledBackground,
      colorScheme: base.colorScheme.copyWith(
        surface: AppColors.amoledSurface,
        surfaceContainerHighest: AppColors.amoledSurfaceVariant,
        outlineVariant: AppColors.amoledOutline,
      ),
      cardTheme: base.cardTheme.copyWith(color: AppColors.amoledSurface),
      appBarTheme: base.appBarTheme
          .copyWith(backgroundColor: AppColors.amoledBackground),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme
          .copyWith(backgroundColor: AppColors.amoledSurface),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        backgroundColor: AppColors.amoledSurface,
        surfaceTintColor: Colors.transparent,
      ),
      dialogTheme:
          base.dialogTheme.copyWith(backgroundColor: AppColors.amoledSurface),
      bottomSheetTheme: base.bottomSheetTheme
          .copyWith(backgroundColor: AppColors.amoledSurface),
    );
  }

  static ThemeData resolve(AppThemeMode mode) => switch (mode) {
        AppThemeMode.light => light(),
        AppThemeMode.dark => dark(),
        AppThemeMode.amoled => amoled(),
        AppThemeMode.system => light(),
      };

  static ThemeData _build({
    required Brightness brightness,
    required Color background,
    required Color surface,
    required Color surfaceVariant,
    required Color outline,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
  }) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: isDark ? AppColors.emerald700 : AppColors.emerald100,
      onPrimaryContainer: isDark ? AppColors.emerald100 : AppColors.emerald900,
      secondary: secondary,
      onSecondary: isDark ? AppColors.emerald900 : Colors.white,
      secondaryContainer: isDark ? const Color(0xFF4A3B17) : AppColors.gold200,
      onSecondaryContainer:
          isDark ? AppColors.gold200 : const Color(0xFF4B3810),
      tertiary: AppColors.emerald500,
      onTertiary: Colors.white,
      error: AppColors.danger,
      onError: Colors.white,
      surface: surface,
      onSurface: onSurface,
      surfaceContainerHighest: surfaceVariant,
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
      outlineVariant: outline.withValues(alpha: 0.6),
      shadow: Colors.black.withValues(alpha: isDark ? 0.5 : 0.08),
      scrim: Colors.black,
      inverseSurface: isDark ? AppColors.cream : AppColors.emerald900,
      onInverseSurface: isDark ? AppColors.emerald900 : AppColors.cream,
      inversePrimary: isDark ? AppColors.emerald700 : AppColors.emerald300,
    );

    final TextTheme textTheme = _textTheme(scheme);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      fontFamily: _fontFamily,
      textTheme: textTheme,
      splashFactory: InkSparkle.splashFactory,
      visualDensity: VisualDensity.standard,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: PredictiveBackPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        surfaceTintColor: Colors.transparent,
        foregroundColor: onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        systemOverlayStyle:
            isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      ),
      cardTheme: CardThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allLg),
        clipBehavior: Clip.antiAlias,
      ),
      dividerTheme: DividerThemeData(
        color: outline.withValues(alpha: 0.5),
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: AppSpacing.listTile,
        iconColor: onSurfaceVariant,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
          side: BorderSide(color: outline),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle:
              textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allSm),
        side: BorderSide(color: outline.withValues(alpha: 0.7)),
        backgroundColor: surfaceVariant,
        labelStyle: textTheme.labelMedium,
        padding: AppSpacing.chip,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        hintStyle: textTheme.bodyMedium
            ?.copyWith(color: onSurfaceVariant.withValues(alpha: 0.7)),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(color: primary, width: 1.6),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(color: AppColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.allMd,
          borderSide: BorderSide(color: AppColors.danger, width: 1.6),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: isDark
            ? AppColors.emerald700.withValues(alpha: 0.55)
            : AppColors.emerald100,
        elevation: 0,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStatePropertyAll<TextStyle?>(
          textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        iconTheme: WidgetStateProperty.resolveWith<IconThemeData?>(
          (Set<WidgetState> states) => IconThemeData(
            size: 24,
            color: states.contains(WidgetState.selected)
                ? primary
                : onSurfaceVariant,
          ),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surface,
        selectedItemColor: primary,
        unselectedItemColor: onSurfaceVariant,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: AppRadius.xl),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allLg),
        titleTextStyle:
            textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.cream : AppColors.emerald900,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: isDark ? AppColors.ink : AppColors.cream,
        ),
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.allMd),
        insetPadding: AppSpacing.page,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariant,
        circularTrackColor: surfaceVariant,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: primary,
        thumbColor: primary,
        overlayColor: primary.withValues(alpha: 0.15),
        inactiveTrackColor: surfaceVariant,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected) ? onPrimary : null,
        ),
        trackColor: WidgetStateProperty.resolveWith<Color?>(
          (Set<WidgetState> states) =>
              states.contains(WidgetState.selected) ? primary : null,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: onSurfaceVariant,
        indicatorSize: TabBarIndicatorSize.label,
        dividerColor: Colors.transparent,
        labelStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cream : AppColors.emerald900,
          borderRadius: AppRadius.allSm,
        ),
        textStyle: textTheme.bodySmall?.copyWith(
          color: isDark ? AppColors.ink : AppColors.cream,
        ),
      ),
    );
  }

  static TextTheme _textTheme(ColorScheme scheme) {
    final Color strong = scheme.onSurface;
    final Color soft = scheme.onSurfaceVariant;
    return TextTheme(
      displayLarge: TextStyle(
          fontSize: 52,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.5,
          color: strong,
          height: 1.05),
      displayMedium: TextStyle(
          fontSize: 42,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.2,
          color: strong,
          height: 1.08),
      displaySmall: TextStyle(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          color: strong,
          height: 1.12),
      headlineMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
          color: strong),
      headlineSmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
          color: strong),
      titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
          color: strong),
      titleMedium:
          TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: strong),
      titleSmall:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: strong),
      bodyLarge: TextStyle(fontSize: 17, height: 1.5, color: strong),
      bodyMedium: TextStyle(fontSize: 15, height: 1.5, color: strong),
      bodySmall: TextStyle(fontSize: 13, height: 1.45, color: soft),
      labelLarge:
          TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: strong),
      labelMedium:
          TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: soft),
      labelSmall: TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
          color: soft),
    );
  }

  /// Kur'an metni için Arapça yazı stili.
  static TextStyle arabic(TextTheme theme,
          {double size = 26,
          Color? color,
          FontWeight weight = FontWeight.w400}) =>
      TextStyle(
        fontFamily: arabicFontFamily,
        fontSize: size,
        height: 2.05,
        fontWeight: weight,
        color: color ?? theme.bodyLarge?.color,
      );
}
