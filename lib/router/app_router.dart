import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/services/notification_service.dart';
import '../features/ai/ai_screen.dart';
import '../features/hadith/hadith_detail_screen.dart';
import '../features/hadith/hadith_screen.dart';
import '../features/home/home_screen.dart';
import '../features/ilahi/downloads_screen.dart';
import '../features/ilahi/ilahi_screen.dart';
import '../features/ilahi/player_screen.dart';
import '../features/ilahi/playlist_screen.dart';
import '../features/more/islamic_days_screen.dart';
import '../features/more/more_screen.dart';
import '../features/more/onboarding_screen.dart';
import '../features/more/premium_screen.dart';
import '../features/prayers/prayers_screen.dart';
import '../features/qibla/qibla_screen.dart';
import '../features/quran/quran_bookmarks_screen.dart';
import '../features/quran/quran_screen.dart';
import '../features/quran/quran_search_screen.dart';
import '../features/quran/surah_screen.dart';
import '../features/ramadan/ramadan_screen.dart';
import '../features/settings/about_screen.dart';
import '../features/settings/adhan_sound_screen.dart';
import '../features/settings/city_picker_screen.dart';
import '../features/settings/notification_settings_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/widgets/app_shell.dart';
import '../features/widgets/not_found_screen.dart';
import '../features/zikir/zikir_screen.dart';
import '../features/zikir/zikir_stats_screen.dart';

/// Kök yönlendirme anahtarı (bildirimden yönlendirme için).
final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

/// Sekme yolları — alt gezinme çubuğuyla birebir eşleşir.
abstract final class AppRoutes {
  static const String home = '/home';
  static const String prayers = '/prayers';
  static const String quran = '/quran';
  static const String ilahi = '/ilahi';
  static const String more = '/more';

  static const String qibla = '/qibla';
  static const String zikir = '/zikir';
  static const String zikirStats = '/zikir/istatistik';
  static const String hadith = '/hadis';
  static const String ramadan = '/ramazan';
  static const String ai = '/ai';
  static const String settings = '/ayarlar';
  static const String notificationSettings = '/ayarlar/bildirimler';
  static const String about = '/ayarlar/hakkinda';
  static const String premium = '/premium';
  static const String calendar = '/takvim';
  static const String cities = '/sehir-sec';
  static const String onboarding = '/hosgeldin';
  static const String quranSearch = '/kuran/arama';
  static const String quranBookmarks = '/kuran/favoriler';
  static const String ilahiPlaylists = '/ilahi/calma-listeleri';
  static const String player = '/ilahi/oynatici';
  static const String ilahiDownloads = '/ilahi/indirilenler';
  static const String adhanSounds = '/ayarlar/ezan-sesi';

  static String surah(int number, {int? ayah}) =>
      ayah == null ? '/kuran/sure/$number' : '/kuran/sure/$number?ayet=$ayah';

  static String hadithDetail(int id) => '/hadis/$id';

  static String playlist(int id) => '/ilahi/calma-listesi/$id';

  /// Bildirim yönlendirmesini uygulama yoluna çevirir.
  static String fromNotification(NotificationRoute route) => switch (route) {
    NotificationRoute.home => home,
    NotificationRoute.times => prayers,
    NotificationRoute.quran => quran,
    NotificationRoute.ramadan => ramadan,
    NotificationRoute.zikir => zikir,
    NotificationRoute.hadith => hadith,
    NotificationRoute.adhan => prayers,
  };
}

