import 'package:ezanai/app/app_runtime.dart';
import 'package:ezanai/core/errors/app_exception.dart';
import 'package:ezanai/features/dua/dua_screen.dart';
import 'package:ezanai/features/hadith/hadith_screen.dart';
import 'package:ezanai/features/home/home_screen.dart';
import 'package:ezanai/features/more/islamic_days_screen.dart';
import 'package:ezanai/features/more/more_screen.dart';
import 'package:ezanai/features/prayers/prayers_screen.dart';
import 'package:ezanai/features/quran/quran_screen.dart';
import 'package:ezanai/features/settings/about_screen.dart';
import 'package:ezanai/features/settings/notification_settings_screen.dart';
import 'package:ezanai/features/settings/settings_screen.dart';
import 'package:ezanai/features/widgets/state_views.dart';
import 'package:ezanai/features/zikir/zikir_screen.dart';
import 'package:ezanai/state/providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_runtime.dart';

/// Ekranların farklı cihaz boyutlarında (küçük telefon → tablet) taşma
/// üretmediğini ve çizim sırasında hata fırlatmadığını doğrular.
///
/// Faz kapısı: "ekran boyutu + tablet uyumu". Testler gerçek repository'lerle
/// çalışır; ağ erişimi yoktur, vakitler sabit verilir.
void main() {
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

  /// Veritabanı kurulamazsa ekran testleri atlanır.
  void screenTest(
    String description,
    Future<void> Function(WidgetTester) body,
  ) {
    testWidgets(description, (WidgetTester tester) async {
      if (skipWithoutDatabase(databaseProblem)) return;
      await body(tester);
    });
  }

  final Map<String, Widget Function()> screens = <String, Widget Function()>{
    'Ana sayfa': HomeScreen.new,
    'Vakitler': PrayersScreen.new,
    'Kur\'an': QuranScreen.new,
    'Dualar': DuaScreen.new,
    'Hadis': HadithScreen.new,
    'Zikir': ZikirScreen.new,
    'Hicri takvim': IslamicDaysScreen.new,
    'Daha Fazla': MoreScreen.new,
    'Ayarlar': SettingsScreen.new,
    'Bildirim ayarları': NotificationSettingsScreen.new,
    'Hakkında': AboutScreen.new,
  };

  group('taşma ve çizim hatası yok', () {
    for (final MapEntry<String, Widget Function()> screen in screens.entries) {
      for (final MapEntry<String, Size> size in TestScreens.named.entries) {
        screenTest('${screen.key} — ${size.key}', (WidgetTester tester) async {
          await renderScreen(
            tester,
            screen.value(),
            runtime: runtime,
            size: size.value,
            times: times,
          );
        });
      }
    }
  });

  group('içerik gerçekten çiziliyor', () {
    screenTest('Dualar: künye özeti ve kategori çipleri görünür', (
      WidgetTester tester,
    ) async {
      await renderScreen(
        tester,
        const DuaScreen(),
        runtime: runtime,
        times: times,
      );

      expect(find.text('Dualar'), findsWidgets);
      expect(find.textContaining('dua · kaynak künyeli'), findsOneWidget);
      expect(find.textContaining('Tümü ('), findsOneWidget);
      expect(find.byType(FilterChip), findsWidgets);
    });

    screenTest('Hadis: başlık ve konu çipleri görünür', (
      WidgetTester tester,
    ) async {
      await renderScreen(
        tester,
        const HadithScreen(),
        runtime: runtime,
        times: times,
      );

      expect(find.text('Hadis'), findsWidgets);
      expect(find.byType(FilterChip), findsWidgets);
    });

    screenTest('Zikir: tesbih ekranı sayaç ile çizilir', (
      WidgetTester tester,
    ) async {
      await renderScreen(
        tester,
        const ZikirScreen(),
        runtime: runtime,
        times: times,
      );

      expect(find.text('Tesbih'), findsWidgets);
    });

    screenTest('Kur\'an: sure listesi yüklenir', (WidgetTester tester) async {
      await renderScreen(
        tester,
        const QuranScreen(),
        runtime: runtime,
        times: times,
      );

      expect(find.textContaining('Kur'), findsWidgets);
    });

    screenTest('Daha Fazla: tüm bölüm girişleri listelenir', (
      WidgetTester tester,
    ) async {
      // Tablet boyutunda tüm girişler aynı ekranda görünür.
      await renderScreen(
        tester,
        const MoreScreen(),
        runtime: runtime,
        size: TestScreens.tablet,
        times: times,
      );

      expect(find.text('Dualar'), findsWidgets);
      expect(find.text('Hadis'), findsWidgets);
      expect(find.text('Tesbih ve Zikir'), findsWidgets);
      expect(find.text('Hicri Takvim ve Önemli Günler'), findsWidgets);
    });
  });

  group('hata ve uyarı durumları kullanıcıya bildirilir', () {
    screenTest('hata görünümü anlaşılır mesaj ve "Tekrar dene" sunar', (
      WidgetTester tester,
    ) async {
      await renderScreen(
        tester,
        Scaffold(
          body: ErrorView(error: AppException.network(), onRetry: () {}),
        ),
        runtime: runtime,
        times: times,
      );

      expect(find.text('Bir şeyler ters gitti'), findsOneWidget);
      expect(
        find.textContaining('İnternet bağlantısı kurulamadı'),
        findsOneWidget,
      );
      expect(find.text('Tekrar dene'), findsOneWidget);
    });

    screenTest('izni olmayan hatalarda "Tekrar dene" gösterilmez', (
      WidgetTester tester,
    ) async {
      await renderScreen(
        tester,
        Scaffold(
          body: ErrorView(
            error: AppException.locationDisabled(),
            onRetry: () {},
          ),
        ),
        runtime: runtime,
        times: times,
      );

      expect(find.textContaining('Konum servisleri kapalı'), findsOneWidget);
      expect(find.text('Tekrar dene'), findsNothing);
    });

    screenTest('vakitler cihazda hesaplandıysa uyarı şeridi görünür', (
      WidgetTester tester,
    ) async {
      await renderScreen(
        tester,
        const HomeScreen(),
        runtime: runtime,
        times: fixedTimes(
          DateTime.now(),
          warning:
              'Resmî vakit servisine ulaşılamadı; vakitler cihazda hesaplandı.',
        ),
      );

      expect(find.textContaining('cihazda hesaplandı'), findsOneWidget);
    });
  });
}
