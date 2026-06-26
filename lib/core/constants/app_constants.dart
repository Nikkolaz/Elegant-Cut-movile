import 'dart:io' show Platform;

class ApiConstants {
  static String get baseUrl {
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:3001/api';
      }
    } catch (_) {}
    return 'http://localhost:3001/api';
  }

  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String checkToken = '/auth/check-token';
}

class AppConstants {
  static const String appName = 'Elegant Cut';
}
