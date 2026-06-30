import 'package:elegant_cut_mobile/core/network/fcm_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Notificación en background: ${message.notification?.title}');
}

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;
  NotificationService._();

  FirebaseMessaging? _messaging;
  final FcmApiService _fcmApi = FcmApiService();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;
    try {
      _messaging = FirebaseMessaging.instance;
      await _requestPermission();
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      _messaging!.getToken().then((token) {
        if (token != null) _registerTokenIfNeeded(token);
      });

      _messaging!.onTokenRefresh.listen((token) {
        _registerTokenIfNeeded(token);
      });

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
      _isInitialized = true;
    } catch (e) {
      print('NotificationService: Firebase no disponible - $e');
    }
  }

  Future<void> _requestPermission() async {
    if (_messaging == null) return;
    final settings = await _messaging!.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      print('Permiso de notificaciones denegado');
    }
  }

  Future<void> _registerTokenIfNeeded(String token) async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.containsKey('token');
    if (!isLoggedIn) return;

    final savedToken = prefs.getString('fcm_token');
    if (savedToken != token) {
      await _fcmApi.registerToken(token);
    }
  }

  Future<void> registerAfterLogin() async {
    if (_messaging == null) return;
    final token = await _messaging!.getToken();
    if (token != null) {
      await _fcmApi.registerToken(token);
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('Notificación en foreground: ${message.notification?.title}');
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('Notificación presionada: ${message.data}');
  }

  Future<void> unregisterToken() async {
    await _fcmApi.unregisterToken();
  }

  Future<String?> getToken() async {
    if (_messaging == null) return null;
    return _messaging!.getToken();
  }
}
