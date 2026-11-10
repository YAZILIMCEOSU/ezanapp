import 'package:ezanai/core/services/notification_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

/// Simge hatası yüzünden başlatma düşerse servisin **kalıcı olarak
/// susmadığını** doğrular: en fazla üç tur yeniden denenir.
class _FailingPlugin extends FlutterLocalNotificationsPlugin {
  int initializeCalls = 0;

  @override
  Future<bool?> initialize({
    required InitializationSettings settings,
    DidReceiveNotificationResponseCallback? onDidReceiveNotificationResponse,
    DidReceiveBackgroundNotificationResponseCallback?
    onDidReceiveBackgroundNotificationResponse,
  }) async {
    initializeCalls++;
    throw PlatformException(
      code: 'INVALID_ICON',
      message: 'test: simge bulunamadı',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'başlatma hatası oturumu kalıcı susturmaz, üç kez yeniden denenir',
    () async {
      final _FailingPlugin plugin = _FailingPlugin();
      final NotificationService service = NotificationService(plugin: plugin);

      // Her turda iki simge denenir (asıl + yedek).
      await service.initialize();
      expect(plugin.initializeCalls, 2);

      await service.initialize();
      expect(plugin.initializeCalls, 4);

      await service.initialize();
      expect(plugin.initializeCalls, 6);

      // Üst sınır aşılmaz: gereksiz deneme yapılmaz.
      await service.initialize();
      expect(plugin.initializeCalls, 6);
    },
  );
}
