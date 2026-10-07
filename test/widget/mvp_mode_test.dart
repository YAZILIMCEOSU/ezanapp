import 'package:ezanai/app/app_runtime.dart';
import 'package:ezanai/core/config/app_features.dart';
import 'package:ezanai/features/home/home_screen.dart';
import 'package:ezanai/features/more/more_screen.dart';
import 'package:ezanai/features/widgets/app_shell.dart';
import 'package:ezanai/state/providers.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_runtime.dart';

/// Kademeli yayın (kapsam B) doğrulaması.
///
/// Faz 2+ modülleri kapatıldığında (MVP derlemesi) sekmelerin, ana ekran
/// kartlarının ve menü girişlerinin **gerçekten** gizlendiğini, ayrıca kapalı
/// yolların yönlendirildiğini sınar. Böylece "kapattım ama giriş görünüyor"
/// veya "boş ekrana düşüyor" durumları CI'da yakalanır.
void main() {
  group('sekme süzme', () {
    test('tam kapsamda beş sekme, sıraları korunarak görünür', () {
      final List<ShellTab> tabs = shellTabs(const AppFeatures());
      expect(tabs.map((ShellTab tab) => tab.label).toList(), <String>[
        'Ana Sayfa',
        'Vakitler',
        'Kur\'an',
        'İlahi',
        'Daha Fazla',
      ]);
      expect(tabs.map((ShellTab tab) => tab.branch).toList(), <int>[
        0,
        1,
        2,
        3,
        4,
      ]);
    });

    test('MVP kapsamında içerik sekmeleri gizlenir', () {
      final List<ShellTab> tabs = shellTabs(AppFeatures.mvp);
      expect(tabs.map((ShellTab tab) => tab.label).toList(), <String>[
        'Ana Sayfa',
        'Vakitler',
        'Daha Fazla',
      ]);
      // Sekme sırası StatefulShellRoute dal sırasıdır; "Daha Fazla" 4. daldır.
      expect(tabs.map((ShellTab tab) => tab.branch).toList(), <int>[0, 1, 4]);
    });

    test('kapalı modüllerin yolları yönlendirilir, açık olanlar kalır', () {
      const AppFeatures mvp = AppFeatures.mvp;
      for (final String blocked in <String>[
        '/quran',
        '/kuran/arama',
        '/kuran/sure/2',
        '/hadis',
        '/hadis/12',
        '/dualar',
        '/ilahi',
        '/ilahi/indirilenler',
        '/ramazan',
        '/ai',
        '/premium',
        '/ayarlar/yedekleme',
      ]) {
        expect(
          mvp.allows(blocked),
          isFalse,
          reason: '$blocked kapatılmış olmalıydı',
        );
      }
      for (final String open in <String>[
        '/home',
        '/prayers',
        '/qibla',
        '/zikir',
        '/zikir/istatistik',
        '/takvim',
        '/sehir-sec',
        '/ayarlar',
        '/ayarlar/bildirimler',
        '/ayarlar/hakkinda',
      ]) {
        expect(open, isNotEmpty);
        expect(
          mvp.allows(open),
          isTrue,
          reason: '$open MVP kapsamında açık kalmalıydı',
        );
      }
      expect(const AppFeatures().allows('/ai'), isTrue);
    });
  });

  group('MVP ekranları', () {
    late AppRuntime runtime;
    late TodayTimes times;
    String? databaseProblem;

    setUpAll(() async {
      initTestDatabaseFactory();
      databaseProblem = await probeDatabase();
      if (databaseProblem != null) return;
      runtime = await createTestRuntime();
      times = fixedTimes(DateTime.now());
    });

    testWidgets('ana ekran yalnızca MVP kartlarını gösterir', (
      WidgetTester tester,
    ) async {
      if (skipWithoutDatabase(databaseProblem)) return;
      await renderScreen(
        tester,
        const HomeScreen(),
        runtime: runtime,
        times: times,
        features: AppFeatures.mvp,
        verify: () {
          // MVP içerik: vakitler ve günlük zikir özeti görünür.
          expect(find.text('Bugünün vakitleri'), findsWidgets);
          expect(find.text('Günlük zikir'), findsWidgets);
          // Faz 2+ kartları hiç çizilmez.
          expect(find.text('Günün ayeti'), findsNothing);
          expect(find.text('Günün hadisi'), findsNothing);
          expect(find.text('Günün duası'), findsNothing);
          // Hızlı erişimde yalnızca Kıble ve Tesbih kalır.
          expect(find.text('Kıble'), findsWidgets);
          expect(find.text('Tesbih'), findsWidgets);
          expect(find.text('AI Asistan'), findsNothing);
        },
      );
    });

    testWidgets('Daha Fazla ekranı yalnızca açık modülleri listeler', (
      WidgetTester tester,
    ) async {
      if (skipWithoutDatabase(databaseProblem)) return;
      await renderScreen(
        tester,
        const MoreScreen(),
        runtime: runtime,
        times: times,
        features: AppFeatures.mvp,
        size: TestScreens.tablet,
        verify: () {
          expect(find.text('Kıble'), findsWidgets);
          expect(find.text('Tesbih ve Zikir'), findsWidgets);
          expect(find.text('Ayarlar'), findsWidgets);
          expect(find.text('Bildirim Ayarları'), findsWidgets);
          expect(find.text('Hicri Takvim ve Önemli Günler'), findsWidgets);
          // Kapatılan modüllerin girişleri yok.
          expect(find.text('Kur\'an-ı Kerim'), findsNothing);
          expect(find.text('İlahi ve Dini Sesler'), findsNothing);
          expect(find.text('AI İslam Asistanı'), findsNothing);
          expect(find.text('Dualar'), findsNothing);
          expect(find.text('Ramazan'), findsNothing);
        },
      );
    });
  });
}