/// Uygulamanın yönlendiricisi.
///
/// * Sekmeler `StatefulShellRoute` ile korunur (sekme değişince durum kaybolmaz).
/// * Detay ekranları tam ekran açılır; geri dönüşte sekme konumu korunur.
final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.home,
  debugLogDiagnostics: false,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (
        BuildContext context,
        GoRouterState state,
        StatefulNavigationShell shell,
      ) => AppShell(navigationShell: shell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.home,
              name: 'home',
              builder: (BuildContext context, GoRouterState state) =>
                  const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.prayers,
              name: 'prayers',
              builder: (BuildContext context, GoRouterState state) =>
                  const PrayersScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.quran,
              name: 'quran',
              builder: (BuildContext context, GoRouterState state) =>
                  const QuranScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.ilahi,
              name: 'ilahi',
              builder: (BuildContext context, GoRouterState state) =>
                  const IlahiScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: AppRoutes.more,
              name: 'more',
              builder: (BuildContext context, GoRouterState state) =>
                  const MoreScreen(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.onboarding,
      builder: (BuildContext context, GoRouterState state) =>
          const OnboardingScreen(),
    ),
    GoRoute(
      path: AppRoutes.qibla,
      builder: (BuildContext context, GoRouterState state) =>
          const QiblaScreen(),
    ),
    GoRoute(
      path: AppRoutes.zikir,
      builder: (BuildContext context, GoRouterState state) =>
          const ZikirScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'istatistik',
          builder: (BuildContext context, GoRouterState state) =>
              const ZikirStatsScreen(),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.hadith,
      builder: (BuildContext context, GoRouterState state) =>
          const HadithScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: ':id',
          builder: (BuildContext context, GoRouterState state) =>
              HadithDetailScreen(
                hadithId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
              ),
        ),
      ],
    ),
    GoRoute(
      path: AppRoutes.ramadan,
      builder: (BuildContext context, GoRouterState state) =>
          const RamadanScreen(),
    ),
    GoRoute(
      path: AppRoutes.ai,
      builder: (BuildContext context, GoRouterState state) => const AiScreen(),
    ),
    GoRoute(
      path: AppRoutes.premium,
      builder: (BuildContext context, GoRouterState state) =>
          const PremiumScreen(),
    ),
    GoRoute(
      path: AppRoutes.calendar,
      builder: (BuildContext context, GoRouterState state) =>
          const IslamicDaysScreen(),
    ),
    GoRoute(
      path: AppRoutes.cities,
      builder: (BuildContext context, GoRouterState state) =>
          const CityPickerScreen(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (BuildContext context, GoRouterState state) =>
          const SettingsScreen(),
      routes: <RouteBase>[
        GoRoute(
          path: 'bildirimler',
          builder: (BuildContext context, GoRouterState state) =>
              const NotificationSettingsScreen(),
        ),
        GoRoute(
          path: 'hakkinda',
          builder: (BuildContext context, GoRouterState state) =>
              const AboutScreen(),
        ),
      ],
    ),
    GoRoute(
      path: '/kuran/arama',
      builder: (BuildContext context, GoRouterState state) =>
          const QuranSearchScreen(),
    ),
    GoRoute(
      path: '/kuran/favoriler',
      builder: (BuildContext context, GoRouterState state) =>
          const QuranBookmarksScreen(),
    ),
    GoRoute(
      path: '/kuran/sure/:number',
      builder: (BuildContext context, GoRouterState state) => SurahScreen(
        surahNumber: int.tryParse(state.pathParameters['number'] ?? '') ?? 1,
        initialAyah: int.tryParse(state.uri.queryParameters['ayet'] ?? ''),
      ),
    ),
    GoRoute(
      path: AppRoutes.player,
      builder: (BuildContext context, GoRouterState state) =>
          const PlayerScreen(),
    ),
    GoRoute(
      path: AppRoutes.ilahiDownloads,
      builder: (BuildContext context, GoRouterState state) =>
          const DownloadsScreen(),
    ),
    GoRoute(
      path: AppRoutes.adhanSounds,
      builder: (BuildContext context, GoRouterState state) =>
          const AdhanSoundScreen(),
    ),
    GoRoute(
      path: AppRoutes.ilahiPlaylists,
      builder: (BuildContext context, GoRouterState state) =>
          const PlaylistScreen(),
    ),
    GoRoute(
      path: '/ilahi/calma-listesi/:id',
      builder: (BuildContext context, GoRouterState state) => PlaylistScreen(
        playlistId: int.tryParse(state.pathParameters['id'] ?? ''),
      ),
    ),
  ],
  errorBuilder: (BuildContext context, GoRouterState state) =>
      NotFoundScreen(location: state.uri.toString()),
);
