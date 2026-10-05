import 'package:ezanai/core/services/notification_service.dart';
import 'package:ezanai/router/app_router.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Navigasyon kapsamı testleri.
///
/// Amaç: kod içinde tanımlı **her yolun** gerçekten bir ekrana bağlı olduğunu
/// ve bildirim yönlendirmelerinin geçerli bir yola çıktığını doğrulamak.
/// Böylece "buton var ama ekran yok" veya "bildirim yanlış sayfaya gidiyor"
/// hataları CI'da yakalanır.
void main() {
  RouteMatchList matchOf(String location) =>
      appRouter.configuration.findMatch(Uri.parse(location));

  void expectResolves(String location) {
    final RouteMatchList match = matchOf(location);
    expect(
      match.isError,
      isFalse,
      reason: '"$location" bir ekrana bağlı değil (hata rotasına düştü)',
    );
    expect(
      match.matches,
      isNotEmpty,
      reason: '"$location" için eşleşen rota yok',
    );
  }

  group('sekme yolları', () {
    test('beş ana sekme de çözümlenir', () {
      for (final String route in <String>[
        AppRoutes.home,
        AppRoutes.prayers,
        AppRoutes.quran,
        AppRoutes.ilahi,
        AppRoutes.more,
      ]) {
        expectResolves(route);
      }
    });
  });

  group('tüm sabit yollar çözümlenir', () {
    test('sabit yol sabitleri', () {
      for (final String route in <String>[
        AppRoutes.home,
        AppRoutes.prayers,
        AppRoutes.quran,
        AppRoutes.ilahi,
        AppRoutes.more,
        AppRoutes.qibla,
        AppRoutes.zikir,
        AppRoutes.zikirStats,
        AppRoutes.hadith,
        AppRoutes.dualar,
        AppRoutes.ramadan,
        AppRoutes.ai,
        AppRoutes.settings,
        AppRoutes.notificationSettings,
        AppRoutes.about,
        AppRoutes.premium,
        AppRoutes.calendar,
        AppRoutes.cities,
        AppRoutes.onboarding,
        AppRoutes.quranSearch,
        AppRoutes.quranBookmarks,
        AppRoutes.ilahiPlaylists,
        AppRoutes.player,
        AppRoutes.ilahiDownloads,
        AppRoutes.adhanSounds,
        AppRoutes.backup,
      ]) {
        expectResolves(route);
      }
    });

    test('parametreli yollar çözümlenir', () {
      expectResolves(AppRoutes.surah(1));
      expectResolves(AppRoutes.surah(114));
      expectResolves(AppRoutes.surah(2, ayah: 255));
      expectResolves(AppRoutes.hadithDetail(1));
      expectResolves(AppRoutes.playlist(1));
    });

    test('son sekmedeki alt sayfalar da çözümlenir', () {
      expectResolves('/ayarlar/bildirimler');
      expectResolves('/ayarlar/hakkinda');
      expectResolves('/ayarlar/ezan-sesi');
      expectResolves('/ayarlar/yedekleme');
    });
  });

  group('bildirim yönlendirmesi', () {
    test('her bildirim hedefi geçerli bir yola gider', () {
      for (final NotificationRoute route in NotificationRoute.values) {
        final String location = AppRoutes.fromNotification(route);
        expectResolves(location);
      }
    });

    test('eski bildirim yükleri doğru ekrana yönlendirir', () {
      // Uygulama güncellendiğinde cihazda bekleyen eski bildirimler de
      // doğru çalışmalı: yük biçimi "route:ayrıntı" şeklindedir.
      expectResolves(
        AppRoutes.fromNotification(
          NotificationRoute.fromPayload('adhan:aksam'),
        ),
      );
      expectResolves(
        AppRoutes.fromNotification(
          NotificationRoute.fromPayload('times:imsak'),
        ),
      );
      expectResolves(
        AppRoutes.fromNotification(NotificationRoute.fromPayload(null)),
      );
      expectResolves(
        AppRoutes.fromNotification(
          NotificationRoute.fromPayload('bilinmeyen-deger'),
        ),
      );
    });
  });

  group('bilinmeyen yol', () {
    test('tanımsız yol hata ekranına düşer (çökme yok)', () {
      final RouteMatchList match = matchOf('/boyle-bir-yol-yok');
      expect(match.isError, isTrue);
    });
  });

  group('yol sabitleri tutarlı', () {
    test('yol sabitleri Türkçe ve küçük harfli', () {
      for (final String route in <String>[
        AppRoutes.qibla,
        AppRoutes.zikir,
        AppRoutes.hadith,
        AppRoutes.ramadan,
        AppRoutes.settings,
        AppRoutes.premium,
        AppRoutes.calendar,
        AppRoutes.cities,
        AppRoutes.onboarding,
      ]) {
        expect(route.startsWith('/'), isTrue, reason: route);
        expect(route.contains(' '), isFalse, reason: route);
        expect(route, route.toLowerCase(), reason: route);
      }
    });

    test('sure/ayet yolu sorgu parametresiyle kurulur', () {
      expect(AppRoutes.surah(2), '/kuran/sure/2');
      expect(AppRoutes.surah(2, ayah: 255), '/kuran/sure/2?ayet=255');
      expect(AppRoutes.hadithDetail(42), '/hadis/42');
      expect(AppRoutes.playlist(7), '/ilahi/calma-listesi/7');
    });
  });
}
