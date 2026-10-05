import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../router/app_router.dart';
import '../config/app_config.dart';
import '../utils/logger.dart';
import 'notification_service.dart';

/// Arka planda (uygulama kapalıyken) gelen veri mesajlarını işler.
///
/// Firebase bu izolatta ayrıca başlatılmalıdır; hata olsa bile uygulama
/// açılışını engellememesi için tüm iş sessizce yutulur.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp();
    }
  } catch (error) {
    AppLog.warning('Arka plan bildirimi işlenemedi: $error');
  }
}

/// Sunucudan gönderilen bildirim (FCM) modeli.
class PushMessage {
  const PushMessage({
    required this.title,
    required this.body,
    this.data = const <String, String>{},
    this.route,
  });

  final String title;
  final String body;
  final Map<String, String> data;

  /// Bildirime dokunulduğunda gidilecek uygulama yolu.
  final String? route;

  factory PushMessage.fromRemoteMessage(RemoteMessage message) {
    final Object? payloadRoute = message.data['route'];
    final NotificationRoute route = NotificationRoute.fromPayload(
      payloadRoute?.toString(),
    );
    return PushMessage(
      title:
          message.notification?.title ??
          (message.data['title'] as String? ?? 'EzanAI'),
      body:
          message.notification?.body ?? (message.data['body'] as String? ?? ''),
      data: message.data.map(
        (String key, Object? value) => MapEntry<String, String>(key, '$value'),
      ),
      // Yol eşlemesi tek yerde tutulur (AppRoutes.fromNotification); böylece
      // yeni bir bildirim hedefi eklendiğinde buranın güncellenmesi unutulamaz.
      route: AppRoutes.fromNotification(route),
    );
  }
}

/// Firebase Cloud Messaging köprüsü.
///
/// Firebase yapılandırılmadıysa (`FIREBASE_ENABLED=false` veya
/// `google-services.json` yoksa) servis sessizce devre dışı kalır; vakit
/// bildirimleri tamamen **yerel** olarak zamanlandığı için uygulamanın
/// çalışması bu servise bağlı değildir.
class PushService {
  PushService({this._messaging});

  FirebaseMessaging? _messaging;
  bool _initialized = false;
  bool _available = false;
  String? _token;
  String? _lastError;
  String? _pendingRoute;

  final StreamController<PushMessage> _messageController =
      StreamController<PushMessage>.broadcast();
  Stream<PushMessage> get onMessage => _messageController.stream;

  bool get isAvailable => _available;
  String? get token => _token;
  String? get lastError => _lastError;

  /// Uygulama kapalıyken dokunulan bildirimin yönlendirmesi.
  ///
  /// Yönlendirici hazır olmadan tüketilmemesi için burada saklanır;
  /// arayüz hazır olduğunda [takePendingRoute] ile alınır.
  String? takePendingRoute() {
    final String? route = _pendingRoute;
    _pendingRoute = null;
    return route;
  }

  Future<bool> initialize() async {
    if (_initialized) return _available;
    _initialized = true;

    if (!AppConfig.firebaseEnabled) {
      _lastError = 'Firebase yapılandırılmadı (FIREBASE_ENABLED=false).';
      AppLog.info('Bildirim köprüsü kapalı: $_lastError');
      return false;
    }

    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      _messaging ??= FirebaseMessaging.instance;

      await FirebaseMessaging.instance.requestPermission();
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
      _token = await _messaging!.getToken();
      _messaging!.onTokenRefresh.listen((String value) => _token = value);

      FirebaseMessaging.onMessage.listen(_handleForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpened);
      final RemoteMessage? initial = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initial != null) {
        // Uygulama bildirimden açıldıysa yönlendirme ana ekranda tüketilir.
        _handleOpened(initial);
      }

      _available = true;
      AppLog.info('Bildirim köprüsü hazır (FCM).');
      return true;
    } catch (error) {
      _lastError = 'Firebase başlatılamadı: $error';
      AppLog.warning(_lastError!);
      _available = false;
      return false;
    }
  }

  void _handleForeground(RemoteMessage message) {
    if (_messageController.isClosed) return;
    _messageController.add(PushMessage.fromRemoteMessage(message));
  }

  void _handleOpened(RemoteMessage message) {
    final PushMessage parsed = PushMessage.fromRemoteMessage(message);
    _pendingRoute = parsed.route;
    if (_messageController.isClosed) return;
    _messageController.add(parsed);
  }

  /// Duyuru/hatırlatma konularına abone olur (ör. kadir_gecesi).
  Future<void> subscribe(String topic) async {
    if (!_available) return;
    try {
      await _messaging!.subscribeToTopic(topic);
    } catch (error) {
      AppLog.warning('Konuya abone olunamadı ($topic): $error');
    }
  }

  Future<void> unsubscribe(String topic) async {
    if (!_available) return;
    try {
      await _messaging!.unsubscribeFromTopic(topic);
    } catch (error) {
      AppLog.warning('Konudan çıkılamadı ($topic): $error');
    }
  }

  Future<void> dispose() async {
    await _messageController.close();
  }
}
