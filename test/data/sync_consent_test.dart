import 'package:ezanai/app/app_runtime.dart';
import 'package:ezanai/core/constants/app_constants.dart';
import 'package:flutter_test/flutter_test.dart';

import '../support/test_runtime.dart';

/// KVKK: bulut yedekleme açık rızası olmadan hiçbir veri sunucuya gitmez.
///
/// Bu testler ağa çıkmaz: rıza kapısı Supabase yapılandırmasından **önce**
/// çalıştığı için rıza yokken `ensureSession()` bile çağrılmaz.
void main() {
  initTestDatabaseFactory();

  String? databaseProblem;

  setUpAll(() async {
    databaseProblem = await probeDatabase();
  });

  group('Bulut yedekleme rıza kapısı', () {
    test('rıza yokken yükleme engellenir ve sunucuya gidilmez', () async {
      if (skipWithoutDatabase(databaseProblem)) return;
      final AppRuntime runtime = await createTestRuntime();
      addTearDown(runtime.dispose);

      final bool uploaded = await runtime.sync.uploadBackup();

      expect(uploaded, isFalse);
      expect(runtime.sync.lastError, contains('açık rızası'));
      expect(runtime.sync.userId, isNull);
    });

    test('rıza yokken indirme engellenir ve sunucuya gidilmez', () async {
      if (skipWithoutDatabase(databaseProblem)) return;
      final AppRuntime runtime = await createTestRuntime();
      addTearDown(runtime.dispose);

      final Map<String, Object?>? payload = await runtime.sync.downloadBackup();

      expect(payload, isNull);
      expect(runtime.sync.lastError, contains('açık rızası'));
      expect(runtime.sync.userId, isNull);
    });

    test('rıza varsa yapılandırma yokluğu yerel hataya döner', () async {
      if (skipWithoutDatabase(databaseProblem)) return;
      final AppRuntime runtime = await createTestRuntime(
        preferences: <String, Object>{
          PrefKeys.backupConsentAt: DateTime.now().toIso8601String(),
        },
      );
      addTearDown(runtime.dispose);

      if (runtime.sync.isConfigured) {
        markTestSkipped('Test ortamında Supabase yapılandırılmış.');
        return;
      }

      expect(await runtime.sync.uploadBackup(), isFalse);
      expect(runtime.sync.lastError, contains('yapılandırılmadı'));
    });

    test('rıza geri çekilince yükleme yeniden engellenir', () async {
      if (skipWithoutDatabase(databaseProblem)) return;
      final AppRuntime runtime = await createTestRuntime(
        preferences: <String, Object>{
          PrefKeys.backupConsentAt: DateTime.now().toIso8601String(),
        },
      );
      addTearDown(runtime.dispose);

      // Rıza kaydını sil (Ayarlar → Açık rızalarım → Bulut yedekleme kapat).
      await runtime.preferences.remove(PrefKeys.backupConsentAt);

      expect(await runtime.sync.uploadBackup(), isFalse);
      expect(runtime.sync.lastError, contains('açık rızası'));
    });
  });
}
